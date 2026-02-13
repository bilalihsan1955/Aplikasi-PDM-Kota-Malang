import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../utils/app_style.dart';

class DetailBeritaPage extends StatefulWidget {
  const DetailBeritaPage({super.key});

  @override
  State<DetailBeritaPage> createState() => _DetailBeritaPageState();
}

class _DetailBeritaPageState extends State<DetailBeritaPage> {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Menggunakan scaffoldDark agar tingkat kegelapan sama dengan halaman agenda
    final cardColor = isDark ? AppStyle.scaffoldDark : Colors.white;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Lapisan Konten Utama
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
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoryTag(),
                            const SizedBox(height: 20),
                            const Text(
                              'Q3 Financial Results: Strategic Growth in Asian Markets',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildAuthorInfo(isDark),
                            const SizedBox(height: 24),
                            Divider(color: isDark ? Colors.white10 : Colors.grey[200]),
                            const SizedBox(height: 24),
                            Text(
                              'The company today announced robust third-quarter results, driven largely by accelerated adoption of our enterprise solutions across the Asia-Pacific region.\n\nStrategic investments in digital infrastructure and a focused approach to market expansion have yielded significant returns.The company today announced robust third-quarter results, driven largely by accelerated adoption of our enterprise solutions across the Asia-Pacific region.\n\nStrategic investments in digital infrastructure and a focused approach to market expansion have yielded significant returns.The company today announced robust third-quarter results, driven largely by accelerated adoption of our enterprise solutions across the Asia-Pacific region.\n\nStrategic investments in digital infrastructure and a focused approach to market expansion have yielded significant returns.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Lapisan Header Dinamis
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _circleNavButton(
                        icon: RemixIcons.arrow_left_line,
                        onTap: () => context.pop(),
                        showWhiteBg: !_isScrolled,
                        isDark: isDark,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isScrolled ? 1 : 0,
                          child: const Text(
                            'Berita Terkini',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _circleNavButton(
                        icon: RemixIcons.share_line,
                        onTap: () {},
                        showWhiteBg: !_isScrolled,
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
        child: Icon(
          icon, 
          color: showWhiteBg ? Colors.black : (isDark ? Colors.white : Colors.black87), 
          size: 20
        ),
      ),
    );
  }

  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppStyle.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Text(
        'CORPORATE', 
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppStyle.accent, letterSpacing: 0.8)
      ),
    );
  }

  Widget _buildAuthorInfo(bool isDark) {
    return Row(
      children: [
        const CircleAvatar(radius: 20, backgroundImage: AssetImage('assets/images/profile.png')),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sarah Jenkins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1A1F36))),
            const Text('24 Oct 2023 • 4 min read', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
