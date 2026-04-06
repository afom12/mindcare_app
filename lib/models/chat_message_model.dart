enum ChatRole { user, assistant }

class ChatMessageModel {
  ChatMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.pending = false,
    this.failed = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final bool pending;
  final bool failed;

  ChatMessageModel copyWith({
    String? text,
    bool? pending,
    bool? failed,
  }) {
    return ChatMessageModel(
      id: id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }
}
