// Memasang User-Agent aplikasi untuk seluruh `HttpClient` dart:io (Image.network,
// cached_network_image, flutter_widget_from_html, flutter_map). No-op di web.
export 'app_http_overrides_stub.dart'
    if (dart.library.io) 'app_http_overrides_io.dart';
