import 'package:flutter/material.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTapAll;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onTapAll,
  });

  @override
  Widget build(BuildContext context) {
    const Color appBlue = Color(0xFF152D8D);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),
        TextButton(
          onPressed: onTapAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: appBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Semua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : appBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeDotsIndicator extends StatelessWidget {
  final int length;
  final int current;

  const HomeDotsIndicator({
    super.key,
    required this.length,
    required this.current,
  });

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
