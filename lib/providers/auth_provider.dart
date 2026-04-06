import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/auth_result.dart';
import '../models/user_model.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._authService,
    this._storage,
  );

  final AuthService _authService;
  final SecureStorageService _storage;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get lastError => _error;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> bootstrap() async {
    _error = null;
    final token = await _storage.readToken();
    final userJson = await _storage.readUserJson();
    if (token != null && token.isNotEmpty) {
      _user = _authService.userFromStoredJson(userJson);
      _status = AuthStatus.authenticated;
    } else {
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _error = null;
    try {
      final result = await _authService.login(email: email, password: password);
      await _persistSession(result, fallbackEmail: email);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _error = null;
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      await _persistSession(result, fallbackEmail: email, fallbackName: name);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    }
  }

  Future<void> _persistSession(
    AuthResult result, {
    String? fallbackEmail,
    String? fallbackName,
  }) async {
    await _storage.writeToken(result.token);
    UserModel? u = result.user;
    final email = (u?.email.isNotEmpty == true) ? u!.email : (fallbackEmail ?? '');
    final id = u?.id.isNotEmpty == true ? u!.id : 'session';
    final name = u?.name ?? fallbackName;
    _user = UserModel(id: id, email: email.isNotEmpty ? email : 'you@mindcare.app', name: name);
    await _storage.writeUserJson(jsonEncode(_user!.toJson()));
  }

  Future<void> updateLocalName(String name) async {
    if (_user == null) return;
    final next = _user!.copyWith(name: name);
    _user = next;
    await _storage.writeUserJson(jsonEncode(next.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
