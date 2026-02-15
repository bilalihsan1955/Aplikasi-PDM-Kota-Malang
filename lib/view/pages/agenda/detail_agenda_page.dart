import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_style.dart';
import '../../../models/agenda_model.dart';
import '../../../services/event_api_service.dart';

class DetailAgendaPage extends StatefulWidget {
  final String? slug;
  final AgendaModel? initialAgenda;

  const DetailAgendaPage({super.key, this.slug, this.initialAgenda});

  @override
  State<DetailAgendaPage> createState() => _DetailAgendaPageState();
}

class _DetailAgendaPageState extends State<DetailAgendaPage> {
  final ScrollController _scrollController = ScrollController();
  final EventApiService _api = EventApiService();
  bool _isScrolled = false;
  bool _loading = true;
  String? _error;
  AgendaModel? _agenda;

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
    if (widget.initialAgenda != null) {
      _agenda = widget.initialAgenda;
      _loading = false;
    }
    if (widget.slug != null && widget.slug!.isNotEmpty) {
      _loadDetail();
    } else if (widget.initialAgenda == null) {
      _loading = false;
    }
  }

  Future<void> _loadDetail() async {
    final slug = widget.slug;
    if (slug == null || slug.isEmpty) return;
    if (_agenda == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final item = await _api.getBySlug(slug);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (item != null) {
        _agenda = item;
        _error = null;
      } else if (_agenda == null) {
        _error = 'Gagal memuat agenda';
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildBody(isDark),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: appBarColor,
                boxShadow: _isScrolled
                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(RemixIcons.arrow_left_line, color: isDark ? Colors.white : Colors.black87, size: 22),
                        iconSize: 48,
                        padding: const EdgeInsets.all(12),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _agenda?.title ?? 'Detail Agenda',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(RemixIcons.share_line, color: isDark ? Colors.white : Colors.black87, size: 22),
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

  Widget _buildBody(bool isDark) {
    if (widget.slug == null && widget.initialAgenda == null) {
      return _buildStaticContent(isDark);
    }
    if (_loading && _agenda == null) {
      return _buildSkeleton(isDark);
    }
    if (_error != null && _agenda == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RemixIcons.error_warning_line, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700])),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: _loadDetail, icon: const Icon(RemixIcons.refresh_line, size: 20), label: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    if (_agenda != null) {
      return _buildDetailContent(_agenda!, isDark);
    }
    return _buildStaticContent(isDark);
  }

  Widget _buildSkeleton(bool isDark) {
    return Skeletonizer(
      enabled: true,
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
                Container(height: 220, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24))),
                const SizedBox(height: 24),
                Container(height: 28, width: 100, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100))),
                const SizedBox(height: 16),
                Container(height: 28, width: 200, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 20, width: 160, color: Colors.grey[300]),
                const SizedBox(height: 32),
                Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24))),
                const SizedBox(height: 16),
                Container(height: 120, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24))),
                const SizedBox(height: 32),
                Container(height: 80, width: double.infinity, color: Colors.grey[300]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticContent(bool isDark) {
    return SingleChildScrollView(
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
                child: Image.asset('assets/images/banner.png', height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              _buildConferenceTag(),
              const SizedBox(height: 16),
              const Text('Leadership Summit 2024', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
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
                'Join us for the annual Leadership Summit, where industry pioneers gather to discuss the future of corporate strategy.',
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(AgendaModel agenda, bool isDark) {
    final imageWidget = (agenda.image.startsWith('http://') || agenda.image.startsWith('https://'))
        ? Image.network(agenda.image, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderImage(220, isDark))
        : (agenda.image.isNotEmpty
            ? Image.asset(agenda.image, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderImage(220, isDark))
            : _placeholderImage(220, isDark));

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              ClipRRect(borderRadius: BorderRadius.circular(24), child: imageWidget),
              const SizedBox(height: 24),
              _buildCategoryTag(agenda.categoryName),
              const SizedBox(height: 16),
              Text(agenda.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              if (agenda.organizer != null && agenda.organizer!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(RemixIcons.verified_badge_line, color: AppStyle.accent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Diselenggarakan oleh ${agenda.organizer}',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 14),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              _buildDateTimeCardFromAgenda(agenda, context),
              const SizedBox(height: 16),
              _buildDetailsCardFromAgenda(agenda, isDark),
              if (agenda.registrationLink != null && agenda.registrationLink!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildRegistrationButton(context, isDark),
              ],
              const SizedBox(height: 32),
              _buildLocationHeader(),
              const SizedBox(height: 16),
              _buildMapPreview(isDark, locationName: agenda.location),
              const SizedBox(height: 32),
              const Text('Tentang Acara', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                agenda.displayDescription.isEmpty ? 'Tidak ada deskripsi.' : agenda.displayDescription,
                style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage(double height, bool isDark) {
    return Container(
      height: height,
      width: double.infinity,
      color: isDark ? Colors.white10 : Colors.grey[200],
      child: Icon(RemixIcons.calendar_event_line, size: 48, color: isDark ? Colors.white24 : Colors.grey[400]),
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: AppStyle.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppStyle.primary, letterSpacing: 0.5)),
    );
  }

  Widget _buildDateTimeCardFromAgenda(AgendaModel agenda, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const RadialGradient(center: Alignment.topLeft, radius: 3, colors: [Color(0xFF39A658), Color(0xFF4A6FDB), Color(0XFF071D75)], stops: [0.0, 0.3, 0.8]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset('assets/images/pattern.png', fit: BoxFit.cover, height: 140, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  SizedBox(height: 64, child: _buildCardDateFromAgenda(agenda, context)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('DATE & TIME', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(agenda.eventDateFormatted, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(agenda.time.isEmpty ? '–' : agenda.time, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDateFromAgenda(AgendaModel agenda, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isDark
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: _dateContainerFromAgenda(agenda, isDark, textColor),
              )
            : _dateContainerFromAgenda(agenda, isDark, textColor),
      ),
    );
  }

  Widget _dateContainerFromAgenda(AgendaModel agenda, bool isDark, Color textColor) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152D8D).withOpacity(0.8) : const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(agenda.month, style: TextStyle(color: textColor, fontWeight: isDark ? FontWeight.bold : FontWeight.w900, fontSize: 12)),
          Text(agenda.date, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildRegistrationButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        final link = _agenda?.registrationLink;
        if (link != null && link.isNotEmpty) {
          // TODO: launchUrl(Uri.parse(link)) if url_launcher added
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppStyle.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppStyle.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(RemixIcons.link, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Daftar / Link Pendaftaran',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCardFromAgenda(AgendaModel agenda, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : (Colors.grey[200] ?? Colors.grey)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _infoRow(RemixIcons.map_pin_line, 'Lokasi', agenda.location, Colors.green),
          if (agenda.contactPerson != null && agenda.contactPerson!.isNotEmpty) ...[
            const Divider(height: 32),
            _infoRow(RemixIcons.user_line, 'Kontak', agenda.contactPerson!, Colors.blue),
          ],
          if (agenda.contactPhone != null && agenda.contactPhone!.isNotEmpty) ...[
            const Divider(height: 32),
            _infoRow(RemixIcons.phone_line, 'Telepon', agenda.contactPhone!, Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const RadialGradient(center: Alignment.topLeft, radius: 3, colors: [Color(0xFF39A658), Color(0xFF4A6FDB), Color(0XFF071D75)], stops: [0.0, 0.3, 0.8]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Pattern di kanan
            Positioned(
              right: -20,
              top: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/pattern.png',
                  fit: BoxFit.cover,
                  height: 140,
                ),
              ),
            ),
            // Konten utama
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Row dibatasi tinggi agar double.infinity pada anak bekerja dengan benar
                  SizedBox(
                    height: 64,
                    child: _buildCardDate(context),
                  ),
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
            ),
          ],
        ),
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
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: _dateContainer(isDark, textColor),
            )
          : _dateContainer(isDark, textColor),
      ),
    );
  }

  Widget _dateContainer(bool isDark, Color textColor) {
    return Container(
      height: double.infinity, // Tinggi mengisi ruang yang tersedia
      width: double.infinity,  // Lebar akan dikontrol oleh AspectRatio 1:1
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

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () {},
          child: const Text('View Map', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Future<void> _openMapsAt(double lat, double lng) async {
    // geo: membuka app peta (Google Maps); fallback https untuk browser
    final geoUri = Uri.parse('geo:$lat,$lng');
    final webUri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildMapPreview(bool isDark, {String? locationName}) {
    const LatLng eventLocation = LatLng(-7.9666, 112.6326);
    final name = (locationName != null && locationName.trim().isNotEmpty) ? locationName.trim() : 'Lokasi acara';
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(initialCenter: eventLocation, initialZoom: 15.0, interactionOptions: InteractionOptions(flags: InteractiveFlag.none)),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.pdm_malang.app'),
                MarkerLayer(markers: [Marker(point: eventLocation, width: 40, height: 40, child: const Icon(RemixIcons.map_pin_line, color: Colors.red, size: 40))]),
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
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle), child: const Icon(RemixIcons.map_pin_line, color: Colors.white, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('Lokasi acara', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openMapsAt(eventLocation.latitude, eventLocation.longitude),
                      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), shape: BoxShape.circle), child: const Icon(RemixIcons.compass_3_line, color: Color(0xFF1565C0), size: 20)),
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
        const Icon(RemixIcons.verified_badge_line, color: AppStyle.accent, size: 18),
        const SizedBox(width: 6),
        const Text('Hosted by Global Innovators', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
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
          _infoRow(RemixIcons.map_pin_line, 'Grand Hyatt Center', 'Hall B, Level 2', Colors.green),
          const Divider(height: 32),
          _infoRow(RemixIcons.accessibility_line, 'Business Casual', 'Professional attire', Colors.blue),
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
