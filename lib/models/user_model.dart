class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: json['name'] as String? ?? json['fullName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (name != null) 'name': name,
      };

  UserModel copyWith({String? name}) =>
      UserModel(id: id, email: email, name: name ?? this.name);
}
