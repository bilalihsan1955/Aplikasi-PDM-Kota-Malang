import '../../models/auth_user_model.dart';

class AuthProfileUpdateResult {
  final bool success;
  final String message;
  final AuthUser? user;
  final Map<String, List<String>>? errors;

  const AuthProfileUpdateResult({
    required this.success,
    required this.message,
    this.user,
    this.errors,
  });

  factory AuthProfileUpdateResult.success({
    required String message,
    AuthUser? user,
  }) {
    return AuthProfileUpdateResult(
      success: true,
      message: message,
      user: user,
    );
  }

  factory AuthProfileUpdateResult.failure({
    required String message,
    Map<String, List<String>>? errors,
  }) {
    return AuthProfileUpdateResult(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
