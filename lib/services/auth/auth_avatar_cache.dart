import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Unduh avatar ke disk cache agar [CachedNetworkImage] di [UserAvatar] tampil dari cache.
void prefetchAuthAvatarUrl(String? url) {
  if (url == null || url.trim().isEmpty) return;
  final u = url.trim();
  final lower = u.toLowerCase();
  if (!lower.startsWith('http://') && !lower.startsWith('https://')) return;
  DefaultCacheManager().downloadFile(u).then((_) {}).catchError((_, __) {});
}
