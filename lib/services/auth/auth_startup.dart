import 'auth_api_service.dart';
import 'auth_local_service.dart';

/// Dipanggil **setelah** UI sudah tampil (mis. dari `initState`).
/// Mengembalikan rute redirect (`'/login'`) jika sesi harus dibatalkan, atau `null` jika aman.
Future<String?> tryRefreshTokenInBackground() async {
  final local = AuthLocalService();

  final loggedIn = await local.isLoggedIn();
  if (!loggedIn) return null;

  final token = await local.getToken();
  final trimmed = token?.trim() ?? '';
  if (trimmed.length < 36) return null;

  final result = await AuthApiService().refreshToken(token: trimmed);

  if (result.success && result.newToken != null && result.newToken!.isNotEmpty) {
    await local.updateStoredTokenIfDifferent(result.newToken!);
    return null;
  }

  if (result.invalidateSession) {
    await local.clearAllLocalData();
    final location = await local.resolveInitialLocation();
    return location;
  }

  return null;
}
