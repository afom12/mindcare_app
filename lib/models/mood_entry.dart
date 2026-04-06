class MoodEntry {
  MoodEntry({
    required this.id,
    required this.label,
    required this.emoji,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String label;
  final String emoji;
  final DateTime createdAt;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        if (note != null && note!.isNotEmpty) 'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }
}
