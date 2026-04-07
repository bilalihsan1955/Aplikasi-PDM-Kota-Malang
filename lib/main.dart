import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdm_malang/services/auth/auth_local_service.dart';
import 'package:pdm_malang/services/auth/auth_startup.dart';
import 'package:pdm_malang/services/fcm_service.dart';
import 'package:pdm_malang/utils/app_go_router.dart';
import 'package:pdm_malang/utils/app_deep_link.dart';
import 'package:pdm_malang/utils/notification_navigation.dart';
import 'package:pdm_malang/utils/pending_auth_redirect.dart';
import 'package:pdm_malang/utils/routes.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';
import 'package:pdm_malang/view_models/profile_view_model.dart';
import 'package:pdm_malang/view_models/notification_view_model.dart';
import 'package:pdm_malang/view_models/auth_view_model.dart';
import 'package:pdm_malang/utils/app_style.dart';
import 'package:pdm_malang/utils/app_timezone.dart';
import 'package:pdm_malang/firebase_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureLocalTimeZone();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FCMService.registerNotificationOpenListener();

  final authLocal = AuthLocalService();
  final loggedIn = await authLocal.isLoggedIn();
  final authLocation = await authLocal.resolveInitialLocation();

  String routerInitial = authLocation;
  Object? routerInitialExtra;

  // Cold start: App Link dulu (bukan FCM). Jika belum login, simpan tujuan → tetap onboarding/login.
  await Future<void>.delayed(const Duration(milliseconds: 200));
  final appUri = await AppLinks().getInitialLink();
  final deepFromLink = tryAppDeepLinkFromUri(appUri);

  NotificationColdStartTarget? notifTarget;
  if (deepFromLink == null) {
    final openMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (openMsg != null) {
      FCMService.markInitialLaunchMessageConsumed();
      final model = FCMService.notificationModelFromRemoteMessage(openMsg);
      notifTarget = coldStartTargetForNotification(model);
    } else {
      final localOpen = await FCMService.notificationModelFromLocalNotificationLaunch();
      if (localOpen != null) {
        notifTarget = coldStartTargetForNotification(localOpen);
      }
    }
  }

  if (deepFromLink != null) {
    if (!loggedIn) {
      await PendingAuthRedirect.save(deepFromLink.destination, deepFromLink.extra);
    } else {
      routerInitial = deepFromLink.destination;
      routerInitialExtra = deepFromLink.extra;
    }
  } else if (notifTarget != null) {
    if (!loggedIn) {
      await PendingAuthRedirect.save(notifTarget.location, notifTarget.extra);
    } else {
      routerInitial = notifTarget.location;
      routerInitialExtra = notifTarget.extra;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AgendaViewModel()),
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MyApp(
        initialLocation: routerInitial,
        initialExtra: routerInitialExtra,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialLocation;
  final Object? initialExtra;

  const MyApp({
    super.key,
    required this.initialLocation,
    this.initialExtra,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final _router = createAppRouter(
    initialLocation: widget.initialLocation,
    initialExtra: widget.initialExtra,
  );
  StreamSubscription<Uri>? _appLinksSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bindAppGoRouter(_router);
    // StatefulShellRoute kadang tidak menerapkan initialExtra; paksa go sekali.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final loc = widget.initialLocation.trim();
      final ex = widget.initialExtra;
      final beritaDetail = loc == '/berita/detail' || loc.endsWith('/berita/detail');
      final agendaDetail = loc == '/agenda/detail' || loc.endsWith('/agenda/detail');
      final amalDetail =
          loc == '/amal-usaha/detail' || loc.endsWith('/amal-usaha/detail');
      if (!beritaDetail && !agendaDetail && !amalDetail) return;
      if (ex is Map) {
        final slug = ex['slug'];
        if (slug is String && slug.isNotEmpty) {
          final path = beritaDetail
              ? '/berita/detail'
              : agendaDetail
                  ? '/agenda/detail'
                  : '/amal-usaha/detail';
          _router.go(path, extra: {'slug': slug});
        }
      }
    });
    _appLinksSubscription = AppLinks().uriLinkStream.listen((uri) async {
      if (!mounted) return;
      final target = tryAppDeepLinkFromUri(uri);
      if (target == null) return;
      final ok = await AuthLocalService().isLoggedIn();
      if (!mounted) return;
      if (!ok) {
        await PendingAuthRedirect.save(target.destination, target.extra);
        final loc = await AuthLocalService().resolveInitialLocation();
        if (!mounted) return;
        _router.go(loc);
        return;
      }
      _router.go(target.destination, extra: target.extra);
    });
    FCMService().onNotificationTapped = (notification) {
      scheduleOpenNotificationTarget(notification);
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FCMService().onNotificationReceived = (n) {
        if (!mounted) return;
        unawaited(context.read<NotificationViewModel>().applyIncomingFromPush(n));
        unawaited(_refreshNotificationInboxFromFcm());
      };
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await FCMService.deliverInitialMessageWhenReady();
      if (!mounted) return;
      FCMService().consumePendingNotificationOpen();
    });
    unawaited(_bootstrapAfterFirstFrame());
  }

  /// Urutan: Firebase (intinya), FCM + izin notifikasi hanya jika sudah login, lalu refresh sesi + sinkron token.
  Future<void> _bootstrapAfterFirstFrame() async {
    await _initFirebaseAndFcm();
    if (!mounted) return;
    await FCMService().cancelLegacyUiTestNotificationIfAny();
    if (!mounted) return;
    final pathOnly = Uri.tryParse(widget.initialLocation)?.path ?? widget.initialLocation;
    const authOnlyPaths = {'/onboarding', '/login', '/register', '/forgot-password'};
    if (!authOnlyPaths.contains(pathOnly)) {
      await _backgroundTokenRefresh();
      if (mounted) {
        await FCMService().reschedulePrayerAlarmsFromLocalCacheIfValid();
        if (mounted) {
          unawaited(context.read<HomeViewModel>().loadPrayerData());
        }
      }
    }
    if (!mounted) return;
    try {
      final inboxLoggedIn = await AuthLocalService().isLoggedIn();
      if (!mounted) return;
      if (inboxLoggedIn) {
        await context.read<NotificationViewModel>().loadNotifications(
              forceRefresh: false,
            );
      }
    } catch (e, st) {
      debugPrint('[MyApp] Prefetch notifications: $e\n$st');
    }
  }

  @override
  void dispose() {
    _appLinksSubscription?.cancel();
    _appLinksSubscription = null;
    FCMService().onNotificationTapped = null;
    unbindAppGoRouter();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(FCMService().syncRegisteredTokenToBackend());
      unawaited(FCMService().replayLastPrayerScheduleNotificationsIfAny());
      if (mounted) {
        unawaited(context.read<HomeViewModel>().refreshPrayerDataIfStaleOnResume());
      }
      if (mounted) {
        unawaited(_refreshNotificationsOnResume());
      }
    }
  }

  Future<void> _refreshNotificationsOnResume() async {
    try {
      if (!await AuthLocalService().isLoggedIn()) return;
      if (!mounted) return;
      await context.read<NotificationViewModel>().refresh();
    } catch (e, st) {
      debugPrint('[MyApp] Resume refresh notifications: $e\n$st');
    }
  }

  /// Setelah FCM (foreground / tap tray): muat ulang inbox agar titik merah navbar ikut server.
  /// Dua kali dengan jeda: backend sering menulis DB sedikit setelah push terkirim.
  Future<void> _refreshNotificationInboxFromFcm() async {
    try {
      if (!await AuthLocalService().isLoggedIn()) return;
      if (!mounted) return;
      await context.read<NotificationViewModel>().refresh();
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      if (!await AuthLocalService().isLoggedIn()) return;
      await context.read<NotificationViewModel>().refresh();
    } catch (e, st) {
      debugPrint('[MyApp] FCM refresh notifications: $e\n$st');
    }
  }

  Future<void> _initFirebaseAndFcm() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        FCMService.registerNotificationOpenListener();
      }
      final auth = AuthLocalService();
      if (!await auth.isLoggedIn()) {
        FCMService.releaseLocationGate();
        return;
      }
      await FCMService().initializeAfterLogin();
    } catch (e) {
      debugPrint('[MyApp] Firebase/FCM init: $e');
    }
  }

  Future<void> _backgroundTokenRefresh() async {
    final redirectTo = await tryRefreshTokenInBackground();
    if (redirectTo != null && mounted) {
      _router.go(redirectTo);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();
    final themeMode = profileViewModel.themeMode;

    return MaterialApp.router(
      title: 'Makotamu',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 150),
      themeAnimationCurve: Curves.fastOutSlowIn,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppStyle.scaffoldLight,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: false, // Matikan kontras paksaan
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyle.primary,
          brightness: Brightness.light,
          primary: AppStyle.primary,
          surface: Colors.white,
          background: AppStyle.scaffoldLight,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppStyle.scaffoldDark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarContrastEnforced: false, // Matikan kontras paksaan
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyle.primary,
          brightness: Brightness.dark,
          primary: AppStyle.primary,
          surface: AppStyle.cardDark,
          background: AppStyle.scaffoldDark,
        ),
      ),
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false, // Tambahkan ini di builder juga
            systemStatusBarContrastEnforced: false,
          ),
          child: child!,
        );
      },
      routerConfig: _router,
    );
  }
}
