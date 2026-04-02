class AuthActionResult {
  final bool success;
  final String message;

  const AuthActionResult({
    required this.success,
    required this.message,
  });

  factory AuthActionResult.success(String message) =>
      AuthActionResult(success: true, message: message);

  factory AuthActionResult.failure(String message) =>
      AuthActionResult(success: false, message: message);
}

