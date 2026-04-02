import '../../models/auth_user_model.dart';

class AuthRegisterResult {
  final bool success;
  final String message;
  final AuthUser? user;
  final String? token;
  final Map<String, List<String>>? errors;

  const AuthRegisterResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });

  factory AuthRegisterResult.success({
    required String message,
    required AuthUser user,
    required String token,
  }) {
    return AuthRegisterResult(
      success: true,
      message: message,
      user: user,
      token: token,
    );
  }

  factory AuthRegisterResult.failure({
    required String message,
    Map<String, List<String>>? errors,
  }) {
    return AuthRegisterResult(
      success: false,
      message: message,
      errors: errors,
    );
  }
}

