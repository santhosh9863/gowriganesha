import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // Named tier system
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double hero = 24;
  static const double full = 999;

  // Border radius shortcuts
  static BorderRadius get smallBorder => BorderRadius.circular(small);
  static BorderRadius get mediumBorder => BorderRadius.circular(medium);
  static BorderRadius get largeBorder => BorderRadius.circular(large);
  static BorderRadius get heroBorder => BorderRadius.circular(hero);

  // Backward compatibility aliases (deprecated — used by existing screens)
  static const double card = 16;
  static const double button = 12;
  static const double bottomSheet = 20;
  static const double chip = 20;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get bottomSheetBorder => BorderRadius.circular(bottomSheet);
  static BorderRadius get chipBorder => BorderRadius.circular(chip);
}
