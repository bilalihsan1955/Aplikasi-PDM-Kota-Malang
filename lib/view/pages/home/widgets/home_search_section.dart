import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

class HomeSearchSection extends StatelessWidget {
  const HomeSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/menu', extra: {'openSearch': true}),
        child: Hero(
          tag: 'menu_search',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE8ECF4),
                  width: 1,
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    RemixIcons.search_line,
                    size: 22,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cari menu, layanan, informasi...',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white38 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
