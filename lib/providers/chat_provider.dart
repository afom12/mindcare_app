import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../services/api_exception.dart';
import '../services/chat_local_store.dart';
import '../services/chat_service.dart';
import '../services/greeting_catalog.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(
    this._chatService,
    this._localStore,
    this._greetings,
  );

  final ChatService _chatService;
  final ChatLocalStore _localStore;
  final GreetingCatalog _greetings;

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  bool _typing = false;
  bool get isTyping => _typing;

  String? _error;
  String? get error => _error;

  /// Load cached messages or seed a warm greeting (offline-first).
  Future<void> loadPersisted() async {
    final cached = await _localStore.load();
    if (cached.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(cached);
      notifyListeners();
      return;
    }
    await _appendWelcomeIfEmpty();
  }

  Future<void> _appendWelcomeIfEmpty() async {
    if (_messages.isNotEmpty) return;
    final text = await _greetings.nextAssistantGreeting();
    _messages.add(
      ChatMessageModel(
        id: _genId(),
        role: ChatRole.assistant,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    await _localStore.save(_messages);
  }

  Future<void> clearConversation() async {
    _messages.clear();
    _error = null;
    await _localStore.clear();
    await _appendWelcomeIfEmpty();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _error = null;
    final userMsg = ChatMessageModel(
      id: _genId(),
      role: ChatRole.user,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    _messages.add(userMsg);
    await _persist();
    notifyListeners();

    _typing = true;
    notifyListeners();

    final placeholder = ChatMessageModel(
      id: _genId(),
      role: ChatRole.assistant,
      text: '',
      createdAt: DateTime.now(),
      pending: true,
    );
    _messages.add(placeholder);
    notifyListeners();

    try {
      final reply = await _chatService.sendMessage(trimmed);
      final idx = _messages.indexWhere((m) => m.id == placeholder.id);
      if (idx >= 0) {
        _messages[idx] = ChatMessageModel(
          id: placeholder.id,
          role: ChatRole.assistant,
          text: reply,
          createdAt: DateTime.now(),
        );
      }
      await _persist();
    } on ApiException catch (e) {
      final idx = _messages.indexWhere((m) => m.id == placeholder.id);
      if (idx >= 0) {
        _messages[idx] = ChatMessageModel(
          id: placeholder.id,
          role: ChatRole.assistant,
          text:
              'I could not reach the assistant just now. ${e.message} Your words are still saved here offline.',
          createdAt: DateTime.now(),
          failed: true,
        );
      }
      _error = e.message;
      await _persist();
    } catch (e) {
      final idx = _messages.indexWhere((m) => m.id == placeholder.id);
      if (idx >= 0) {
        _messages[idx] = ChatMessageModel(
          id: placeholder.id,
          role: ChatRole.assistant,
          text:
              'Something went wrong. Take a breath — we will be ready when you try again. Your last message is saved.',
          createdAt: DateTime.now(),
          failed: true,
        );
      }
      await _persist();
    } finally {
      _typing = false;
      notifyListeners();
    }
  }

  String _genId() => '${DateTime.now().microsecondsSinceEpoch}-${_messages.length}';
}
