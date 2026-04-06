import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/fcm_service.dart';
import '../../services/prayer_time_service.dart';
import '../../view_models/home_view_model.dart';
import '../widgets/back_button_app.dart';

class JadwalSholatPage extends StatefulWidget {
  const JadwalSholatPage({super.key, this.prayer});

  final PrayerTimeResult? prayer;

  static String _timeDot(String t) => t.replaceAll(':', '.');

  static String _cityTitleCase(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  @override
  State<JadwalSholatPage> createState() => _JadwalSholatPageState();
}

class _JadwalSholatPageState extends State<JadwalSholatPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await FCMService().runJadwalPageAndroidPermissionOnboarding();
      if (!mounted) return;
      if (widget.prayer == null) {
        context.read<HomeViewModel>().loadPrayerData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final prayer = widget.prayer ?? vm.prayerTime;
        final loadingExtra = widget.prayer == null && vm.prayerLoading;
        final subtitle = prayer != null
            ? JadwalSholatPage._cityTitleCase(prayer.city)
            : (loadingExtra ? 'Memuat jadwal…' : 'Waktu sholat');

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: _JadwalHeader(subtitle: subtitle),
            ),
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: SafeArea(
                top: false,
                child: _JadwalContent(
                  prayer: prayer,
                  isDark: isDark,
                  prayerLoadingExtra: loadingExtra,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JadwalHeader extends StatelessWidget implements PreferredSizeWidget {
  const _JadwalHeader({required this.subtitle});

  final String subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                key: const ValueKey('headerTitle'),
                children: [
                  BackButtonApp(onTap: () => context.pop()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Jadwal Sholat',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerBlueBanner extends StatefulWidget {
  const _NextPrayerBlueBanner({required this.prayer, required this.isDark});

  final PrayerTimeResult prayer;
  final bool isDark;

  @override
  State<_NextPrayerBlueBanner> createState() => _NextPrayerBlueBannerState();
}

class _NextPrayerBlueBannerState extends State<_NextPrayerBlueBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = widget.prayer.nextPrayer;
    final city = JadwalSholatPage._cityTitleCase(widget.prayer.city);
    final isDark = widget.isDark;
    final countdown = PrayerTimeResult.formatCountdownId(
      widget.prayer.durationUntilNextPrayer,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF152D8D), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sholat berikutnya',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.88),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      next.name,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      next.time,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                height: 88,
                child: Image.asset(
                  _prayerIconAsset(next.name),
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.9),
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => Icon(
                    RemixIcons.time_line,
                    size: 52,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                RemixIcons.map_pin_2_fill,
                size: 16,
                color: Colors.white.withOpacity(0.85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  city.isEmpty ? 'Lokasi' : city,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Text(
                  countdown,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JadwalContent extends StatelessWidget {
  const _JadwalContent({
    required this.prayer,
    required this.isDark,
    this.prayerLoadingExtra = false,
  });

  final PrayerTimeResult? prayer;
  final bool isDark;
  /// True saat data diambil dari API (deep link / notifikasi tanpa extra).
  final bool prayerLoadingExtra;

  @override
  Widget build(BuildContext context) {
    final nextName = prayer?.nextPrayer.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prayerLoadingExtra && prayer == null)
            _JadwalLoadingSkeleton(isDark: isDark)
          else ...[
            if (prayer != null) ...[
              _NextPrayerBlueBanner(prayer: prayer!, isDark: isDark),
              const SizedBox(height: 20),
            ],
            _WhiteScheduleSection(
              isDark: isDark,
              title: 'Jadwal Sholat',
              icon: RemixIcons.time_line,
              child: prayer == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Data jadwal tidak tersedia',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ),
                    )
                  : _PrayerScheduleList(
                      prayer: prayer!,
                      nextPrayerName: nextName,
                      isDark: isDark,
                    ),
            ),
            const SizedBox(height: 16),
            Consumer<HomeViewModel>(
              builder: (context, vm, _) {
                return _KiblatShortcutCard(
                  isDark: isDark,
                  qiblaDegree: vm.qiblaDirection,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading: shimmer grayscale pada kartu berikutnya, section jadwal, dan kiblat.
class _JadwalLoadingSkeleton extends StatelessWidget {
  const _JadwalLoadingSkeleton({required this.isDark});

  final bool isDark;

  static ShimmerEffect _shimmer(bool isDark) => ShimmerEffect(
        baseColor:
            isDark ? const Color(0xFF262626) : const Color(0xFFD5D5D5),
        highlightColor:
            isDark ? const Color(0xFF404040) : const Color(0xFFF0F0F0),
      );

  static final _placeholderPrayer = PrayerTimeResult(
    fajr: '04.00',
    sunrise: '05.30',
    dhuhr: '12.00',
    asr: '15.30',
    maghrib: '18.00',
    isha: '19.15',
    city: 'Kota placeholder',
  );

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : const Color(0xFF5C6370);
    final titleCol = isDark ? Colors.white : const Color(0xFF2D3142);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F3F3);
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE0E0E0);

    return Skeletonizer(
      enabled: true,
      effect: _shimmer(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sholat berikutnya',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dzuhur',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              color: titleCol,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '12.00',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: Icon(
                        RemixIcons.time_line,
                        size: 52,
                        color: muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(RemixIcons.map_pin_2_fill, size: 16, color: muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Nama kota',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '0 mnt',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: titleCol,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _WhiteScheduleSection(
            isDark: isDark,
            title: 'Jadwal Sholat',
            icon: RemixIcons.time_line,
            headerIconNeutral: true,
            child: _PrayerScheduleList(
              prayer: _placeholderPrayer,
              nextPrayerName: 'Dzuhur',
              isDark: isDark,
              grayscaleSkeleton: true,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF1F4F9),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF0F2F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        RemixIcons.compass_3_fill,
                        size: 26,
                        color: muted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kompas kiblat',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: titleCol,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Menghitung arah kiblat…',
                            style: TextStyle(
                              fontSize: 13,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      RemixIcons.arrow_right_s_line,
                      color: muted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Entri ke halaman kompas kiblat (di bawah kontainer jadwal utama).
class _KiblatShortcutCard extends StatelessWidget {
  const _KiblatShortcutCard({
    required this.isDark,
    required this.qiblaDegree,
  });

  final bool isDark;
  final double? qiblaDegree;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFF1F4F9);
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subtitleColor = isDark ? Colors.white54 : const Color(0xFF5C6370);
    final accent = isDark ? const Color(0xFF93A9E8) : const Color(0xFF152D8D);
    final deg = qiblaDegree?.round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/kiblat', extra: {'qibla': qiblaDegree}),
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFF0F2F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    RemixIcons.compass_3_fill,
                    size: 26,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kompas kiblat',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deg != null
                            ? 'Arah $deg° · buka kompas'
                            : 'Buka kompas arah Ka\'bah',
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  RemixIcons.arrow_right_s_line,
                  color: subtitleColor,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteScheduleSection extends StatelessWidget {
  const _WhiteScheduleSection({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.child,
    this.headerIconNeutral = false,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;
  /// Ikon judul abu-abu (placeholder / skeleton) tanpa aksen biru.
  final bool headerIconNeutral;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFF1F4F9);
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: headerIconNeutral
                        ? (isDark ? Colors.white54 : const Color(0xFF757575))
                        : (isDark ? const Color(0xFF93A9E8) : const Color(0xFF152D8D)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

String _prayerIconAsset(String prayerName) {
  final file = prayerName.toLowerCase().replaceAll(' ', '_');
  return 'assets/images/jadwal_sholat/$file.png';
}

class _PrayerScheduleList extends StatelessWidget {
  const _PrayerScheduleList({
    required this.prayer,
    this.nextPrayerName,
    required this.isDark,
    this.grayscaleSkeleton = false,
  });

  final PrayerTimeResult prayer;
  final String? nextPrayerName;
  final bool isDark;
  /// Warna netral untuk placeholder di dalam [Skeletonizer] (tanpa aksen biru).
  final bool grayscaleSkeleton;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Subuh', prayer.fajr),
      ('Terbit', prayer.sunrise),
      ('Dzuhur', prayer.dhuhr),
      ('Ashar', prayer.asr),
      ('Maghrib', prayer.maghrib),
      ('Isya', prayer.isha),
    ];

    final nameColor = isDark ? Colors.white.withOpacity(0.92) : const Color(0xFF2D3142);
    final timeColor = grayscaleSkeleton
        ? (isDark ? Colors.white70 : const Color(0xFF4A4A4A))
        : (isDark ? Colors.white : const Color(0xFF152D8D));
    final rowBg = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F6FA);
    final rowBgNext = grayscaleSkeleton
        ? (isDark
            ? Colors.white.withOpacity(0.1)
            : const Color(0xFFE0E0E0))
        : (isDark
            ? const Color(0xFF152D8D).withOpacity(0.22)
            : const Color(0xFFE8EEF9));
    final prayerIconTint = grayscaleSkeleton
        ? (isDark ? Colors.white54 : const Color(0xFF6E6E6E))
        : (isDark ? const Color(0xFF93A9E8) : const Color(0xFF152D8D));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: rows.map((e) {
          final name = e.$1;
          final time = e.$2;
          final isNext = name == nextPrayerName;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isNext ? rowBgNext : rowBg,
              borderRadius: BorderRadius.circular(16),
              border: isNext
                  ? Border.all(
                      color: grayscaleSkeleton
                          ? (isDark
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFFBDBDBD))
                          : const Color(0xFF152D8D)
                              .withOpacity(isDark ? 0.5 : 0.35),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          prayerIconTint,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          _prayerIconAsset(name),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            RemixIcons.time_line,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isNext)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          RemixIcons.arrow_right_circle_fill,
                          size: 18,
                          color: grayscaleSkeleton
                              ? (isDark ? Colors.white54 : const Color(0xFF757575))
                              : const Color(0xFF152D8D),
                        ),
                      ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                        color: nameColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  JadwalSholatPage._timeDot(time),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: timeColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
