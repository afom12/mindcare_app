/// Public therapist row for browsing / booking (`GET /therapists`).
class TherapistListing {
  TherapistListing({
    required this.id,
    required this.name,
    this.title,
    this.bio,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? title;
  final String? bio;
  final String? avatarUrl;

  factory TherapistListing.fromJson(Map<String, dynamic> json) {
    return TherapistListing(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? 'Therapist').toString(),
      title: json['title'] as String? ?? json['credentials'] as String?,
      bio: json['bio'] as String? ?? json['about'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['photo'] as String?,
    );
  }
}
