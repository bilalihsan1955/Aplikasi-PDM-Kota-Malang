import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdm_malang/utils/in_app_webview_nav.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'home_section_header.dart';

class HomeMenuSection extends StatelessWidget {
  const HomeMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: HomeSectionHeader(
            title: 'Menu Utama',
            onTapAll: () => context.push('/menu'),
          ),
        ),
        const SizedBox(height: 8),
        const HomeMenuGrid(),
      ],
    );
  }
}

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF39A658);
    final viewModel = context.watch<HomeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewModel.homeMenus.length > 8
            ? 8
            : viewModel.homeMenus.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 0,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = viewModel.homeMenus[index];

          return GestureDetector(
            onTap: () {
              if (item['label'] == 'sholat') {
                context.push(
                  '/jadwal-sholat',
                  extra: {'prayer': viewModel.prayerTime},
                );
              }
              if (item['label'] == 'Berita') context.go('/berita');
              if (item['label'] == 'Agenda') context.go('/agenda');
              if (item['label'] == 'Profil') context.go('/about-pdm');
              if (item['label'] == 'Dokumentasi') context.push('/gallery');
              if (item['label'] == 'Amal Usaha') context.push('/amal-usaha');
              if (item['label'] == 'Notifikasi') context.push('/notifications');
              if (item['label'] == 'KHGT') {
                pushInAppWebView(
                  context,
                  url: 'https://khgt.muhammadiyah.or.id/kalendar-hijriah',
                  title: 'KHGT',
                );
              }
              if (item['label'] == 'Cari') context.push('/menu');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFC300).withOpacity(0.25),
                        themeColor.withOpacity(0.25),
                      ],
                      begin: index.isEven
                          ? Alignment.topLeft
                          : Alignment.bottomRight,
                      end: index.isEven
                          ? Alignment.bottomRight
                          : Alignment.topLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(item['icon'], color: themeColor, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF2D3142),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
