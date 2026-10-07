/// Pemetaan terpusat untuk pesan kesalahan jaringan & API menjadi teks ramah pengguna.
class NetworkErrorMapper {
  /// Mengubah pesan error mentah (exception / API message) menjadi pesan yang ramah pengguna.
  static String toFriendly(String raw, {String fallbackContext = 'data'}) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('unreachable') ||
        lower.contains('timeout') ||
        lower.contains('timed out') ||
        lower.contains('no internet') ||
        lower.contains('failed host lookup')) {
      return 'Koneksi internet tidak stabil.\nPeriksa jaringan Anda dan coba lagi.';
    }
    if (lower.contains('404') || lower.contains('not found')) {
      return 'Data tidak ditemukan.\nSilakan coba lagi nanti.';
    }
    if (lower.contains('500') || lower.contains('internal server')) {
      return 'Server sedang bermasalah.\nSilakan coba beberapa saat lagi.';
    }
    if (lower.contains('403') ||
        lower.contains('forbidden') ||
        lower.contains('unauthorized')) {
      return 'Akses ditolak.\nSilakan login ulang atau hubungi admin.';
    }
    if (raw.isEmpty) return 'Gagal memuat $fallbackContext.\nSilakan coba lagi.';
    return 'Terjadi kesalahan.\nSilakan coba lagi nanti.';
  }
}
