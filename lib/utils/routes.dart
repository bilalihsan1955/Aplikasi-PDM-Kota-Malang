import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view/main_screen.dart';
import '../view/pages/home_page.dart';
import '../view/pages/agenda/agenda_page.dart';
import '../view/pages/berita/berita_page.dart';
import '../view/pages/profile/profile_page.dart';
import '../view/pages/berita/detail_berita_page.dart';
import '../models/news_model.dart';
import '../view/pages/agenda/detail_agenda_page.dart';
import '../models/agenda_model.dart';
import '../view/pages/about_pdm_page.dart';
import '../view/pages/gallery_page.dart';
import '../view/pages/profile/account_page.dart';
import '../view/pages/auth/onboarding_page.dart';
import '../view/pages/auth/login_page.dart';
import '../view/pages/auth/register_page.dart';
import '../view/pages/notification_page.dart';
import '../view/pages/menu_list_page.dart';
import '../view/pages/empty_placeholder_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    // Auth Routes - Full Screen
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => const NoTransitionPage(child: OnboardingPage()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => const NoTransitionPage(child: RegisterPage()),
    ),
    GoRoute(
      path: '/placeholder',
      pageBuilder: (context, state) {
        final title = state.extra is String ? state.extra as String : 'Halaman';
        return NoTransitionPage(child: EmptyPlaceholderPage(title: title));
      },
    ),

    // App Shell Routes - With Navbar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
              routes: [
                GoRoute(
                  path: 'about-pdm',
                  pageBuilder: (context, state) => const NoTransitionPage(child: AboutPdmPage()),
                ),
                GoRoute(
                  path: 'gallery',
                  pageBuilder: (context, state) => const NoTransitionPage(child: GalleryPage()),
                ),
                GoRoute(
                  path: 'notifications',
                  pageBuilder: (context, state) => const NoTransitionPage(child: NotificationPage()),
                ),
                GoRoute(
                  path: 'menu',
                  pageBuilder: (context, state) => const NoTransitionPage(child: MenuListPage()),
                ),
              ],
            ),
          ],
        ),
        // Tab 1: Agenda
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agenda',
              pageBuilder: (context, state) => const NoTransitionPage(child: AgendaPage()),
              routes: [
                GoRoute(
                  path: 'detail',
                  pageBuilder: (context, state) {
                    String? slug;
                    AgendaModel? initialAgenda;
                    final ex = state.extra;
                    if (ex is Map) {
                      slug = ex['slug'] is String ? ex['slug'] as String : null;
                      initialAgenda = ex['agenda'] is AgendaModel ? ex['agenda'] as AgendaModel : null;
                    } else if (ex is String) {
                      slug = ex;
                    }
                    return NoTransitionPage(
                      child: DetailAgendaPage(slug: slug, initialAgenda: initialAgenda),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Berita
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/berita',
              pageBuilder: (context, state) => const NoTransitionPage(child: BeritaPage()),
              routes: [
                GoRoute(
                  path: 'detail',
                  pageBuilder: (context, state) {
                    String? slug;
                    NewsModel? initialNews;
                    final ex = state.extra;
                    if (ex is Map) {
                      slug = ex['slug'] is String ? ex['slug'] as String : null;
                      initialNews = ex['news'] is NewsModel ? ex['news'] as NewsModel : null;
                    } else if (ex is String) {
                      slug = ex;
                    }
                    return NoTransitionPage(
                      child: DetailBeritaPage(slug: slug, initialNews: initialNews),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
              routes: [
                GoRoute(
                  path: 'account',
                  pageBuilder: (context, state) => const NoTransitionPage(child: AccountPage()),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
