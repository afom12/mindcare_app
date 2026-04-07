/// Generic learning / crisis resource row from `GET /resources`.
class ResourceItem {
  ResourceItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.url,
    this.category,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? url;
  final String? category;

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: (json['id'] ?? json['_id'] ?? json['slug'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Resource').toString(),
      subtitle: json['subtitle'] as String? ?? json['description'] as String?,
      url: json['url'] as String? ?? json['link'] as String?,
      category: json['category'] as String? ?? json['type'] as String?,
    );
  }
}
