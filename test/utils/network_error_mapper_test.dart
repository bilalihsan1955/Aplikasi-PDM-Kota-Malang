import 'package:flutter_test/flutter_test.dart';
import 'package:pdm_malang/utils/network_error_mapper.dart';

void main() {
  group('NetworkErrorMapper Tests', () {
    test('maps connection and socket errors correctly', () {
      expect(
        NetworkErrorMapper.toFriendly('SocketException: OS Error: Connection refused'),
        contains('Koneksi internet tidak stabil'),
      );
      expect(
        NetworkErrorMapper.toFriendly('ClientException: Software caused connection abort'),
        contains('Koneksi internet tidak stabil'),
      );
      expect(
        NetworkErrorMapper.toFriendly('Failed host lookup: makotamu.org'),
        contains('Koneksi internet tidak stabil'),
      );
    });

    test('maps 404 not found errors', () {
      expect(
        NetworkErrorMapper.toFriendly('Status 404: Not Found'),
        contains('Data tidak ditemukan'),
      );
    });

    test('maps 500 server errors', () {
      expect(
        NetworkErrorMapper.toFriendly('Status 500: Internal Server Error'),
        contains('Server sedang bermasalah'),
      );
    });

    test('maps 403 / unauthorized access errors', () {
      expect(
        NetworkErrorMapper.toFriendly('Status 403: Forbidden'),
        contains('Akses ditolak'),
      );
    });

    test('handles empty and generic errors with fallback context', () {
      expect(
        NetworkErrorMapper.toFriendly('', fallbackContext: 'berita'),
        equals('Gagal memuat berita.\nSilakan coba lagi.'),
      );
      expect(
        NetworkErrorMapper.toFriendly('Unknown runtime error', fallbackContext: 'berita'),
        equals('Terjadi kesalahan.\nSilakan coba lagi nanti.'),
      );
    });
  });
}
