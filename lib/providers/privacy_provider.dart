import 'package:flutter/foundation.dart';

import '../services/privacy_service.dart';

class PrivacyProvider extends ChangeNotifier {
  PrivacyProvider(this._privacy);

  final PrivacyService _privacy;

  bool _hasPin = false;
  bool _hidePreviews = false;
  bool _sessionUnlocked = true;
  bool _dailyReminder = true;
  DateTime? _pausedAt;

  bool get hasPin => _hasPin;
  bool get hideChatPreviews => _hidePreviews;
  bool get sessionUnlocked => _sessionUnlocked;
  bool get shouldShowLock => _hasPin && !_sessionUnlocked;
  bool get dailyReminderEnabled => _dailyReminder;

  Future<void> bootstrap() async {
    _hasPin = await _privacy.hasPin();
    _hidePreviews = await _privacy.hideChatPreviews;
    _dailyReminder = await _privacy.dailyReminderEnabled;
    _sessionUnlocked = !_hasPin;
    notifyListeners();
  }

  void lockSession() {
    if (!_hasPin) return;
    _sessionUnlocked = false;
    notifyListeners();
  }

  Future<bool> tryUnlock(String pin) async {
    final ok = await _privacy.verifyPin(pin);
    if (ok) {
      _sessionUnlocked = true;
      notifyListeners();
    }
    return ok;
  }

  Future<void> setNewPin(String pin) async {
    await _privacy.setPin(pin);
    _hasPin = true;
    _sessionUnlocked = true;
    notifyListeners();
  }

  Future<void> removePin() async {
    await _privacy.clearPin();
    _hasPin = false;
    _sessionUnlocked = true;
    notifyListeners();
  }

  Future<void> setHidePreviews(bool v) async {
    await _privacy.setHideChatPreviews(v);
    _hidePreviews = v;
    notifyListeners();
  }

  Future<void> setDailyReminderEnabled(bool v) async {
    await _privacy.setDailyReminderEnabled(v);
    _dailyReminder = v;
    notifyListeners();
  }

  void markPaused() {
    _pausedAt = DateTime.now();
  }

  void maybeLockAfterResume() {
    if (!_hasPin || !_sessionUnlocked) return;
    final p = _pausedAt;
    if (p == null) return;
    final diff = DateTime.now().difference(p);
    if (diff.inSeconds >= 4) {
      lockSession();
    }
    _pausedAt = null;
  }
}
