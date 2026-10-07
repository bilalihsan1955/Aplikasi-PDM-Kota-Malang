import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdm_malang/models/auth_user_model.dart';
import 'package:pdm_malang/services/auth/auth_local_service.dart';
import 'package:pdm_malang/view/widgets/user_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthLocalService.cachedUserNotifier,
      builder: (context, user, _) {
        final name = user?.name.trim();
        final displayName = (name == null || name.isEmpty) ? 'Pengguna' : name;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $displayName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      'Bagaimana kabarmu hari ini',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF152D8D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: UserAvatar(
                    user: user,
                    size: 50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
