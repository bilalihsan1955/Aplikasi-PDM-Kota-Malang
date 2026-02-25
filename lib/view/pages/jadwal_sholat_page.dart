import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../services/prayer_time_service.dart';
import '../widgets/back_button_app.dart';

class JadwalSholatPage extends StatelessWidget {
  const JadwalSholatPage({super.key, this.prayer, this.qiblaDegree});

  final PrayerTimeResult? prayer;
  final double? qiblaDegree;

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextName = prayer?.nextPrayer.name;
    final subtitle = prayer != null
        ? _cityTitleCase(prayer!.city)
        : 'Waktu sholat dan arah kiblat';

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
          // Padding atas sekarang kecil karena sudah di bawah AppBar
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          child: SafeArea(
            top: false,
            child: _JadwalContent(
              prayer: prayer,
              qiblaDegree: qiblaDegree,
              nextName: nextName,
              isDark: isDark,
            ),
          ),
        ),
      ),
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Jadwal Sholat',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2D3142),
                            ),
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

class _JadwalContent extends StatelessWidget {
  const _JadwalContent({
    required this.prayer,
    required this.qiblaDegree,
    required this.nextName,
    required this.isDark,
  });

  final PrayerTimeResult? prayer;
  final double? qiblaDegree;
  final String? nextName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Jadwal Sholat
          _SectionCard(
          isDark: isDark,
          title: 'Jadwal Sholat',
          icon: RemixIcons.time_line,
          gradient: const LinearGradient(
            colors: [Color(0xFF152D8D), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: prayer == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Data jadwal tidak tersedia'),
                  ),
                )
              : _PrayerScheduleList(
                  prayer: prayer!,
                  nextPrayerName: nextName,
                  isDark: isDark,
                ),
          ),
          const SizedBox(height: 24),
          // Section: Arah Kiblat
          _SectionCard(
          isDark: isDark,
          title: 'Arah Kiblat',
          icon: RemixIcons.compass_3_fill,
          gradient: const LinearGradient(
            colors: [Color(0xFF39A658), Color(0xFF2D8E4A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: qiblaDegree == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Data arah kiblat tidak tersedia'),
                  ),
                )
              : _QiblaCompassSection(
                  qiblaDegree: qiblaDegree!,
                  isDark: isDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.child,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final Gradient gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
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
                  Icon(icon, size: 22, color: Colors.white.withOpacity(0.9)),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
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
  });

  final PrayerTimeResult prayer;
  final String? nextPrayerName;
  final bool isDark;

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
              color: Colors.white.withOpacity(isNext ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(16),
              border: isNext
                  ? Border.all(color: Colors.white.withOpacity(0.4), width: 1)
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
                      child: Image.asset(
                        _prayerIconAsset(name),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          RemixIcons.time_line,
                          size: 24,
                          color: Colors.white.withOpacity(0.8),
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
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
                Text(
                  JadwalSholatPage._timeDot(time),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class _QiblaCompassSection extends StatelessWidget {
  const _QiblaCompassSection({required this.qiblaDegree, required this.isDark});

  final double qiblaDegree;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Center(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            final heading = snapshot.data?.heading;
            final hasCompass = heading != null;
            double headingDisplay = heading ?? 0;
            while (headingDisplay < 0) headingDisplay += 360;
            while (headingDisplay >= 360) headingDisplay -= 360;
            double diff = hasCompass ? (headingDisplay - qiblaDegree) : 0;
            while (diff > 180) diff -= 360;
            while (diff < -180) diff += 360;
            final isAligned = hasCompass && diff.abs() < 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Arahkan ke derajat ${qiblaDegree.round()}° untuk posisi Indonesia',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (hasCompass)
                        Transform.rotate(
                          angle: -heading * (math.pi / 180),
                          child: _CompassDial(
                            size: 220,
                            qiblaDegree: qiblaDegree,
                            isAligned: isAligned,
                            heading: heading,
                          ),
                        )
                      else
                        _CompassDial(
                          size: 220,
                          qiblaDegree: qiblaDegree,
                          isAligned: isAligned,
                          heading: null,
                        ),
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _CompassNeedlePainter(
                          needleColor: isAligned
                              ? const Color(0xFFFFD700)
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAligned
                              ? const Color(0xFFFFD700)
                              : Colors.white.withOpacity(0.95),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      if (hasCompass)
                        Positioned(
                          bottom: 64,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              '${headingDisplay.round()}°',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: isAligned
                                    ? const Color(0xFFFFD700)
                                    : Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!hasCompass)
                  Text(
                    'Aktifkan lokasi untuk kompas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  _CompassNeedlePainter({
    required this.needleColor,
  });

  final Color needleColor;

  static const double needleLength = 72;
  static const double needleWidth = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx, cy - needleLength)
      ..lineTo(cx + needleWidth, cy)
      ..lineTo(cx, cy + needleWidth)
      ..lineTo(cx - needleWidth, cy)
      ..close();
    canvas.drawPath(path, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(covariant _CompassNeedlePainter old) =>
      old.needleColor != needleColor;
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.size,
    required this.qiblaDegree,
    required this.isAligned,
    this.heading,
  });

  final double size;
  final double qiblaDegree;
  final bool isAligned;
  final double? heading;

  @override
  Widget build(BuildContext context) {
    final cx = size / 2;
    final cy = size / 2;
    const double qiblaRadius = 85;
    const double iconSize = 28;
    final rad = qiblaDegree * (math.pi / 180);
    final qx = cx + qiblaRadius * math.sin(rad);
    final qy = cy - qiblaRadius * math.cos(rad);
    final iconAngle = (heading ?? 0) * (math.pi / 180);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassDialPainter(size: size),
        child: Stack(
          children: [
            _dialLabel('N', Alignment.topCenter, isNorth: true),
            _dialLabel('E', Alignment.centerRight, isNorth: false),
            _dialLabel('S', Alignment.bottomCenter, isNorth: false),
            _dialLabel('W', Alignment.centerLeft, isNorth: false),
            Positioned(
              left: qx - iconSize / 2,
              top: qy - iconSize / 2,
              width: iconSize,
              height: iconSize,
              child: Transform.rotate(
                angle: iconAngle,
                alignment: Alignment.center,
                child: isAligned
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFFD700),
                          BlendMode.modulate,
                        ),
                        child: Image.asset(
                          'assets/images/kaaba-01.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            RemixIcons.compass_3_fill,
                            size: 22,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      )
                    : Image.asset(
                        'assets/images/kaaba-01.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          RemixIcons.compass_3_fill,
                          size: 22,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialLabel(String text, Alignment align, {required bool isNorth}) {
    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isNorth ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isNorth
                ? Colors.white
                : Colors.white.withOpacity(0.8),
            shadows: isNorth
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({required this.size});

  final double size;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 4;

    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius - 8,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (int i = 0; i < 360; i += 30) {
      final rad = i * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final tickLength = isCardinal ? 14 : 8;
      final innerR = radius - tickLength;
      final outerR = radius;
      canvas.drawLine(
        Offset(cx + innerR * math.sin(rad), cy - innerR * math.cos(rad)),
        Offset(cx + outerR * math.sin(rad), cy - outerR * math.cos(rad)),
        Paint()
          ..color = Colors.white.withOpacity(isCardinal ? 0.9 : 0.5)
          ..strokeWidth = isCardinal ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter old) => old.size != size;
}
