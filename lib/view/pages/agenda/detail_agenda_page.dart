import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_style.dart';
import '../../../models/agenda_model.dart';

class DetailAgendaPage extends StatefulWidget {
  final String? slug;
  final AgendaModel? initialAgenda;

  const DetailAgendaPage({
    super.key,
    this.slug,
    this.initialAgenda,
  });

  @override
  State<DetailAgendaPage> createState() => _DetailAgendaPageState();
}

class _DetailAgendaPageState extends State<DetailAgendaPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Koordinat Default
  static const double _defaultLat = -7.949630143095969;
  static const double _defaultLng = 112.60867657182543;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 10) {
        if (!_isScrolled) setState(() => _isScrolled = true);
      } else {
        if (_isScrolled) setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchGoogleMaps() async {
    // Gunakan koordinat dari agenda jika ada, jika tidak gunakan default
    final double lat = widget.initialAgenda?.latitude ?? _defaultLat;
    final double lng = widget.initialAgenda?.longitude ?? _defaultLng;
    
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final agendaTitle = widget.initialAgenda?.title ?? 'Detail Agenda';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/banner.png',
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildConferenceTag(),
                      const SizedBox(height: 16),
                      Text(
                        agendaTitle,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      _buildHostedInfo(),
                      const SizedBox(height: 32),
                      _buildDateTimeCard(context),
                      const SizedBox(height: 16),
                      _buildDetailsCard(isDark),
                      const SizedBox(height: 32),
                      _buildLocationHeader(),
                      const SizedBox(height: 16),
                      _buildMapPreview(isDark),
                      const SizedBox(height: 32),
                      const Text('About Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        'Join us for the annual Leadership Summit, where industry pioneers gather to discuss the future of corporate strategy. This year\'s session will focus on sustainable growth.',
                        style: TextStyle(fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      _buildRegisterButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: appBarColor,
                boxShadow: _isScrolled ? [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))
                ] : [],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isScrolled ? 1 : 0,
                          child: Text(
                            agendaTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share_outlined, color: isDark ? Colors.white : Colors.black87, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: _launchGoogleMaps,
          child: const Text('View Map', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildMapPreview(bool isDark) {
    final double lat = widget.initialAgenda?.latitude ?? _defaultLat;
    final double lng = widget.initialAgenda?.longitude ?? _defaultLng;
    final LatLng eventLocation = LatLng(lat, lng);

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: eventLocation,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.pdm_malang.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: eventLocation,
                      width: 40, height: 40,
                      rotate: false,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Colors.white, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.initialAgenda?.location ?? 'Lokasi Acara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      Text('2.4 km from your location', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ])),
                    GestureDetector(
                      onTap: _launchGoogleMaps,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), shape: BoxShape.circle),
                        child: const Icon(RemixIcons.compass_3_line, color: Color(0xFF1565C0), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFF1F4F9), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Register Now', style: TextStyle(color: AppStyle.accent, fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: AppStyle.accent, size: 20),
        ],
      ),
    );
  }

  Widget _buildConferenceTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: AppStyle.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: const Text('CONFERENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppStyle.primary, letterSpacing: 0.5)),
    );
  }

  Widget _buildHostedInfo() {
    return Row(
      children: [
        const Icon(Icons.verified, color: AppStyle.accent, size: 18),
        const SizedBox(width: 6),
        const Text('Hosted by Global Innovators', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildDateTimeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const RadialGradient(center: Alignment.topLeft, radius: 3, colors: [Color(0xFF39A658), Color(0xFF4A6FDB), Color(0XFF071D75)], stops: [0.0, 0.3, 0.8]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          SizedBox(height: 64, child: _buildCardDate(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('DATE & TIME', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('Oct 24, 2026', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('09:00 AM - 12:00 PM', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDate(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isDark 
          ? BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: _dateContainer(isDark, textColor))
          : _dateContainer(isDark, textColor),
      ),
    );
  }

  Widget _dateContainer(bool isDark, Color textColor) {
    return Container(
      height: double.infinity, width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152D8D).withOpacity(0.8) : const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('OCT', style: TextStyle(color: textColor, fontWeight: isDark ? FontWeight.bold : FontWeight.w900, fontSize: 12)),
          Text('24', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _infoRow(Icons.location_on, 'Grand Hyatt Center', 'Hall B, Level 2', Colors.green),
          const Divider(height: 32),
          _infoRow(Icons.accessibility, 'Business Casual', 'Professional attire', Colors.blue),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
