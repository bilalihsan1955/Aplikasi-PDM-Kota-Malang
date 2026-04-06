import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../widgets/back_button_app.dart';

class KiblatPage extends StatelessWidget {
  const KiblatPage({super.key, this.qiblaDegree});

  final double? qiblaDegree;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: _KiblatHeader(isDark: isDark),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: qiblaDegree == null
                ? Center(
                    child: Text(
                      'Data arah kiblat tidak tersedia',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  )
                : _KiblatCompassCard(
                    qiblaDegree: qiblaDegree!,
                    isDark: isDark,
                  ),
          ),
        ),
      ),
    );
  }
}

class _KiblatHeader extends StatelessWidget implements PreferredSizeWidget {
  const _KiblatHeader({required this.isDark});

  final bool isDark;

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
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
                children: [
                  BackButtonApp(onTap: () => context.pop()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Arah Kiblat',
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
                          'Kompas menuju Ka\'bah',
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

class _KiblatCompassCard extends StatelessWidget {
  const _KiblatCompassCard({
    required this.qiblaDegree,
    required this.isDark,
  });

  final double qiblaDegree;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFF1F4F9);
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return SizedBox.expand(
      child: Container(
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
          child: _KiblaCompassSection(
            qiblaDegree: qiblaDegree,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _KiblaCompassSection extends StatelessWidget {
  const _KiblaCompassSection({required this.qiblaDegree, required this.isDark});

  final double qiblaDegree;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hintColor = isDark ? Colors.white70 : const Color(0xFF5C6370);
    final primaryText = isDark ? Colors.white : const Color(0xFF2D3142);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                    color: hintColor,
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
                          angle: -headingDisplay * (math.pi / 180),
                          child: _CompassDial(
                            size: 220,
                            qiblaDegree: qiblaDegree,
                            isAligned: isAligned,
                            heading: heading,
                            isDark: isDark,
                          ),
                        )
                      else
                        _CompassDial(
                          size: 220,
                          qiblaDegree: qiblaDegree,
                          isAligned: isAligned,
                          heading: null,
                          isDark: isDark,
                        ),
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _CompassNeedlePainter(
                          needleColor: isAligned
                              ? const Color(0xFFFFD700)
                              : (isDark
                                    ? Colors.white.withOpacity(0.9)
                                    : const Color(0xFF152D8D)),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAligned
                              ? const Color(0xFFFFD700)
                              : (isDark
                                    ? Colors.white.withOpacity(0.95)
                                    : Colors.white),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : const Color(0xFF152D8D).withOpacity(0.35),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                                    : primaryText,
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
                      color: primaryText,
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
  _CompassNeedlePainter({required this.needleColor});

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
    required this.isDark,
    this.heading,
  });

  final double size;
  final double qiblaDegree;
  final bool isAligned;
  final bool isDark;
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
    final kaabaColor = isDark
        ? Colors.white.withOpacity(0.9)
        : const Color(0xFF152D8D).withOpacity(0.85);
    final fallbackIcon = kaabaColor;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassDialPainter(size: size, isDark: isDark),
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
                child: Image.asset(
                  'assets/images/kaaba-01.png',
                  fit: BoxFit.contain,
                  color: isAligned ? const Color(0xFFFFD700) : kaabaColor,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (_, __, ___) => Icon(
                    RemixIcons.compass_3_fill,
                    size: 22,
                    color: isAligned ? const Color(0xFFFFD700) : fallbackIcon,
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
    final base = isDark ? Colors.white : const Color(0xFF2D3142);
    final secondary = isDark ? Colors.white.withOpacity(0.75) : const Color(0xFF5C6370);
    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isNorth ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isNorth ? base : secondary,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({required this.size, required this.isDark});

  final double size;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 4;

    final fill = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFE8ECF2).withOpacity(0.9);
    final outerStroke = isDark
        ? Colors.white.withOpacity(0.35)
        : const Color(0xFF9AA3B2).withOpacity(0.55);
    final innerStroke = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF9AA3B2).withOpacity(0.25);

    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = outerStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius - 8,
      Paint()
        ..color = innerStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final tickStrong = isDark ? 0.85 : 0.55;
    final tickWeak = isDark ? 0.45 : 0.35;

    for (int i = 0; i < 360; i += 30) {
      final rad = i * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final tickLength = isCardinal ? 14 : 8;
      final innerR = radius - tickLength;
      final outerR = radius;
      final opacity = isCardinal ? tickStrong : tickWeak;
      canvas.drawLine(
        Offset(cx + innerR * math.sin(rad), cy - innerR * math.cos(rad)),
        Offset(cx + outerR * math.sin(rad), cy - outerR * math.cos(rad)),
        Paint()
          ..color = (isDark ? Colors.white : const Color(0xFF2D3142))
              .withOpacity(opacity)
          ..strokeWidth = isCardinal ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter old) =>
      old.size != size || old.isDark != isDark;
}
