import 'api_client.dart';
import 'api_exception.dart';

class ChatService {
  ChatService(this._api);

  final ApiClient _api;

  String? _extractReply(Map<String, dynamic> json) {
    final direct = json['reply'] ??
        json['message'] ??
        json['response'] ??
        json['content'] ??
        json['answer'] ??
        json['text'];
    if (direct is String && direct.trim().isNotEmpty) return direct.trim();
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final inner = data['reply'] ?? data['message'] ?? data['response'] ?? data['content'];
      if (inner is String && inner.trim().isNotEmpty) return inner.trim();
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  Future<String> sendMessage(String message) async {
    final res = await _api.postJson(
      '/ai/chat',
      {'message': message},
      auth: true,
    );
    final reply = _extractReply(res);
    if (reply == null) {
      throw ApiException('The assistant replied, but we could not read the response.');
    }
    return reply;
  }
}
