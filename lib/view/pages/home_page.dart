import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth/auth_local_service.dart';
import '../../services/fcm/fcm_service.dart';
import '../../view_models/home_view_model.dart';
import 'home/widgets/home_event_section.dart';
import 'home/widgets/home_header.dart';
import 'home/widgets/home_menu_section.dart';
import 'home/widgets/home_news_section.dart';
import 'home/widgets/home_news_slide.dart';
import 'home/widgets/home_prayer_qibla_section.dart';
import 'home/widgets/home_search_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _canRefresh = false;

  @override
  void initState() {
    super.initState();
    unawaited(AuthLocalService().getCachedUser());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _canRefresh = true);
      });
      // Perizinan (notifikasi, lokasi, alarm) hanya diminta di halaman Home
      _requestPermissionsIfNeeded();
    });
  }

  Future<void> _requestPermissionsIfNeeded() async {
    try {
      if (!await AuthLocalService().isLoggedIn()) return;
      FCMService.armLocationGateBeforeNotificationPrompt();
      await FCMService().initializeAfterLogin();
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    await context.read<HomeViewModel>().refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF152D8D),
        notificationPredicate: (_) => _canRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                const HomeHeader(),
                const SizedBox(height: 24),
                const HomeSearchSection(),
                const SizedBox(height: 24),
                Consumer<HomeViewModel>(
                  builder: (_, vm, __) => HomeNewsSlide(
                    currentIndex: vm.slideIndex,
                    news: vm.featuredNews,
                    loading: vm.featuredLoading,
                  ),
                ),
                const SizedBox(height: 16),
                const HomePrayerQiblaSection(),
                const SizedBox(height: 24),
                const HomeEventSection(),
                const HomeMenuSection(),
                const SizedBox(height: 8),
                const HomeNewsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
