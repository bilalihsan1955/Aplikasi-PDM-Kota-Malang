import 'dart:async';

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
import 'package:pdm_malang/utils/notification_navigation.dart';
import 'package:pdm_malang/utils/routes.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';
import 'package:pdm_malang/view_models/profile_view_model.dart';
import 'package:pdm_malang/view_models/notification_view_model.dart';
import 'package:pdm_malang/view_models/auth_view_model.dart';
import 'package:pdm_malang/utils/app_style.dart';
import 'package:pdm_malang/firebase_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FCMService.registerNotificationOpenListener();

  final authLocation = await AuthLocalService().resolveInitialLocation();

  String routerInitial = authLocation;
  Object? routerInitialExtra;

  // Cold start dari tap notifikasi: langsung buka rute tujuan (tanpa flash home).
  if (authLocation == '/') {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final openMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (openMsg != null) {
      FCMService.markInitialLaunchMessageConsumed();
      final model = FCMService.notificationModelFromRemoteMessage(openMsg);
      final target = coldStartTargetForNotification(model);
      if (target != null) {
        routerInitial = target.location;
        routerInitialExtra = target.extra;
      }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bindAppGoRouter(_router);
    FCMService().onNotificationTapped = (notification) {
      scheduleOpenNotificationTarget(notification);
    };
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
    final pathOnly = Uri.tryParse(widget.initialLocation)?.path ?? widget.initialLocation;
    const authOnlyPaths = {'/onboarding', '/login', '/register', '/forgot-password'};
    if (!authOnlyPaths.contains(pathOnly)) {
      await _backgroundTokenRefresh();
    }
  }

  @override
  void dispose() {
    FCMService().onNotificationTapped = null;
    unbindAppGoRouter();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(FCMService().syncRegisteredTokenToBackend());
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
      title: 'PDM Malang',
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
