import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'pending_auth_redirect.dart';

/// Setelah login/register: buka rute yang ditunda (deep link / notifikasi) atau home.
Future<void> navigateAfterSuccessfulAuth(GoRouter router) async {
  final pending = await PendingAuthRedirect.take();
  if (pending != null) {
    final loc = pending.location.trim();
    final ex = pending.extra;
    router.go(loc, extra: ex);
    final beritaDetail = loc == '/berita/detail' || loc.endsWith('/berita/detail');
    final agendaDetail = loc == '/agenda/detail' || loc.endsWith('/agenda/detail');
    final amalDetail =
        loc == '/amal-usaha/detail' || loc.endsWith('/amal-usaha/detail');
    if (beritaDetail || agendaDetail || amalDetail) {
      if (ex is Map) {
        final slug = ex['slug'];
        if (slug is String && slug.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final path = beritaDetail
                ? '/berita/detail'
                : agendaDetail
                    ? '/agenda/detail'
                    : '/amal-usaha/detail';
            router.go(path, extra: {'slug': slug});
          });
        }
      }
    }
    return;
  }
  router.go('/');
}
