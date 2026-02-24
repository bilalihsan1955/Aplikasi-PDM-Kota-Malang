import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdm_malang/models/amal_usaha_model.dart';
import '../../../utils/app_style.dart';
import '../widgets/back_button_app.dart';
import '../widgets/navbar_widgets.dart';

class DetailAmalUsahaPage extends StatefulWidget {
  final AmalUsahaItem? item;

  const DetailAmalUsahaPage({super.key, this.item});

  @override
  State<DetailAmalUsahaPage> createState() => _DetailAmalUsahaPageState();
}

class _DetailAmalUsahaPageState extends State<DetailAmalUsahaPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppStyle.scaffoldDark : Colors.white;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final item = widget.item;

    if (item == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(RemixIcons.arrow_left_line),
            onPressed: () => context.pop(),
          ),
          title: const Text('Detail Amal Usaha'),
        ),
        body: const Center(child: Text('Data tidak tersedia')),
      );
    }

    final hasNetworkImage = item.image.isNotEmpty && item.image.startsWith('http');
    final descriptionText = _stripHtml(item.description);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      bottomNavigationBar: NavbarWidgets(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/agenda');
              break;
            case 2:
              context.go('/berita');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
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
                    child: hasNetworkImage
                        ? Image.network(
                            item.image,
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
                            errorBuilder: (_, __, ___) => _placeholderImage(isDark),
                          )
                        : _placeholderImage(isDark),
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, -40, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        32,
                        24,
                        24 + 96,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryTag(item.typeLabel),
                            if (item.logo.isNotEmpty && item.logo.startsWith('http')) ...[
                              const SizedBox(height: 20),
                              _buildLogo(item.logo, isDark),
                              const SizedBox(height: 20),
                            ] else ...[
                              const SizedBox(height: 20),
                            ],
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                color: isDark ? Colors.white : const Color(0xFF2D3142),
                              ),
                            ),
                            if (item.establishedYear != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Berdiri tahun ${item.establishedYear}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.grey[600],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            if (descriptionText.isNotEmpty)
                              Text(
                                descriptionText,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.8,
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                ),
                              ),
                          _buildKontakSection(item, isDark),
                        ],
                      ),
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
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF2D3142),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Amal Usaha',
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

  Widget _buildLogo(String logoUrl, bool isDark) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          logoUrl,
          height: 80,
          width: 80,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 80,
              width: 80,
              child: Skeletonizer(
                enabled: true,
                child: Container(
                  color: isDark ? Colors.white12 : Colors.grey[300],
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(RemixIcons.building_2_line, size: 40, color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String typeLabel) {
    final label = typeLabel.isNotEmpty ? typeLabel.toUpperCase() : 'AMAL USAHA';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppStyle.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppStyle.accent,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildKontakSection(AmalUsahaItem item, bool isDark) {
    final hasAddress = item.address.isNotEmpty;
    final hasPhone = item.phone.isNotEmpty;
    final hasEmail = item.email.isNotEmpty;
    final hasWebsite = item.website.isNotEmpty;
    final hasHead = item.headName.isNotEmpty;
    if (!hasAddress && !hasPhone && !hasEmail && !hasWebsite && !hasHead) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(
          'Kontak',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        if (hasAddress)
          _contactRow(
            icon: RemixIcons.map_pin_line,
            label: item.address,
            isDark: isDark,
          ),
        if (hasPhone) ...[
          if (hasAddress) const SizedBox(height: 12),
          _contactTile(
            icon: RemixIcons.phone_line,
            label: item.phone,
            onTap: () => _launchUrl('tel:${item.phone}'),
            isDark: isDark,
          ),
        ],
        if (hasEmail) ...[
          if (hasAddress || hasPhone) const SizedBox(height: 12),
          _contactTile(
            icon: RemixIcons.mail_line,
            label: item.email,
            onTap: () => _launchUrl('mailto:${item.email}'),
            isDark: isDark,
          ),
        ],
        if (hasWebsite) ...[
          if (hasAddress || hasPhone || hasEmail) const SizedBox(height: 12),
          _contactTile(
            icon: RemixIcons.global_line,
            label: item.website,
            onTap: () => _launchUrl(item.website.startsWith('http') ? item.website : 'https://${item.website}'),
            isDark: isDark,
          ),
        ],
        if (hasHead) ...[
          if (hasAddress || hasPhone || hasEmail || hasWebsite) const SizedBox(height: 12),
          _contactRow(
            icon: RemixIcons.user_line,
            label: item.headName,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _contactRow({required IconData icon, required String label, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppStyle.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  static String _stripHtml(String html) {
    if (html.isEmpty) return html;
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Widget _circleNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool showWhiteBg,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: showWhiteBg ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: showWhiteBg
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Icon(
          icon,
          color: showWhiteBg ? Colors.black : (isDark ? Colors.white : Colors.black87),
          size: 28,
        ),
      ),
    );
  }

  Widget _placeholderImage(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? Colors.white12 : Colors.grey[300],
      child: Icon(RemixIcons.building_2_line, size: 64, color: Colors.grey[500]),
    );
  }
}
