import 'package:flutter/material.dart';
import 'package:pdm_malang/view/pages/agenda_page.dart';
import 'package:pdm_malang/view/pages/berita_page.dart';
import 'package:pdm_malang/view/pages/home_page.dart';
import 'package:pdm_malang/view/pages/profile_page.dart';
import 'package:pdm_malang/view/widgets/navbar_widgets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Daftar halaman
    final List<Widget> _pages = [
      HomePage(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const AgendaPage(),
      const BeritaPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavbarWidgets(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
