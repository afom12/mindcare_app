import '../models/mood_entry.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Optional `/mood` sync — if the route is missing, callers should fall back to local storage.
class MoodService {
  MoodService(this._api);

  final ApiClient _api;

  Future<List<MoodEntry>> fetchEntries() async {
    final res = await _api.getJson('/mood', auth: true);
    dynamic raw = res['entries'] ?? res['data'] ?? res['moods'] ?? res['items'];
    if (raw is Map && raw['entries'] is List) {
      raw = raw['entries'];
    }
    if (raw is! List) {
      return [];
    }
    final out = <MoodEntry>[];
    for (final e in raw) {
      if (e is Map) {
        final parsed = _tryParseEntry(Map<String, dynamic>.from(e));
        if (parsed != null) out.add(parsed);
      }
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  Future<void> createEntry(MoodEntry entry) async {
    await _api.postJson(
      '/mood',
      {
        'label': entry.label,
        'emoji': entry.emoji,
        'note': entry.note,
        'createdAt': entry.createdAt.toIso8601String(),
      },
      auth: true,
    );
  }

  /// Returns null if the endpoint is not implemented (404) or request fails softly.
  Future<List<MoodEntry>?> tryFetchEntries() async {
    try {
      return await fetchEntries();
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) return null;
      return null;
    } catch (_) {
      return null;
    }
  }

  MoodEntry? _tryParseEntry(Map<String, dynamic> json) {
    try {
      final id = (json['id'] ?? json['_id'] ?? '').toString();
      final label = (json['label'] ?? json['mood'] ?? '').toString();
      final emoji = (json['emoji'] ?? json['icon'] ?? '🙂').toString();
      final note = json['note'] as String?;
      final ts = json['createdAt'] ?? json['created_at'] ?? json['date'];
      final created = ts is String
          ? (DateTime.tryParse(ts) ?? DateTime.now())
          : DateTime.now();
      if (label.isEmpty) return null;
      return MoodEntry(
        id: id.isNotEmpty ? id : created.microsecondsSinceEpoch.toString(),
        label: label,
        emoji: emoji,
        createdAt: created,
        note: note?.trim().isEmpty == true ? null : note?.trim(),
      );
    } catch (_) {
      return null;
    }
  }
}
