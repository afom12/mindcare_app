import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PIN (hashed), privacy toggles. Chat preview hiding uses SharedPreferences.
class PrivacyService {
  PrivacyService() : _secure = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _secure;

  static const _pinHashKey = 'mindcare_pin_sha256';
  static const _hidePreviewsKey = 'mindcare_hide_chat_previews';
  static const _notifEnabledKey = 'mindcare_daily_notif_enabled';

  Future<bool> hasPin() async {
    final h = await _secure.read(key: _pinHashKey);
    return h != null && h.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final hash = _hash(pin);
    await _secure.write(key: _pinHashKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _pinHashKey);
    if (stored == null) return false;
    return stored == _hash(pin);
  }

  Future<void> clearPin() async {
    await _secure.delete(key: _pinHashKey);
  }

  String _hash(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> get hideChatPreviews async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_hidePreviewsKey) ?? false;
  }

  Future<void> setHideChatPreviews(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_hidePreviewsKey, v);
  }

  Future<bool> get dailyReminderEnabled async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_notifEnabledKey) ?? true;
  }

  Future<void> setDailyReminderEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifEnabledKey, v);
  }
}
