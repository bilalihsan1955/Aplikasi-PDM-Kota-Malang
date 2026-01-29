import 'package:flutter/material.dart';

/// =======================
/// DATA
/// =======================

final List<Map<String, String>> events = [
  {
    "month": "OCT",
    "date": "24",
    "title": "Kajian Tablogh Akbar",
    "time": "10:00 AM",
    "location": "Aula PDM Kota Malang",
  },
  {
    "month": "NOV",
    "date": "12",
    "title": "Design Sprint",
    "time": "01:00 PM",
    "location": "Meeting Room A",
  },
  {
    "month": "DEC",
    "date": "05",
    "title": "Year End Party",
    "time": "07:00 PM",
    "location": "Grand Ballroom",
  },
];

final List<Map<String, dynamic>> newsData = [
  {
    "tag": "POLICY",
    "time": "2 hours ago",
    "title": "New Remote Work Policy",
    "desc": "Updating hybrid work guidelines for flexibility.",
    "image": "assets/images/profile.png",
  },
  {
    "tag": "EVENT",
    "time": "5 hours ago",
    "title": "Annual Tech Conference",
    "desc": "Join us for the biggest tech event of the year.",
    "image": "assets/images/bg.webp",
  },
  {
    "tag": "NEWS",
    "time": "2 days ago",
    "title": "New Office Opening",
    "desc": "We are expanding to a new location in Bali.",
    "image": "assets/images/bg.webp",
  },
  {
    "tag": "UPDATE",
    "time": "1 day ago",
    "title": "System Maintenance",
    "desc": "Server downtime scheduled for this weekend.",
    "image": "assets/images/profile.png",
  },
];

final List<Map<String, dynamic>> homeMenus = [
  {'icon': Icons.apartment, 'label': 'Profil'},
  {'icon': Icons.article_outlined, 'label': 'Berita'},
  {'icon': Icons.event_outlined, 'label': 'Agenda'},
  {'icon': Icons.photo_library_outlined, 'label': 'Dokumentasi'},
  {'icon': Icons.notifications_none, 'label': 'Pengumuman'},
  {'icon': Icons.location_on_outlined, 'label': 'Lokasi'},
  {'icon': Icons.search, 'label': 'Cari'},
  {'icon': Icons.share_outlined, 'label': 'Bagikan'},
];

/// =======================
/// HOME PAGE
/// =======================

class HomePage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 24),
            const _CompanyBanner(),
            const SizedBox(height: 24),

            _EventSection(
              currentPage: _currentPage,
              onChanged: (i) => setState(() => _currentPage = i),
            ),
            const SizedBox(height: 24),
            const _HomeMenuSection(),
            const SizedBox(height: 24),
            _NewsSection(onNavigate: widget.onNavigate),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// HEADER
/// =======================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hi, Bilal Al Ihsan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Bagaimana kabarmu hari ini',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF152D8D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyBanner extends StatelessWidget {
  const _CompanyBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              /// 🔹 Background Image (lebih natural, ga terlalu zoom)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),

              /// 🔹 Dark overlay (lebih kuat di bawah)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              /// 🔹 Content
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tentang PDM Malang',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mengenal lebih dekat visi, misi, dan perjalanan organisasi kami.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================
/// EVENT SECTION
/// =======================

class _EventSection extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onChanged;

  const _EventSection({required this.currentPage, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final visibleEvents = events.length > 2 ? 2 : events.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(
            title: 'Agenda Terkini',
            // onTapAll: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const EventPage()),
            //   );
            // },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.88),
            itemCount: visibleEvents,
            onPageChanged: onChanged,
            itemBuilder: (context, index) {
              return _EventCard(
                event: events[index],
                margin: EdgeInsets.only(
                  left: index == 0 ? 24 : 8,
                  right: index == visibleEvents - 1 ? 24 : 8,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _DotsIndicator(length: visibleEvents, current: currentPage),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, String> event;
  final EdgeInsets margin;

  const _EventCard({required this.event, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 3,
          colors: [Color(0xFF26C6DA), Color(0xFF4A6FDB), Color(0XFF071D75)],
          stops: [0.0, 0.3, 0.8],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _EventDate(event: event),
          const SizedBox(width: 16),
          _EventInfo(event: event),
        ],
      ),
    );
  }
}

class _EventDate extends StatelessWidget {
  final Map<String, String> event;

  const _EventDate({required this.event});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event['month']!,
              style: const TextStyle(
                color: Color(0xFF152D8D),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              event['date']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final Map<String, String> event;

  const _EventInfo({required this.event});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event['title']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(event['time']!, style: const TextStyle(color: Colors.white)),
              Container(
                height: 12,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white54,
              ),
              Expanded(
                child: Text(
                  event['location']!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =======================
/// MENU GRID
/// =======================

class _HomeMenuSection extends StatelessWidget {
  const _HomeMenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _SectionHeader(title: 'Menu Utama'),
        ),
        SizedBox(height: 16),
        _HomeMenuGrid(),
      ],
    );
  }
}

class _HomeMenuGrid extends StatelessWidget {
  const _HomeMenuGrid();

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna tema yang sama dengan Navbar
    const Color themeColor = Color(0xFF39A658); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: homeMenus.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 0, // Jarak antar baris ditambah sedikit
          crossAxisSpacing: 16,
          childAspectRatio: 0.8, // Disesuaikan agar teks tidak terpotong
        ),
        itemBuilder: (context, index) {
          final item = homeMenus[index];

          return GestureDetector(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container Ikon yang dibuat konsisten dengan gaya Navbar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    // Menggunakan opacity yang sama lembutnya dengan navbar (0.12)
                    color: themeColor.withOpacity(0.12), 
                    borderRadius: BorderRadius.circular(20), // Sudut membulat modern
                    border: Border.all(
                      color: themeColor.withOpacity(0.1), // Border tipis agar lebih sharp
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item['icon'], 
                    color: themeColor, 
                    size: 28, // Ukuran ikon dipertegas
                  ),
                ),
                const SizedBox(height: 10),
                // Teks Menu
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3142), // Warna teks gelap yang elegan
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =======================
/// NEWS SECTION
/// =======================

class _NewsSection extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const _NewsSection({this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Berita Terkini',
            onTapAll: () {
              if (onNavigate != null) {
                onNavigate!(2); // 2 = index BeritaPage di MainScreen
              }
            },
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsData.length > 4 ? 4 : newsData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return _NewsCard(data: newsData[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _NewsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(data['image'], fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.1)),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6DCEF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        data['tag'],
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0XFF071D75),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['time'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      data['desc'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// SHARED WIDGETS
/// =======================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTapAll;

  const _SectionHeader({required this.title, this.onTapAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onTapAll,
          child: Text(
            'Semua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int length;
  final int current;

  const _DotsIndicator({required this.length, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: current == i ? 20 : 8,
          decoration: BoxDecoration(
            color: current == i
                ? const Color(0xFF152D8D)
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
