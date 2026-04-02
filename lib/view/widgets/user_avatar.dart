import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/auth_user_model.dart';

class UserAvatar extends StatelessWidget {
  final AuthUser? user;
  final double size;
  final BorderRadius borderRadius;

  const UserAvatar({
    super.key,
    required this.user,
    required this.size,
    BorderRadius? borderRadius,
  }) : borderRadius = borderRadius ?? BorderRadius.zero;

  static bool _isHttpUrl(String url) {
    final u = url.trim().toLowerCase();
    return u.startsWith('http://') || u.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarUrl = user?.avatar?.trim() ?? '';
    final useNetwork = avatarUrl.isNotEmpty && _isHttpUrl(avatarUrl);

    return SizedBox(
      height: size,
      width: size,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: useNetwork
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 180),
                fadeOutDuration: Duration.zero,
                placeholder: (context, _) => _initialsFallback(colorScheme),
                errorWidget: (context, _, __) => _initialsFallback(colorScheme),
              )
            : _initialsFallback(colorScheme),
      ),
    );
  }

  Widget _initialsFallback(ColorScheme colorScheme) {
    final initials = _initialsFromName(user?.name ?? '');
    final bg = colorScheme.primaryContainer;
    final fg = colorScheme.onPrimaryContainer;

    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static String _initialsFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first.toUpperCase();
    if (parts.length == 1) return first;
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }
}
