class PasswordResetOtpSendResult {
  final bool success;
  final String message;
  final int? expiresInSeconds;

  const PasswordResetOtpSendResult._({
    required this.success,
    required this.message,
    this.expiresInSeconds,
  });

  factory PasswordResetOtpSendResult.ok({
    required String message,
    int? expiresInSeconds,
  }) {
    return PasswordResetOtpSendResult._(
      success: true,
      message: message,
      expiresInSeconds: expiresInSeconds,
    );
  }

  factory PasswordResetOtpSendResult.fail(String message) {
    return PasswordResetOtpSendResult._(success: false, message: message);
  }
}

class PasswordResetOtpVerifyResult {
  final bool success;
  final String message;
  final String? verificationToken;

  const PasswordResetOtpVerifyResult._({
    required this.success,
    required this.message,
    this.verificationToken,
  });

  factory PasswordResetOtpVerifyResult.ok({
    required String message,
    required String verificationToken,
  }) {
    return PasswordResetOtpVerifyResult._(
      success: true,
      message: message,
      verificationToken: verificationToken,
    );
  }

  factory PasswordResetOtpVerifyResult.fail(String message) {
    return PasswordResetOtpVerifyResult._(success: false, message: message);
  }
}

class PasswordResetSubmitResult {
  final bool success;
  final String message;

  const PasswordResetSubmitResult({
    required this.success,
    required this.message,
  });
}

