import 'user_model.dart';

class AuthResult {
  const AuthResult({
    required this.token,
    this.user,
  });

  final String token;
  final UserModel? user;
}
