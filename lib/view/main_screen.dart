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
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (navigationShell.currentIndex != 0 && context.canPop() == false) {
          navigationShell.goBranch(0, initialLocation: true);
        } else {
          // Jika sudah di Home, biarkan sistem menangani back (biasanya keluar aplikasi)
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: NavbarWidgets(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            // Memastikan selalu kembali ke halaman utama tab (root) saat Navbar ditekan
            navigationShell.goBranch(
              index,
              initialLocation: true,
            );
          },
        ),
      ),
    );
  }
}
