class AuthRefreshResult {
  final bool success;
  final String message;
  final String? newToken;

  /// Jika true, refresh ditolak server (mis. token kedaluwarsa); sesi lokal harus dibersihkan.
  final bool invalidateSession;

  const AuthRefreshResult({
    required this.success,
    required this.message,
    this.newToken,
    this.invalidateSession = false,
  });

  factory AuthRefreshResult.ok({
    required String message,
    required String newToken,
  }) =>
      AuthRefreshResult(
        success: true,
        message: message,
        newToken: newToken,
      );

  factory AuthRefreshResult.fail({
    required String message,
    bool invalidateSession = false,
  }) =>
      AuthRefreshResult(
        success: false,
        message: message,
        invalidateSession: invalidateSession,
      );
}
