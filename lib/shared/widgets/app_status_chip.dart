import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';

enum AppChipVariant { success, warning, error, info, neutral, accent }

class AppStatusChip extends StatelessWidget {
  final String label;
  final AppChipVariant variant;
  final IconData? icon;

  const AppStatusChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color dot) = _colors;

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) get _colors => switch (variant) {
        AppChipVariant.success => (
            AppColors.successBg,
            AppColors.success,
            AppColors.success,
          ),
        AppChipVariant.warning => (
            AppColors.warningBg,
            AppColors.warning,
            AppColors.warning,
          ),
        AppChipVariant.error => (
            AppColors.errorBg,
            AppColors.error,
            AppColors.error,
          ),
        AppChipVariant.info => (
            AppColors.infoBg,
            AppColors.info,
            AppColors.info,
          ),
        AppChipVariant.accent => (
            AppColors.accentBg,
            AppColors.accent,
            AppColors.accent,
          ),
        AppChipVariant.neutral => (
            AppColors.warmGray100,
            AppColors.warmGray600,
            AppColors.warmGray400,
          ),
      };
}
