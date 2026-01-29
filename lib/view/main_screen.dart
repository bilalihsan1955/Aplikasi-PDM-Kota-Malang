import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdm_malang/view/widgets/navbar_widgets.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        } else {
          // Jika sudah di Home, biarkan sistem menangani back (biasanya keluar aplikasi)
          // Kita bisa menggunakan SystemNavigator.pop() jika ingin memaksa keluar
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFC),
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: NavbarWidgets(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
