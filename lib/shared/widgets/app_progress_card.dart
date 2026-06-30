import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/shared/widgets/press_animator.dart';

class AppProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final Color? progressColor;
  final Color? trackColor;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    this.progressColor,
    this.trackColor,
    this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progColor = progressColor ?? AppColors.primary;
    final trkColor = trackColor ?? AppColors.warmGray100;

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: progColor.withAlpha(25),
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: Icon(icon, size: 16, color: progColor),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGray500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: trkColor,
              color: progColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return PressAnimator(
      onTap: onTap,
      borderRadius: AppRadius.largeBorder,
      child: card,
    );
  }
}
