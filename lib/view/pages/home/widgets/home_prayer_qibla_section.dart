import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pdm_malang/services/prayer/prayer_time_service.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';

class HomePrayerQiblaSection extends StatefulWidget {
  const HomePrayerQiblaSection({super.key});

  @override
  State<HomePrayerQiblaSection> createState() => _HomePrayerQiblaSectionState();
}

class _HomePrayerQiblaSectionState extends State<HomePrayerQiblaSection> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<HomeViewModel>();
    if (vm.prayerTime == null && vm.prayerLoading) {
      vm.loadPrayerData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<HomeViewModel>(
      builder: (_, vm, __) {
        final loading = vm.prayerLoading;
        final prayer = vm.prayerTime;
        final isSkeleton = loading && prayer == null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Skeletonizer(
            enabled: isSkeleton,
            effect: ShimmerEffect(
              baseColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFE0E0E0),
              highlightColor: isDark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFF5F5F5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSkeleton
                    ? null
                    : () => context.push(
                          '/jadwal-sholat',
                          extra: {'prayer': prayer},
                        ),
                borderRadius: BorderRadius.circular(20),
                child: HomeNextPrayerBlueBanner(
                  prayer: prayer,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _prayerIconAsset(String prayerName) {
  final file = prayerName.toLowerCase().replaceAll(' ', '_');
  return 'assets/images/jadwal_sholat/$file.png';
}

class HomeNextPrayerBlueBanner extends StatefulWidget {
  const HomeNextPrayerBlueBanner({
    super.key,
    required this.prayer,
    required this.isDark,
  });

  final PrayerTimeResult? prayer;
  final bool isDark;

  static String _cityTitle(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  @override
  State<HomeNextPrayerBlueBanner> createState() =>
      _HomeNextPrayerBlueBannerState();
}

class _HomeNextPrayerBlueBannerState extends State<HomeNextPrayerBlueBanner> {
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
    final prayer = widget.prayer;
    final isDark = widget.isDark;
    final next = prayer?.nextPrayer;
    final name = next?.name ?? 'Subuh';
    final time = next?.time ?? '00.00';
    final city = HomeNextPrayerBlueBanner._cityTitle(prayer?.city ?? 'Lokasi');
    final countdown = prayer != null
        ? PrayerTimeResult.formatCountdownId(prayer.durationUntilNextPrayer)
        : '-- mnt';

    final isSkeleton = prayer == null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isSkeleton
            ? null
            : const LinearGradient(
                colors: [Color(0xFF152D8D), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isSkeleton
            ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSkeleton
              ? (isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE0E0E0))
              : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sholat berikutnya',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.82),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                        color: Colors.white.withOpacity(0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(
                  _prayerIconAsset(name),
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.9),
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => Icon(
                    RemixIcons.time_line,
                    size: 38,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                RemixIcons.map_pin_2_fill,
                size: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  city.isEmpty ? 'Lokasi' : city,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  countdown,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
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
