import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        TextTheme(
          // Display — 36px, Bold
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.3,
          ),
          displaySmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: -0.2,
          ),

          // Headline — 22–24px, SemiBold
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            letterSpacing: -0.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.35,
            letterSpacing: -0.1,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),

          // Title — 14–16px, Medium/SemiBold
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),

          // Body — 13–15px, Regular
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),

          // Label — 11–12px, Medium
          labelLarge: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0.1,
          ),
          labelMedium: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0.1,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0.15,
          ),
        ),
      );
}
