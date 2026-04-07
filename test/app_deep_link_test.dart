import 'package:flutter_test/flutter_test.dart';
import 'package:pdm_malang/utils/app_deep_link.dart';

void main() {
  test('parses makotamu.org berita URL to slug', () {
    final uri = Uri.parse(
      'https://makotamu.org/berita/takbiran-dan-nyepi-2026-berbarengan-muhammadiyah-bali-serukan-semangat-toleransi-dan-ketertiban-00E79',
    );
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/berita/detail');
    expect(t.extra['slug'], contains('takbiran-dan-nyepi'));
    expect(t.extra['slug'], endsWith('00E79'));
  });

  test('parses path-only /berita/slug (href relatif di HTML)', () {
    final uri = Uri.parse('/berita/artikel-slug-test');
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/berita/detail');
    expect(t.extra['slug'], 'artikel-slug-test');
  });

  test('parses HTTPS /agenda/slug ke detail agenda', () {
    final uri = Uri.parse('https://makotamu.org/agenda/acara-nasional-2026');
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/agenda/detail');
    expect(t.extra['slug'], 'acara-nasional-2026');
  });

  test('parses path-only /agenda/slug', () {
    final uri = Uri.parse('/agenda/event-slug');
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/agenda/detail');
    expect(t.extra['slug'], 'event-slug');
  });

  test('parses /kegiatan/slug (URL publik situs makotamu) ke detail agenda', () {
    final uri = Uri.parse(
      'https://makotamu.org/kegiatan/undangan-kajian-ramadhan-pdm-kota-malang-aMWUU',
    );
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/agenda/detail');
    expect(t.extra['slug'], 'undangan-kajian-ramadhan-pdm-kota-malang-aMWUU');
  });

  test('parses path-only /kegiatan/slug', () {
    final uri = Uri.parse('/kegiatan/acara-lokal');
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/agenda/detail');
    expect(t.extra['slug'], 'acara-lokal');
  });

  test('parses /amal-usaha/slug ke detail amal usaha', () {
    final uri = Uri.parse('https://makotamu.org/amal-usaha/lazismu-kota-malang');
    final t = tryAppDeepLinkFromUri(uri);
    expect(t, isNotNull);
    expect(t!.destination, '/amal-usaha/detail');
    expect(t.extra['slug'], 'lazismu-kota-malang');
  });
}
