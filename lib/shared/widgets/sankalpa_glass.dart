import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';

class SankalpaGlass extends StatelessWidget {
  final Widget child;
  final double sigma;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final Color? tintColor;
  final List<BoxShadow>? boxShadow;

  const SankalpaGlass({
    super.key,
    required this.child,
    this.sigma = 10,
    this.opacity = 0.85,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.tintColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.mediumBorder,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (tintColor ?? Colors.white).withValues(alpha: opacity),
            borderRadius: borderRadius ?? AppRadius.mediumBorder,
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
