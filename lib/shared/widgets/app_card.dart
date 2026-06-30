import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/shared/widgets/press_animator.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      color: color,
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );

    if (onTap == null) return card;

    return PressAnimator(
      onTap: onTap,
      borderRadius: AppRadius.cardBorder,
      child: card,
    );
  }
}
