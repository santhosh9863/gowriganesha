import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double button = 12;
  static const double bottomSheet = 20;
  static const double chip = 20;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get bottomSheetBorder => BorderRadius.circular(bottomSheet);
  static BorderRadius get chipBorder => BorderRadius.circular(chip);
}
