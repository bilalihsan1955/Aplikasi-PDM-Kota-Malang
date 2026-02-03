import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_style.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Selamat Datang di PDM Malang',
      'description': 'Platform digital resmi Pimpinan Daerah Muhammadiyah Kota Malang untuk informasi dan koordinasi umat.',
      'image': 'assets/images/banner.png',
    },
    {
      'title': 'Agenda & Kegiatan',
      'description': 'Pantau terus jadwal kegiatan, tabligh akbar, dan agenda organisasi secara real-time dan terstruktur.',
      'image': 'assets/images/banner.png',
    },
    {
      'title': 'Berita Terkini',
      'description': 'Dapatkan informasi terbaru seputar dakwah, pendidikan, dan amal usaha Muhammadiyah di Kota Malang.',
      'image': 'assets/images/banner.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) => _OnboardingContent(
              title: _onboardingData[index]['title']!,
              description: _onboardingData[index]['description']!,
              image: _onboardingData[index]['image']!,
            ),
          ),
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => _buildDot(index),
                  ),
                ),
                const SizedBox(height: 40),
                _buildButton(context),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 24,
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'Lewati',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppStyle.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: AppStyle.primary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    bool isLastPage = _currentPage == _onboardingData.length - 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Style Gradient Identik dengan _EventCard di HomePage
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 6,
          colors: [Color(0xFF39A658), Color(0xFF4A6FDB), Color(0XFF071D75)],
          stops: [0.0, 0.4, 0.9],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppStyle.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isLastPage) {
              context.go('/login');
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'Mulai Sekarang' : 'Lanjutkan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final String title, description, image;

  const _OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppStyle.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
