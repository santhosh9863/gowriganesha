import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';

enum _SnackType { success, error, info, warning }

extension AppSnackBar on BuildContext {
  void showSuccess(String message, {SnackBarAction? action}) {
    _show(message, _SnackType.success, action: action);
  }

  void showError(String message, {SnackBarAction? action}) {
    _show(message, _SnackType.error, action: action);
  }

  void showInfo(String message, {SnackBarAction? action}) {
    _show(message, _SnackType.info, action: action);
  }

  void showWarning(String message, {SnackBarAction? action}) {
    _show(message, _SnackType.warning, action: action);
  }

  void _show(String message, _SnackType type, {SnackBarAction? action}) {
    final (Color bg, Color fg, Color border) = switch (type) {
      _SnackType.success => (AppColors.successBg, AppColors.success, AppColors.success),
      _SnackType.error => (AppColors.errorBg, AppColors.error, AppColors.error),
      _SnackType.info => (AppColors.infoBg, AppColors.info, AppColors.info),
      _SnackType.warning => (AppColors.warningBg, AppColors.warning, AppColors.warning),
    };
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: fg, fontWeight: FontWeight.w500)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorder,
          side: BorderSide(color: border.withValues(alpha: 0.3)),
        ),
        action: action,
      ),
    );
  }
}
