import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';

class SankalpaGlass extends StatelessWidget {
  final Widget child;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final Color? tintColor;
  final List<BoxShadow>? boxShadow;

  const SankalpaGlass({
    super.key,
    required this.child,
    this.opacity = 0.85,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.tintColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.mediumBorder;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: (tintColor ?? Colors.white).withValues(alpha: opacity),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
