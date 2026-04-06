import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../services/api_exception.dart';
import '../services/chat_service.dart';

// Lightweight unique ids without adding uuid package — use timestamp + counter.
// Actually I used uuid in import - remove uuid package. Use UniqueKey or random.
// I'll use simple id: DateTime.now().microsecondsSinceEpoch.toString()

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._chatService);

  final ChatService _chatService;

  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  bool _typing = false;
  bool get isTyping => _typing;

  String? _error;
  String? get error => _error;

  void addWelcomeIfEmpty() {
    if (_messages.isNotEmpty) return;
    _messages.add(
      ChatMessageModel(
        id: _genId(),
        role: ChatRole.assistant,
        text:
            'Hi — I am here to listen. Share what is on your mind, at your own pace.',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void clearConversation() {
    _messages.clear();
    _error = null;
    addWelcomeIfEmpty();
    notifyListeners();
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
    } on ApiException catch (e) {
      final idx = _messages.indexWhere((m) => m.id == placeholder.id);
      if (idx >= 0) {
        _messages[idx] = ChatMessageModel(
          id: placeholder.id,
          role: ChatRole.assistant,
          text:
              'I could not reach the assistant just now. ${e.message} You can try again in a moment.',
          createdAt: DateTime.now(),
          failed: true,
        );
      }
      _error = e.message;
    } catch (e) {
      final idx = _messages.indexWhere((m) => m.id == placeholder.id);
      if (idx >= 0) {
        _messages[idx] = ChatMessageModel(
          id: placeholder.id,
          role: ChatRole.assistant,
          text:
              'Something went wrong. Take a breath — we will be ready when you try again.',
          createdAt: DateTime.now(),
          failed: true,
        );
      }
    } finally {
      _typing = false;
      notifyListeners();
    }
  }

  String _genId() => '${DateTime.now().microsecondsSinceEpoch}-${_messages.length}';
}
