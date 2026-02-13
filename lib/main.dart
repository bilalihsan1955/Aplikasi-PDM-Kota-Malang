import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdm_malang/utils/routes.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';
import 'package:pdm_malang/view_models/profile_view_model.dart';
import 'package:pdm_malang/view_models/notification_view_model.dart';
import 'package:pdm_malang/utils/app_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (URL API). Jika file belum ada, salin dari .env.example
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env tidak ditemukan; ApiService akan pakai fallback URL
  }

  // Initialize Firebase (Optional - akan skip jika tidak tersedia)
  // Uncomment baris berikut jika sudah setup Firebase:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AgendaViewModel()),
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        dividerTheme: DividerThemeData(color: Colors.grey[200]),
        iconTheme: const IconThemeData(color: AppStyle.primary),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyle.primary,
          brightness: Brightness.light,
          primary: AppStyle.primary,
          secondary: AppStyle.accent,
          tertiary: AppStyle.warning, // Menambahkan warna kuning
          surface: Colors.white,
          onSurface: const Color(0xFF2D3142),
          background: AppStyle.scaffoldLight,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppStyle.scaffoldDark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white.withOpacity(0.7)),
          titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        dividerTheme: const DividerThemeData(color: Colors.white10),
        iconTheme: const IconThemeData(color: Colors.white),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyle.primary,
          brightness: Brightness.dark,
          primary: AppStyle.primary,
          secondary: AppStyle.accent,
          tertiary: AppStyle.warning, // Menambahkan warna kuning
          surface: AppStyle.cardDark,
          onSurface: Colors.white,
          onPrimary: Colors.white,
          background: AppStyle.scaffoldDark,
        ),
      ),
      routerConfig: router,
    );
  }
}
