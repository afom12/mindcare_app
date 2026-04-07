import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which therapist reply the user has seen in-app vs which we already surfaced in a snackbar.
class TherapistInboxPrefs {
  static const _seenKey = 'mindcare_therapist_seen_msg_id_v1';
  static const _promptedKey = 'mindcare_therapist_prompted_msg_id_v1';

  Future<String?> readSeenMessageId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_seenKey);
  }

  Future<String?> readPromptedMessageId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_promptedKey);
  }

  Future<void> writeSeenMessageId(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_seenKey, id);
  }

  Future<void> writePromptedMessageId(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_promptedKey, id);
  }

  /// First-time bootstrap: no snackbar; align cursors to the latest server message id.
  Future<void> bootstrapCursors(String latestTherapistMessageId) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_seenKey, latestTherapistMessageId);
    await p.setString(_promptedKey, latestTherapistMessageId);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_seenKey);
    await p.remove(_promptedKey);
  }
}
