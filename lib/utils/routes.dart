import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view/main_screen.dart';
import '../view/pages/home_page.dart';
import '../view/pages/agenda/agenda_page.dart';
import '../view/pages/berita/berita_page.dart';
import '../view/pages/profile_page.dart';
import '../view/pages/berita/detail_berita_page.dart';
import '../view/pages/agenda/detail_agenda_page.dart';
import '../view/pages/about_pdm_page.dart';
import '../view/pages/gallery_page.dart';
import '../view/pages/auth/onboarding_page.dart';
import '../view/pages/auth/login_page.dart';
import '../view/pages/auth/register_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    // Auth Routes
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    // App Shell Routes
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
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const AboutPdmPage(),
                ),
                GoRoute(
                  path: 'gallery',
                  pageBuilder: (context, state) => const NoTransitionPage(child: GalleryPage()),
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
                  pageBuilder: (context, state) => const NoTransitionPage(child: DetailAgendaPage()),
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
                  pageBuilder: (context, state) => const NoTransitionPage(child: DetailBeritaPage()),
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
            ),
          ],
        ),
      ],
    ),
  ],
);
