import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message_model.dart';

/// Persists the last [maxMessages] chat messages for offline continuity.
class ChatLocalStore {
  ChatLocalStore({this.maxMessages = 10});

  static const _key = 'mindcare_chat_cache_v1';
  final int maxMessages;

  Future<List<ChatMessageModel>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((m) => !m.pending)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ChatMessageModel> messages) async {
    final p = await SharedPreferences.getInstance();
    final persistable = messages.where((m) => !m.pending).toList();
    final tail = persistable.length <= maxMessages
        ? persistable
        : persistable.sublist(persistable.length - maxMessages);
    final encoded = jsonEncode(tail.map((m) => m.toJson()).toList());
    await p.setString(_key, encoded);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
