import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_style.dart';

class AboutPdmPage extends StatefulWidget {
  const AboutPdmPage({super.key});

  @override
  State<AboutPdmPage> createState() => _AboutPdmPageState();
}

class _AboutPdmPageState extends State<AboutPdmPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50) {
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: Image.asset('assets/images/banner.png', fit: BoxFit.cover),
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
                                const Text(
                                  'Pimpinan Daerah Muhammadiyah Kota Malang',
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Muhammadiyah adalah Gerakan Islam, Dakwah Amar Ma\'ruf Nahi Munkar dan Tajdid, bersumber pada Al-Qur\'an dan As-Sunnah.',
                                  style: TextStyle(fontSize: 16, height: 1.8, color: Colors.grey),
                                ),
                                const SizedBox(height: 32),
                                _buildSejarahSection(isDark),
                                const SizedBox(height: 32),
                                const Text('Visi & Misi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _buildVisiMisiCard(isDark),
                                const SizedBox(height: 32),
                                const Text('Struktur Kepengurusan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStrukturList(isDark),
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
                                _buildLocationHeader(),
                                const SizedBox(height: 16),
                                _buildMapPreview(isDark),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _isScrolled ? appBarColor : Colors.transparent,
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
                      _circleNavButton(
                        icon: RemixIcons.arrow_left_s_line,
                        onTap: () => context.pop(),
                        showWhiteBg: !_isScrolled,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isScrolled ? 1 : 0,
                          child: const Text(
                            'Tentang PDM Malang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
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
        const Text('Lokasi Kantor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: _launchGoogleMaps,
          child: const Text('View Map', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildMapPreview(bool isDark) {
    const LatLng officeLocation = LatLng(-7.9666, 112.6326);

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
                  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.pdm_malang.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: officeLocation,
                      width: 40, height: 40,
                      rotate: true, // PERBAIKAN: true agar tetap tegak lurus melawan rotasi peta
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
                          Text('Kantor PDM Kota Malang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                          Text('Jl. Gajayana No. 28, Malang', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
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

  Widget _buildSejarahSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Sejarah Singkat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            'PDM Kota Malang telah berkontribusi sejak era kolonial dalam memajukan pendidikan dan kesehatan masyarakat di wilayah Malang Raya.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVisiMisiCard(bool isDark) {
    return Column(
      children: [
        _visiMisiItem(RemixIcons.star_line, 'Visi', 'Terwujudnya masyarakat Islam yang sebenar-benarnya melalui dakwah berkemajuan.', isDark),
        const SizedBox(height: 12),
        _visiMisiItem(RemixIcons.rocket_2_line, 'Misi', 'Meningkatkan kualitas SDM dan menguatkan peran sosial organisasi.', isDark),
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

  Widget _buildStrukturList(bool isDark) {
    final pengurus = [('Prof. Dr. KH. Abdul Haris', 'Ketua Umum'), ('Dr. H. Nurul Murtadho', 'Sekretaris'), ('H. Zainullah, M.Ag', 'Bendahara')];
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: pengurus.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => Container(
          width: 160, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircleAvatar(radius: 24, backgroundColor: AppStyle.primary, child: Icon(RemixIcons.user_3_fill, color: Colors.white)),
            const SizedBox(height: 12),
            Text(pengurus[index].$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2),
            Text(pengurus[index].$2, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),
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
