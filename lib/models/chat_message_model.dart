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

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'pending': pending,
        'failed': failed,
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      role: ChatRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ChatRole.user,
      ),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      pending: json['pending'] as bool? ?? false,
      failed: json['failed'] as bool? ?? false,
    );
  }

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
