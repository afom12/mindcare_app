import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import 'api_exception.dart';
import 'secure_storage_service.dart';

class ApiClient {
  ApiClient(this._storage);

  final SecureStorageService _storage;

  /// Called when a request used [auth] and the server returned 401.
  /// Use to clear session and navigate to login (avoid for unauthenticated calls).
  void Function()? onUnauthorized;

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool auth = false,
    Map<String, String>? queryParameters,
  }) async {
    final client = http.Client();
    try {
      var uri = _uri(path);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }
      final response = await client
          .get(
            uri,
            headers: await _headers(auth: auth),
          )
          .timeout(ApiConstants.receiveTimeout);

      return _decode(response, usedAuth: auth);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'We could not reach the server. Check your connection and that the API is running.',
      );
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final client = http.Client();
    try {
      final response = await client
          .post(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.receiveTimeout);

      return _decode(response, usedAuth: auth);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'We could not reach the server. Check your connection and that the API is running.',
      );
    } finally {
      client.close();
    }
  }

  Map<String, dynamic> _decode(http.Response response, {required bool usedAuth}) {
    final raw = response.body;
    Map<String, dynamic>? jsonBody;
    if (raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          jsonBody = decoded;
        }
      } catch (_) {
        /* non-json */
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody ?? <String, dynamic>{};
    }

    if (response.statusCode == 401 && usedAuth) {
      onUnauthorized?.call();
    }

    final message = _extractError(jsonBody) ??
        (raw.isNotEmpty ? raw : 'Something went wrong (${response.statusCode}).');
    throw ApiException(message, statusCode: response.statusCode);
  }

  String? _extractError(Map<String, dynamic>? jsonBody) {
    if (jsonBody == null) return null;
    final err = jsonBody['error'];
    if (err is String) return err;
    final msg = jsonBody['message'];
    if (msg is String) return msg;
    final detail = jsonBody['detail'];
    if (detail is String) return detail;
    final errors = jsonBody['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    return null;
  }
}
