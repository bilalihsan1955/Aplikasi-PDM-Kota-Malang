import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdm_malang/models/organization_model.dart';
import 'package:pdm_malang/services/api_service.dart';
import 'package:pdm_malang/services/organization_api_service.dart';
import '../../../utils/app_style.dart';
import '../widgets/back_button_app.dart';

class AboutPdmPage extends StatefulWidget {
  const AboutPdmPage({super.key});

  @override
  State<AboutPdmPage> createState() => _AboutPdmPageState();
}

class _AboutPdmPageState extends State<AboutPdmPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  OrganizationProfileModel? _profile;
  List<OrganizationStructureModel> _structure = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20) {
        if (!_isScrolled) setState(() => _isScrolled = true);
      } else {
        if (_isScrolled) setState(() => _isScrolled = false);
      }
    });
    final cached = OrganizationApiService.getCached();
    if (cached != null && (cached.profile != null || cached.structure.isNotEmpty)) {
      setState(() {
        _profile = cached.profile;
        _structure = cached.structure;
        _loading = false;
        _error = null;
      });
    } else {
      _loadData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final isFirstLoad = _profile == null && _structure.isEmpty;
    if (isFirstLoad) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final api = OrganizationApiService();
    final results = await Future.wait([api.getProfile(), api.getStructure()]);
    if (!mounted) return;
    final profileResult = results[0] as OrganizationProfileResult;
    final structureResult = results[1] as OrganizationStructureResult;
    setState(() {
      _loading = false;
      _profile = profileResult.data;
      _structure = structureResult.data;
      if (!profileResult.success && !structureResult.success) {
        _error = profileResult.message.isNotEmpty ? profileResult.message : structureResult.message;
      } else if (!profileResult.success) {
        _error = profileResult.message;
      } else if (!structureResult.success) {
        _error = structureResult.message;
      } else {
        _error = null;
      }
    });
  }

  Future<void> _launchGoogleMaps() async {
    const lat = -7.949630143095969;
    const lng = 112.60867657182543;
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppStyle.scaffoldDark : Colors.white;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    if (_loading && _profile == null && _structure.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _loadData,
          displacement: 40,
          color: Theme.of(context).colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Skeletonizer(
              enabled: true,
              child: _buildAboutPageSkeleton(isDark, cardColor),
            ),
          ),
        ),
      );
    }

    if (_error != null && _error!.isNotEmpty && _profile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _loadData,
          displacement: 40,
          color: Theme.of(context).colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RemixIcons.wifi_off_line, size: 56, color: isDark ? Colors.white24 : Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text('Oops!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2D3142))),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white60 : Colors.grey[600])),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => _loadData(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFF152D8D), borderRadius: BorderRadius.circular(24)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Icon(RemixIcons.refresh_line, size: 18, color: Colors.white), SizedBox(width: 8), Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final profile = _profile;
    final name = profile?.name ?? 'Pimpinan Daerah Muhammadiyah Kota Malang';
    final shortName = profile?.shortName ?? 'PDM Kota Malang';
    final description = _stripHtml(profile?.description.isNotEmpty == true
        ? profile!.description
        : 'Muhammadiyah adalah Gerakan Islam, Dakwah Amar Ma\'ruf Nahi Munkar dan Tajdid, bersumber pada Al-Qur\'an dan As-Sunnah.');
    // Gambar dari response: data.logo (contoh: "https://makotamu.org/storage/logo.png")
    final logoUrl = _resolveLogoUrl(profile?.logo ?? '');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _loadData,
              displacement: 40,
              color: Theme.of(context).colorScheme.primary,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                child: Column(
                  children: [
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: logoUrl.isNotEmpty && logoUrl.startsWith('http')
                          ? Image.network(
                              logoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Skeletonizer(
                                  enabled: true,
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: isDark ? Colors.white12 : Colors.grey[300],
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => _buildStaticLogoImage(),
                            )
                          : _buildStaticLogoImage(),
                    ),
                    Container(
                      transform: Matrix4.translationValues(0, -40, 0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SafeArea(
                            top: false,
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCategoryTag(),
                                  const SizedBox(height: 20),
                                  Text(
                                    name,
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    description,
                                    style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildSejarahSection(isDark, profile != null ? _stripHtml(profile.history) : null),
                                  const SizedBox(height: 32),
                                  const Text('Visi & Misi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  _buildVisiMisiCard(isDark, profile != null ? _stripHtml(profile.vision) : null, profile != null ? _stripHtml(profile.mission) : null),
                                  const SizedBox(height: 32),
                                  const Text('Struktur Kepengurusan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStrukturList(isDark, _structure),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 32),
                                const Text('Program Kerja Unggulan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _buildProgramList(isDark),
                                const SizedBox(height: 32),
                                _buildContactSection(isDark, profile),
                                const SizedBox(height: 32),
                                _buildLocationHeader(),
                                const SizedBox(height: 16),
                                _buildMapPreview(isDark, address: profile?.address, title: shortName),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isScrolled ? appBarColor : Colors.transparent,
                boxShadow: _isScrolled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: SafeArea(
                bottom: false,
                child: _isScrolled
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 16),
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
                                          'Tentang PDM Malang',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF2D3142),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Profil organisasi',
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
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            _circleNavButton(
                              icon: RemixIcons.arrow_left_line,
                              onTap: () => context.pop(),
                              showWhiteBg: true,
                              isDark: isDark,
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

  static String _stripHtml(String html) {
    if (html.isEmpty) return html;
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Ambil URL gambar logo dari response: jika sudah full URL pakai as-is, jika path relatif gabung dengan origin API.
  static String _resolveLogoUrl(String logo) {
    if (logo.isEmpty) return '';
    if (logo.startsWith('http://') || logo.startsWith('https://')) return logo;
    try {
      final base = ApiService.baseUrl;
      final origin = Uri.parse(base).origin;
      final path = logo.startsWith('/') ? logo : '/$logo';
      return '$origin$path';
    } catch (_) {
      return logo;
    }
  }

  Widget _buildLogoPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? Colors.white12 : Colors.grey[300],
      child: Icon(
        RemixIcons.community_fill,
        size: 80,
        color: isDark ? Colors.white24 : Colors.grey[400],
      ),
    );
  }

  /// Gambar statis jika data logo dari response tidak ada atau gagal load.
  Widget _buildStaticLogoImage() {
    return Image.asset(
      'assets/images/banner.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _buildLogoPlaceholder(Theme.of(context).brightness == Brightness.dark),
    );
  }

  Widget _buildAboutPageSkeleton(bool isDark, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 400,
          width: double.infinity,
          color: isDark ? Colors.white12 : Colors.grey[300],
        ),
        Container(
          transform: Matrix4.translationValues(0, -40, 0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100)),
                  child: const Text('PROFIL ORGANISASI', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ),
                const SizedBox(height: 20),
                Container(height: 28, width: 280, color: Colors.grey[300]),
                const SizedBox(height: 24),
                Container(height: 16, width: double.infinity, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 16, width: double.infinity, color: Colors.grey[300]),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 120, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Container(height: 14, width: double.infinity, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Container(height: 14, width: double.infinity, color: Colors.grey[400]),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(height: 18, width: 100, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Container(height: 48, width: double.infinity, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Container(height: 48, width: double.infinity, color: Colors.grey[300]),
                const SizedBox(height: 32),
                Container(height: 18, width: 160, color: Colors.grey[300]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, __) => Container(
                      width: 160,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(height: 18, width: 180, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Wrap(spacing: 10, runSpacing: 10, children: List.generate(4, (_) => Container(height: 40, width: 140, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12))))),
                const SizedBox(height: 32),
                Container(height: 18, width: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(height: 44, width: 44, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Container(height: 44, width: 44, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Container(height: 44, width: 44, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 32),
                Container(height: 18, width: 120, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Container(height: 280, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(bool isDark, OrganizationProfileModel? profile) {
    final hasPhone = (profile?.phone ?? '').trim().isNotEmpty;
    final hasEmail = (profile?.email ?? '').trim().isNotEmpty;
    final hasWebsite = (profile?.website ?? '').trim().isNotEmpty;
    final sm = profile?.socialMedia;
    final hasSocial = (sm?.instagram ?? sm?.facebook ?? sm?.youtube ?? sm?.twitter) != null;

    if (!hasPhone && !hasEmail && !hasWebsite && !hasSocial) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kontak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (hasPhone)
          _contactTile(
            icon: RemixIcons.phone_line,
            label: profile!.phone,
            onTap: () => _launchUrl('tel:${profile.phone}'),
            isDark: isDark,
          ),
        if (hasEmail) ...[
          if (hasPhone) const SizedBox(height: 12),
          _contactTile(
            icon: RemixIcons.mail_line,
            label: profile!.email,
            onTap: () => _launchUrl('mailto:${profile.email}'),
            isDark: isDark,
          ),
        ],
        if (hasWebsite) ...[
          if (hasPhone || hasEmail) const SizedBox(height: 12),
          _contactTile(
            icon: RemixIcons.global_line,
            label: profile!.website,
            onTap: () => _launchUrl(profile.website.startsWith('http') ? profile.website : 'https://${profile.website}'),
            isDark: isDark,
          ),
        ],
        if (hasSocial) ...[
          if (hasPhone || hasEmail || hasWebsite) const SizedBox(height: 16),
          Text('Media sosial', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (sm!.instagram != null && sm.instagram!.isNotEmpty)
                _socialButton(RemixIcons.instagram_line, sm.instagram!, isDark),
              if (sm.facebook != null && sm.facebook!.isNotEmpty)
                _socialButton(RemixIcons.facebook_fill, sm.facebook!, isDark),
              if (sm.youtube != null && sm.youtube!.isNotEmpty)
                _socialButton(RemixIcons.youtube_line, sm.youtube!, isDark),
              if (sm.twitter != null && sm.twitter!.isNotEmpty)
                _socialButton(RemixIcons.twitter_x_line, sm.twitter!, isDark),
            ],
          ),
        ],
      ],
    );
  }

  Widget _contactTile({required IconData icon, required String label, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppStyle.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87))),
            Icon(RemixIcons.arrow_right_s_line, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String url, bool isDark) {
    return GestureDetector(
      onTap: () => _launchUrl(url.startsWith('http') ? url : 'https://$url'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(14),
          border: isDark ? Border.all(color: Colors.white12) : null,
        ),
        child: Icon(icon, size: 24, color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  /// Buka URL di aplikasi eksternal (browser, telepon, email, app media sosial).
  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback: coba mode default jika external gagal
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Lokasi Kantor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: _launchGoogleMaps,
          child: const Text('View Map', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildMapPreview(bool isDark, {String? address, String? title}) {
    const LatLng officeLocation = LatLng(-7.949650126353061, 112.60868403249327);
    final locationTitle = title?.isNotEmpty == true ? title! : 'Kantor PDM Kota Malang';
    final locationAddress = address?.trim().isNotEmpty == true ? address! : 'Jl. Gajayana No. 28, Malang';

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
              options: const MapOptions(
                initialCenter: officeLocation,
                initialZoom: 16.0,
                interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.pdm_malang.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: officeLocation,
                      width: 40,
                      height: 40,
                      rotate: true,
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
                      child: const Icon(RemixIcons.map_pin_2_fill, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locationTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                          Text(locationAddress, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                    ),
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

  Widget _circleNavButton({required IconData icon, required VoidCallback onTap, required bool showWhiteBg, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: showWhiteBg ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: showWhiteBg ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Icon(icon, color: showWhiteBg ? Colors.black : (isDark ? Colors.white : Colors.black87), size: 28),
      ),
    );
  }

  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: AppStyle.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
      child: const Text('PROFIL ORGANISASI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.accent, letterSpacing: 0.8)),
    );
  }

  Widget _buildSejarahSection(bool isDark, String? history) {
    final raw = history?.trim().isNotEmpty == true
        ? history!
        : 'PDM Kota Malang telah berkontribusi sejak era kolonial dalam memajukan pendidikan dan kesehatan masyarakat di wilayah Malang Raya.';
    final text = _stripHtml(raw);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sejarah Singkat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVisiMisiCard(bool isDark, String? vision, String? mission) {
    final visiText = vision?.trim().isNotEmpty == true
        ? vision!
        : 'Terwujudnya masyarakat Islam yang sebenar-benarnya melalui dakwah berkemajuan.';
    final misiText = mission?.trim().isNotEmpty == true
        ? mission!
        : 'Meningkatkan kualitas SDM dan menguatkan peran sosial organisasi.';
    return Column(
      children: [
        _visiMisiItem(RemixIcons.star_line, 'Visi', visiText, isDark),
        const SizedBox(height: 12),
        _visiMisiItem(RemixIcons.rocket_2_line, 'Misi', misiText, isDark),
      ],
    );
  }

  Widget _visiMisiItem(IconData icon, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppStyle.accent, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrukturList(bool isDark, List<OrganizationStructureModel> structure) {
    final list = structure.where((s) => s.isActive).toList();
    if (list.isEmpty) {
      return const SizedBox(height: 80, child: Center(child: Text('Belum ada data struktur', style: TextStyle(color: Colors.grey, fontSize: 14))));
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final s = list[index];
          return Container(
            width: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (s.photo.startsWith('http'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      s.photo,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const CircleAvatar(radius: 28, backgroundColor: AppStyle.primary, child: Icon(RemixIcons.user_3_fill, color: Colors.white)),
                    ),
                  )
                else
                  const CircleAvatar(radius: 28, backgroundColor: AppStyle.primary, child: Icon(RemixIcons.user_3_fill, color: Colors.white)),
                const SizedBox(height: 12),
                Text(s.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(s.position, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                if (s.division.isNotEmpty) Text(s.division, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgramList(bool isDark) {
    final programs = ['Pendidikan Karakter', 'Layanan Kesehatan Umat', 'Pemberdayaan Ekonomi', 'Dakwah Digital'];
    return Wrap(spacing: 10, runSpacing: 10, children: programs.map((p) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isDark ? AppStyle.cardDark : const Color(0xFFF1F4F9), borderRadius: BorderRadius.circular(12), border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null),
      child: Text(p, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppStyle.accent : Colors.black87)),
    )).toList());
  }
}
