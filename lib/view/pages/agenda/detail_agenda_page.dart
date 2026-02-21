import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_style.dart';
import '../../../models/agenda_model.dart';
import '../../../services/event_api_service.dart';
import '../../widgets/back_button_app.dart';

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
  AgendaModel? _loadedAgenda;
  bool _loading = false;

  /// Data yang ditampilkan: initial dari navigator atau hasil load by slug.
  AgendaModel? get _agenda => widget.initialAgenda ?? _loadedAgenda;

  // Koordinat Default
  static const double _defaultLat = -7.949630143095969;
  static const double _defaultLng = 112.60867657182543;

  @override
  void initState() {
    super.initState();
    if (widget.initialAgenda == null && widget.slug != null && widget.slug!.isNotEmpty) {
      _loadBySlug();
    }
  }

  Future<void> _loadBySlug() async {
    setState(() => _loading = true);
    try {
      final api = EventApiService();
      final a = await api.getBySlug(widget.slug!);
      if (mounted) setState(() {
        _loadedAgenda = a;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _launchGoogleMaps() async {
    final double lat = _agenda?.latitude ?? _defaultLat;
    final double lng = _agenda?.longitude ?? _defaultLng;
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _openRegistrationLink() async {
    final link = _agenda?.registrationLink;
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final agendaTitle = _agenda?.title ?? 'Detail Agenda';

    if (_loading && _agenda == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Memuat agenda...', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _DetailAgendaAppBar(title: agendaTitle),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildBanner(isDark),
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
                const Text('Tentang Acara', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  _agenda?.displayDescription ?? '-',
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 24),
                if ((_agenda?.registrationLink ?? '').trim().isNotEmpty) _buildRegisterButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(bool isDark) {
    final imageUrl = (_agenda?.image ?? '').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderBanner(isDark),
            )
          : _placeholderBanner(isDark),
    );
  }

  Widget _placeholderBanner(bool isDark) {
    return Container(
      height: 220,
      width: double.infinity,
      color: isDark ? Colors.white10 : Colors.grey.shade200,
      child: Icon(RemixIcons.image_line, size: 48, color: isDark ? Colors.white38 : Colors.grey),
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
    final double lat = _agenda?.latitude ?? _defaultLat;
    final double lng = _agenda?.longitude ?? _defaultLng;
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
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.pdm_malang.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: eventLocation,
                      width: 40, height: 40,
                      rotate: true, // PERBAIKAN: true agar tetap tegap (upright) melawan rotasi peta
                      child: const Icon(RemixIcons.map_pin_2_fill, color: Colors.red, size: 40),
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
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle), child: const Icon(RemixIcons.map_pin_2_fill, color: Colors.white, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_agenda?.location ?? 'Lokasi Acara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                      Text('2.4 km from your location', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ])),
                    GestureDetector(
                      onTap: _launchGoogleMaps,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), shape: BoxShape.circle),
                        child: const Icon(RemixIcons.navigation_fill, color: Color(0xFF1565C0), size: 20),
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
    final hasLink = (_agenda?.registrationLink ?? '').trim().isNotEmpty;
    return GestureDetector(
      onTap: hasLink ? _openRegistrationLink : null,
      child: Container(
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
          children: [
            Text(
              hasLink ? 'Daftar Sekarang' : 'Pendaftaran',
              style: const TextStyle(color: AppStyle.accent, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(RemixIcons.arrow_right_line, color: AppStyle.accent, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildConferenceTag() {
    final label = (_agenda?.categoryName ?? 'Agenda').toUpperCase();
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: AppStyle.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: Text(
        label,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppStyle.primary, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildHostedInfo() {
    final host = _agenda?.organizer?.trim() ?? 'PDM Malang';
    return Row(
      children: [
        const Icon(RemixIcons.checkbox_circle_fill, color: AppStyle.accent, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Diselenggarakan oleh $host',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeCard(BuildContext context) {
    final dateStr = _agenda?.eventDateFormatted ?? '-';
    final timeStr = _agenda?.time ?? '-';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const RadialGradient(center: Alignment.topLeft, radius: 3, colors: [Color(0xFF39A658), Color(0xFF4A6FDB), Color(0XFF071D75)], stops: [0.0, 0.3, 0.8]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            top: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/pattern.png',
                fit: BoxFit.cover,
                height: 120,
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(height: 64, child: _buildCardDate(context)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('TANGGAL & WAKTU', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(timeStr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
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
    final monthStr = _agenda?.month ?? '-';
    final dateStr = _agenda?.date ?? '-';
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
          Text(monthStr, style: TextStyle(color: textColor, fontWeight: isDark ? FontWeight.bold : FontWeight.w900, fontSize: 12)),
          Text(dateStr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(bool isDark) {
    // Nama lokasi / venue dari API
    final locationName = (_agenda?.location ?? '').trim();
    final locationDisplay = locationName.isEmpty ? '-' : locationName;

    // Kontak: gabung contact_person & contact_phone dari API
    final contactPerson = _agenda?.contactPerson?.trim();
    final contactPhone = _agenda?.contactPhone?.trim();
    final contactDisplay = [
      if ((contactPerson ?? '').isNotEmpty) contactPerson!,
      if ((contactPhone ?? '').isNotEmpty) contactPhone!,
    ].join(' • ');
    final hasContact = contactDisplay.isNotEmpty;

    // Dress code dari API (opsional)
    final dressCode = (_agenda?.dressCode ?? '').trim();
    final hasDressCode = dressCode.isNotEmpty;

    // Kuota peserta dari API (max_participants)
    final maxParticipants = _agenda?.maxParticipants;
    final hasMaxParticipants = maxParticipants != null && maxParticipants > 0;

    final rows = <Widget>[
      _infoRow(context, RemixIcons.map_pin_user_line, 'Lokasi', locationDisplay, Colors.green, isDark),
    ];
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!;
    if (hasContact) {
      rows.addAll([
        Divider(height: 32, thickness: 1, color: dividerColor),
        _infoRow(context, RemixIcons.user_voice_line, 'Kontak', contactDisplay, Colors.blue, isDark),
      ]);
    }
    if (hasDressCode) {
      rows.addAll([
        Divider(height: 32, thickness: 1, color: dividerColor),
        _infoRow(context, RemixIcons.file_list_3_line, 'Dress code', dressCode, Colors.orange, isDark),
      ]);
    }
    if (hasMaxParticipants) {
      rows.addAll([
        Divider(height: 32, thickness: 1, color: dividerColor),
        _infoRow(context, RemixIcons.user_line, 'Kuota Peserta', '$maxParticipants orang', Colors.purple, isDark),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, Color color, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark ? Colors.white54 : Colors.grey[600]!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// App bar sama persis dengan halaman Gallery (BackButtonApp + judul + subtitle + ikon).
class _DetailAgendaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAgendaAppBar({required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(80);

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
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2D3142),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Detail acara',
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
