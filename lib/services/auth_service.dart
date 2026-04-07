import 'dart:convert';

import '../models/auth_result.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'api_exception.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  String? _extractToken(Map<String, dynamic> json) {
    final direct = json['token'] ?? json['access_token'] ?? json['accessToken'] ?? json['jwt'];
    if (direct is String && direct.isNotEmpty) return direct;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final t = data['token'] ?? data['access_token'] ?? data['accessToken'];
      if (t is String && t.isNotEmpty) return t;
    }
    return null;
  }

  UserModel? _extractUser(Map<String, dynamic> json) {
    final u = json['user'] ?? json['profile'] ?? json['data'];
    if (u is Map<String, dynamic>) {
      try {
        return UserModel.fromJson(u);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _api.postJson('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    final token = _extractToken(res);
    if (token == null || token.isEmpty) {
      throw ApiException('Registration succeeded but no token was returned.');
    }
    return AuthResult(token: token, user: _extractUser(res));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.postJson(
      '/auth/change-password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      auth: true,
    );
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    final token = _extractToken(res);
    if (token == null || token.isEmpty) {
      throw ApiException('Login succeeded but no token was returned.');
    }
    return AuthResult(token: token, user: _extractUser(res));
  }

  UserModel? userFromStoredJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
