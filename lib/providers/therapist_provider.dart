import 'package:flutter/foundation.dart';

import '../models/therapist_models.dart';
import '../services/api_exception.dart';
import '../services/therapist_inbox_prefs.dart';
import '../services/therapist_service.dart';
import 'auth_provider.dart';

enum TherapistRequestPhase { idle, loading, success, error }

class TherapistProvider extends ChangeNotifier {
  TherapistProvider(this._service, this._authProvider);

  final TherapistService _service;
  final AuthProvider _authProvider;
  final TherapistInboxPrefs _inboxPrefs = TherapistInboxPrefs();

  TherapistConnectionState _connection = TherapistConnectionState(status: TherapistAssignmentStatus.none);
  TherapistConnectionState get connection => _connection;

  List<TherapistThreadMessage> _messages = [];
  List<TherapistThreadMessage> get messages => List.unmodifiable(_messages);

  final List<TherapistThreadMessage> _optimistic = [];

  /// Server messages plus optimistic / failed outbound bubbles, sorted by time.
  List<TherapistThreadMessage> get threadMessages {
    final merged = [..._messages, ..._optimistic];
    merged.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(merged);
  }

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

  /// Prefer real id; fall back to email so message bubbles match API sender ids when id was missing.
  String get _identityForMessages {
    final u = _authProvider.user;
    if (u == null) return '';
    if (u.id.isNotEmpty && u.id != 'session') return u.id;
    return u.email;
  }

  Future<void> refreshStatus() async {
    if (!_authProvider.isAuthenticated) return;
    _statusLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _connection = await _service.fetchStatus();
      if (!_connection.canUseTherapistChat) {
        _optimistic.clear();
      }
    } on ApiException catch (e) {
      _lastError = e.message;
    } catch (_) {
      _lastError = 'We could not refresh therapist status.';
    } finally {
      _statusLoading = false;
      notifyListeners();
    }
  }

  /// Returns true when [signalNewTherapistReply] is set and a new therapist reply should be surfaced (e.g. snackbar on resume).
  Future<bool> refreshMessages({bool signalNewTherapistReply = false}) async {
    if (!_connection.canUseTherapistChat) return false;
    final uid = _identityForMessages;
    if (uid.isEmpty) return false;
    _messagesLoading = true;
    notifyListeners();
    var nudge = false;
    try {
      _messages = await _service.fetchMessages(currentUserId: uid);
      _pruneOptimisticAfterRefresh();
      _lastError = null;
      if (signalNewTherapistReply) {
        nudge = await _shouldNudgeTherapistReply();
      }
    } on ApiException catch (e) {
      _lastError = e.message;
    } catch (_) {
      _lastError = 'Messages could not be loaded.';
    } finally {
      _messagesLoading = false;
      notifyListeners();
    }
    return nudge;
  }

  Future<bool> _shouldNudgeTherapistReply() async {
    final fromTherapist = _messages.where((m) => !m.isFromStudent).toList();
    if (fromTherapist.isEmpty) return false;
    fromTherapist.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final latest = fromTherapist.last;
    final seen = await _inboxPrefs.readSeenMessageId();
    final prompted = await _inboxPrefs.readPromptedMessageId();
    if (seen == null && prompted == null) {
      await _inboxPrefs.bootstrapCursors(latest.id);
      return false;
    }
    if (latest.id == seen) return false;
    if (latest.id == prompted) return false;
    await _inboxPrefs.writePromptedMessageId(latest.id);
    return true;
  }

  /// Call when the student opens Human support so we do not repeat resume prompts for already-read replies.
  Future<void> markTherapistHubViewed() async {
    final fromTherapist = _messages.where((m) => !m.isFromStudent).toList();
    if (fromTherapist.isEmpty) return;
    fromTherapist.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await _inboxPrefs.writeSeenMessageId(fromTherapist.last.id);
  }

  /// Remove optimistic rows that now appear in the server list (same text + recent).
  void _pruneOptimisticAfterRefresh() {
    if (_optimistic.isEmpty) return;
    final serverTexts = _messages.map((m) => m.message.trim()).toSet();
    _optimistic.removeWhere(
      (o) =>
          o.isFromStudent &&
          serverTexts.contains(o.message.trim()) &&
          o.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5))),
    );
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
    final uid = _identityForMessages;
    if (uid.isEmpty) return;
    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = TherapistThreadMessage.optimistic(
      id: localId,
      text: trimmed,
      currentUserId: uid,
      delivery: TherapistMessageDelivery.pending,
    );
    _optimistic.add(optimistic);
    _sending = true;
    _lastError = null;
    notifyListeners();
    try {
      await _service.sendMessage(trimmed);
      _optimistic.removeWhere((m) => m.id == localId);
      await refreshMessages(signalNewTherapistReply: false);
    } on ApiException catch (e) {
      _lastError = e.message;
      _markOptimisticFailed(localId);
    } catch (_) {
      _lastError = 'Your message could not be sent. Check your connection.';
      _markOptimisticFailed(localId);
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  void _markOptimisticFailed(String localId) {
    final i = _optimistic.indexWhere((m) => m.id == localId);
    if (i < 0) return;
    final o = _optimistic[i];
    _optimistic[i] = TherapistThreadMessage.optimistic(
      id: o.id,
      text: o.message,
      currentUserId: o.senderId,
      delivery: TherapistMessageDelivery.failed,
    );
  }

  Future<void> retryOptimisticMessage(String localId) async {
    final i = _optimistic.indexWhere((m) => m.id == localId);
    if (i < 0) return;
    final text = _optimistic[i].message;
    _optimistic[i] = TherapistThreadMessage.optimistic(
      id: localId,
      text: text,
      currentUserId: _optimistic[i].senderId,
      delivery: TherapistMessageDelivery.pending,
    );
    _sending = true;
    _lastError = null;
    notifyListeners();
    try {
      await _service.sendMessage(text.trim());
      _optimistic.removeWhere((m) => m.id == localId);
      await refreshMessages(signalNewTherapistReply: false);
    } on ApiException catch (e) {
      _lastError = e.message;
      _markOptimisticFailed(localId);
    } catch (_) {
      _lastError = 'Your message could not be sent. Check your connection.';
      _markOptimisticFailed(localId);
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
