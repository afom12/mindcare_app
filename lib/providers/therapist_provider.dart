import 'package:flutter/foundation.dart';

import '../models/therapist_models.dart';
import '../services/api_exception.dart';
import '../services/therapist_service.dart';
import 'auth_provider.dart';

enum TherapistRequestPhase { idle, loading, success, error }

class TherapistProvider extends ChangeNotifier {
  TherapistProvider(this._service, this._authProvider);

  final TherapistService _service;
  final AuthProvider _authProvider;

  TherapistConnectionState _connection = TherapistConnectionState(status: TherapistAssignmentStatus.none);
  TherapistConnectionState get connection => _connection;

  List<TherapistThreadMessage> _messages = [];
  List<TherapistThreadMessage> get messages => List.unmodifiable(_messages);

  bool _statusLoading = false;
  bool get statusLoading => _statusLoading;

  bool _messagesLoading = false;
  bool get messagesLoading => _messagesLoading;

  bool _sending = false;
  bool get sending => _sending;

  TherapistRequestPhase _requestPhase = TherapistRequestPhase.idle;
  TherapistRequestPhase get requestPhase => _requestPhase;

  String? _lastError;
  String? get lastError => _lastError;

  String get _userId => _authProvider.user?.id ?? '';

  Future<void> refreshStatus() async {
    if (_userId.isEmpty) return;
    _statusLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _connection = await _service.fetchStatus();
    } on ApiException catch (e) {
      _lastError = e.message;
    } catch (_) {
      _lastError = 'We could not refresh therapist status.';
    } finally {
      _statusLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMessages() async {
    if (!_connection.canUseTherapistChat) return;
    if (_userId.isEmpty) return;
    _messagesLoading = true;
    notifyListeners();
    try {
      _messages = await _service.fetchMessages(currentUserId: _userId);
      _lastError = null;
    } on ApiException catch (e) {
      _lastError = e.message;
    } catch (_) {
      _lastError = 'Messages could not be loaded.';
    } finally {
      _messagesLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestTherapistSupport() async {
    _requestPhase = TherapistRequestPhase.loading;
    _lastError = null;
    notifyListeners();
    try {
      await _service.requestSupport();
      _requestPhase = TherapistRequestPhase.success;
      await refreshStatus();
    } on ApiException catch (e) {
      _requestPhase = TherapistRequestPhase.error;
      _lastError = e.message;
    } catch (_) {
      _requestPhase = TherapistRequestPhase.error;
      _lastError = 'Something went wrong. Please try again when you feel ready.';
    } finally {
      notifyListeners();
    }
  }

  void resetRequestPhase() {
    _requestPhase = TherapistRequestPhase.idle;
    notifyListeners();
  }

  Future<void> sendTherapistMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!_connection.canUseTherapistChat) return;
    _sending = true;
    notifyListeners();
    try {
      await _service.sendMessage(trimmed);
      await refreshMessages();
      _lastError = null;
    } on ApiException catch (e) {
      _lastError = e.message;
    } catch (_) {
      _lastError = 'Your message could not be sent. Check your connection.';
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
