import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';

class AppAvatarBadge extends StatelessWidget {
  final String initials;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double fontSize;
  final Widget? badge;
  final String? label;
  final VoidCallback? onTap;

  const AppAvatarBadge({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 40,
    this.fontSize = 14,
    this.badge,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryBg;
    final fg = foregroundColor ?? AppColors.primary;

    final circle = CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: Text(
        initials.length > 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final avatar = badge != null
        ? Badge(
            label: badge,
            child: circle,
          )
        : circle;

    if (label == null && onTap == null) return avatar;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        if (label != null) ...[
          const SizedBox(width: 10),
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.charcoal,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: content,
    );
  }
}
