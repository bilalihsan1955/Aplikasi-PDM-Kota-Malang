import 'package:flutter/material.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  String selectedFilter = 'Semua';
  String searchQuery = '';
  bool isSearching = false;

  // List kategori yang disamakan style-nya dengan Berita
  final List<String> timeFilters = [
    'Semua',
    'Minggu Ini',
    'Bulan Ini',
    'Akan Datang',
  ];

  final List<Map<String, dynamic>> allAgendas = [
    {
      'title': 'Rapat Evaluasi Bulanan',
      'location': 'Ruang Meeting Lt. 2',
      'date': '28',
      'month': 'JAN',
      'time': '09:00 - 11:00 WIB',
      'category': 'Minggu Ini',
    },
    {
      'title': 'Workshop Public Speaking',
      'location': 'Aula Utama',
      'date': '02',
      'month': 'FEB',
      'time': '13:00 - 16:00 WIB',
      'category': 'Minggu Ini',
    },
    {
      'title': 'Kunjungan Industri',
      'location': 'PT. Teknologi Maju',
      'date': '15',
      'month': 'FEB',
      'time': '08:00 - 15:00 WIB',
      'category': 'Bulan Ini',
    },
    {
      'title': 'Gathering Nasional',
      'location': 'Hotel Grand Asia',
      'date': '10',
      'month': 'MAR',
      'time': '08:00 - 20:00 WIB',
      'category': 'Akan Datang',
    },
  ];

  List<Map<String, dynamic>> get filteredAgendas {
    return allAgendas.where((item) {
      final matchTag = selectedFilter == 'Semua' || item['category'] == selectedFilter;
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
            Positioned.fill(child: _agendaList()),
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

  // ================= HEADER (IDENTIK DENGAN BERITA) =================
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
            _categoryChips(), // Bagian yang disamakan
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
              'Agenda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Jadwal kegiatan mendatang',
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
      padding: const EdgeInsets.only(left: 12),
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
              decoration: const InputDecoration(
                hintText: 'Cari agenda...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              isSearching = false;
              searchQuery = '';
            }),
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ================= CHOICE CHIPS (STYLE BERITA) =================
  Widget _categoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: timeFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = timeFilters[index];
          final isActive = filter == selectedFilter;

          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive 
                    ? const Color(0xFF152D8D) // Navy sesuai Berita
                    : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
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

  // ================= LIST VIEW & EMPTY STATE =================
  Widget _agendaList() {
    double topPadding = MediaQuery.of(context).padding.top + 160;
    double bottomPadding = MediaQuery.of(context).padding.bottom + 24;

    if (filteredAgendas.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Align(
          alignment: const Alignment(0, -0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/empty_state/not_found.png',
                width: 160,
                height: 160,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
              ),
              const Text(
                'Agenda Tidak Ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Maaf, kami tidak menemukan jadwal yang Anda cari.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              if (searchQuery.isNotEmpty || selectedFilter != 'Semua')
                GestureDetector(
                  onTap: () => setState(() {
                    searchQuery = '';
                    selectedFilter = 'Semua';
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
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: topPadding, left: 24, right: 24, bottom: bottomPadding),
      itemCount: filteredAgendas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _AgendaCard(data: filteredAgendas[index]),
    );
  }
}

// ================= CARD DESIGN (MODERN SQUARE) =================
class _AgendaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _AgendaCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F4F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071D75).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 1. TANGGAL (Persegi Sempurna)
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E6F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['month'],
                    style: const TextStyle(
                      color: Color(0xFF071D75),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    data['date'],
                    style: const TextStyle(
                      color: Color(0xFF071D75),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 2. KONTEN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data['time'],
                    style: const TextStyle(
                      color: Color(0xFF39A658),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1A202C),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data['location'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 24),
          ],
        ),
      ),
    );
  }
}