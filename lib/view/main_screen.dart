import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pdm_malang/view/widgets/navbar_widgets.dart';
import 'package:pdm_malang/view_models/auth_view_model.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final hideBottomNav = path.endsWith('/webview');

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
      child: Consumer<AuthViewModel>(
        builder: (context, authVm, _) {
          final isSubmitting = authVm.isSubmitting;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final overlayColor = isDark
              ? Colors.black.withOpacity(0.40)
              : Colors.black.withOpacity(0.20);

          return Stack(
            children: [
              Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                extendBody: true,
                body: AbsorbPointer(
                  absorbing: isSubmitting,
                  child: navigationShell,
                ),
                bottomNavigationBar: hideBottomNav
                    ? null
                    : AbsorbPointer(
                        absorbing: isSubmitting,
                        child: NavbarWidgets(
                          currentIndex: navigationShell.currentIndex,
                          onTap: (index) {
                            // Tab Home: langsung go ke '/' agar stack bersih (no flicker jadwal-sholat/menu)
                            if (index == 0) {
                              context.go('/');
                              return;
                            }
                            navigationShell.goBranch(
                              index,
                              initialLocation: true,
                            );
                          },
                        ),
                      ),
              ),
              if (isSubmitting)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: overlayColor,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
