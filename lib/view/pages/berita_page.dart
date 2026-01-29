import 'package:flutter/material.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  String selectedTag = 'Semua';
  String searchQuery = '';
  bool isSearching = false;

  final List<String> categories = [
    'Semua',
    'News',
    'Event',
    'Info',
    'Update',
    'Info',
    'Update',
  ];

  final List<Map<String, dynamic>> allNews = [
    {
      'tag': 'News',
      'time': '2 jam lalu',
      'title': 'Kantor Cabang Baru Dibuka',
      'desc': 'Peresmian kantor cabang baru...',
      'image': 'assets/images/bg.webp',
    },
    {
      'tag': 'Event',
      'time': '5 jam lalu',
      'title': 'Kajian Akbar Bulanan',
      'desc': 'Kajian bersama tokoh nasional.',
      'image': 'assets/images/profile.png',
    },
    {
      'tag': 'Info',
      'time': '1 hari lalu',
      'title': 'Libur Nasional',
      'desc': 'Penyesuaian jadwal kegiatan.',
      'image': 'assets/images/bg.webp',
    },
    {
      'tag': 'Update',
      'time': '2 hari lalu',
      'title': 'Pembaruan Sistem',
      'desc': 'Optimalisasi performa.',
      'image': 'assets/images/profile.png',
    },
    {
      'tag': 'News',
      'time': '3 jam lalu',
      'title': 'Rapat Kerja Wilayah',
      'desc': 'Koordinasi tahunan pengurus.',
      'image': 'assets/images/bg.webp',
    },
    {
      'tag': 'Info',
      'time': '4 hari lalu',
      'title': 'Update Keanggotaan',
      'desc': 'Pendaftaran kartu anggota baru.',
      'image': 'assets/images/profile.png',
    },
  ];

  List<Map<String, dynamic>> get filteredNews {
    return allNews.where((item) {
      final matchTag =
          selectedTag.toLowerCase() == 'semua' ||
          item['tag'].toString().toLowerCase() == selectedTag.toLowerCase();
      final matchSearch = item['title'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchTag && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFC),
        body: Stack(
          children: [
            Positioned.fill(child: _newsGrid()),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCombinedHeader(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMBINED HEADER =================
  Widget _buildCombinedHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            _buildAnimatedHeader(),
            const SizedBox(height: 16),
            _categoryChips(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isSearching ? _searchBar() : _headerTitle(),
      ),
    );
  }

  Widget _headerTitle() {
    return Row(
      key: const ValueKey('headerTitle'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Berita',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Informasi terbaru untuk anda',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => setState(() => isSearching = true),
          icon: const Icon(Icons.search, size: 28, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      key: const ValueKey('searchField'),
      height: 50,
      padding: const EdgeInsets.only(left: 12, right: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(fontSize: 14),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Cari judul berita...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  isSearching = false;
                  searchQuery = '';
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.close, size: 20, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tag = categories[index];
          final isActive = tag == selectedTag;

          return GestureDetector(
            onTap: () => setState(() => selectedTag = tag),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF152D8D)
                    : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _newsGrid() {
    double topPadding = MediaQuery.of(context).padding.top + 160;
    double bottomPadding = MediaQuery.of(context).padding.bottom + 24;

    if (filteredNews.isEmpty) {
  return Padding(
    padding: EdgeInsets.only(top: topPadding),
    child: Align(
      alignment: const Alignment(0, -0.4), 
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/empty_state/not_found.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
            const Text(
              'Berita Tidak Ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'Maaf, kami tidak menemukan berita yang Anda cari.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (searchQuery.isNotEmpty || selectedTag != 'Semua')
              GestureDetector(
                onTap: () => setState(() {
                  searchQuery = '';
                  selectedTag = 'Semua';
                  isSearching = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF152D8D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Atur Ulang Filter',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

    return GridView.builder(
      padding: EdgeInsets.only(
        top: topPadding,
        left: 24,
        right: 24,
        bottom: bottomPadding,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredNews.length,
      itemBuilder: (context, index) => _NewsCard(data: filteredNews[index]),
    );
  }
}

// ================= NEW CARD DESIGN WITH TAG =================
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
            color: Colors.black.withOpacity(0.1), // Shadow pekat sesuai Home
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BAGIAN GAMBAR (Flex 4)
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    data['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[200]),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.1),
                  ), // Overlay tipis sesuai Home
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1EBDD),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        data['tag']
                            .toString()
                            .toUpperCase(), // Ubah ke UpperCase sesuai data Home
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11683B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BAGIAN TEKS (Flex 3)
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
                      fontSize: 15, // Ukuran font spesifik Home
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Deskripsi menggunakan flex lagi untuk handle overflow
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
