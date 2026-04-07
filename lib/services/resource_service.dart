import '../models/resource_item.dart';
import 'api_client.dart';

class ResourceService {
  ResourceService(this._api);

  final ApiClient _api;

  Future<List<ResourceItem>> fetchResources() async {
    final res = await _api.getJson('/resources', auth: true);
    dynamic raw = res['resources'] ?? res['data'] ?? res['items'];
    if (raw is Map && raw['resources'] is List) {
      raw = raw['resources'];
    }
    if (raw is! List) {
      return [];
    }
    return raw
        .whereType<Map>()
        .map((e) => ResourceItem.fromJson(Map<String, dynamic>.from(e)))
        .where((r) => r.id.isNotEmpty || r.title.isNotEmpty)
        .toList();
  }
}
