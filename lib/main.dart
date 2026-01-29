import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdm_malang/utils/routes.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';
import 'package:pdm_malang/view_models/profile_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AgendaViewModel()),
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
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
      themeAnimationDuration: const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.fastOutSlowIn,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFCFCFC),
        textTheme: GoogleFonts.interTextTheme(),
        dividerTheme: DividerThemeData(color: Colors.grey[200]),
        iconTheme: const IconThemeData(color: Color(0xFF152D8D)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF152D8D),
          brightness: Brightness.light,
          surface: Colors.white,
          onSurface: const Color(0xFF2D3142),
          background: const Color(0xFFFCFCFC),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        dividerTheme: const DividerThemeData(color: Colors.white10),
        iconTheme: const IconThemeData(color: Colors.white70),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF152D8D),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          onSurface: Colors.white,
          background: const Color(0xFF121212),
        ),
      ),
      routerConfig: router,
    );
  }
}
