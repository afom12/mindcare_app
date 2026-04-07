import '../core/constants/api_constants.dart';
import '../models/therapist_models.dart';
import 'api_client.dart';

/// Student-side therapist APIs — isolated from [ChatService] (AI).
class TherapistService {
  TherapistService(this._api);

  final ApiClient _api;

  String get _p => ApiConstants.therapistPathPrefix;

  Future<void> requestSupport() async {
    await _api.postJson('$_p/request', {}, auth: true);
  }

  Future<TherapistConnectionState> fetchStatus() async {
    final res = await _api.getJson('$_p/status', auth: true);
    final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;
    return TherapistConnectionState.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<TherapistThreadMessage>> fetchMessages({required String currentUserId}) async {
    final res = await _api.getJson('$_p/messages', auth: true);
    dynamic list = res['messages'] ?? res['data'];
    if (list is Map && list['messages'] is List) {
      list = list['messages'];
    }
    if (list is! List) {
      return [];
    }
    return list
        .whereType<Map>()
        .map((e) => TherapistThreadMessage.fromJson(
              Map<String, dynamic>.from(e),
              currentUserId: currentUserId,
            ))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> sendMessage(String text) async {
    final body = <String, dynamic>{'message': text};
    await _api.postJson('$_p/messages', body, auth: true);
  }
}
