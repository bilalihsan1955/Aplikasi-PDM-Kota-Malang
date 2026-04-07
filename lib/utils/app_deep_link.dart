import '../services/api_service.dart';

/// Hasil parsing URL web → [destination] GoRouter + [extra] (mis. `slug`).
class AppDeepLinkTarget {
  const AppDeepLinkTarget({required this.destination, required this.extra});

  final String destination;
  final Map<String, dynamic> extra;
}

bool _hostMatchesConfiguredWeb(Uri uri) {
  final got = uri.host.toLowerCase();
  if (got == 'makotamu.org' || got == 'www.makotamu.org') return true;

  final expected = Uri.tryParse(ApiService.webBaseUrl);
  if (expected == null || expected.host.isEmpty) return true;
  final want = expected.host.toLowerCase();
  if (want == 'makotamu.org') return true;
  if (got == want) return true;
  if (got == 'www.$want' || want == 'www.$got') return true;
  return false;
}

/// Mengenali path situs: berita/artikel, agenda/kegiatan, amal-usaha → rute detail app.
AppDeepLinkTarget? tryAppDeepLinkFromUri(Uri? uri) {
  if (uri == null) return null;

  final pathOnly =
      uri.host.isEmpty && uri.hasAbsolutePath && uri.pathSegments.isNotEmpty;
  if (!pathOnly) {
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    if (!_hostMatchesConfiguredWeb(uri)) return null;
  }

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length < 2) return null;

  final section = segments.first.toLowerCase();
  final slug = segments[1];
  if (slug.isEmpty) return null;
  if (slug.toLowerCase() == 'detail') return null;

  final String? destination;
  if (section == 'berita' || section == 'artikel') {
    destination = '/berita/detail';
  } else if (section == 'agenda' || section == 'kegiatan') {
    destination = '/agenda/detail';
  } else if (section == 'amal-usaha') {
    destination = '/amal-usaha/detail';
  } else {
    destination = null;
  }
  if (destination == null) return null;

  return AppDeepLinkTarget(
    destination: destination,
    extra: {'slug': slug},
  );
}
