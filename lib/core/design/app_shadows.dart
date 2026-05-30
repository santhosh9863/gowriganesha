import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const _color = Color(0x1A000000);
  static const _colorMedium = Color(0x0D000000);

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: _color,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get soft => [
        BoxShadow(
          color: _color,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: _colorMedium,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: _color,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get none => [];
}
