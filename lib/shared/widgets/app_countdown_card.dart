import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/shared/services/festival_countdown_service.dart';

class AppCountdownCard extends StatelessWidget {
  final FestivalCountdownResult? countdown;

  const AppCountdownCard({super.key, this.countdown});

  @override
  Widget build(BuildContext context) {
    if (countdown == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final result = countdown!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          _icon(theme),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  result.formattedDate,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warmGray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(ThemeData theme) {
    IconData icon;
    Color color;

    if (countdown!.isPast) {
      icon = Icons.check_circle_outline_rounded;
      color = AppColors.warmGray400;
    } else if (countdown!.daysRemaining <= 13) {
      icon = Icons.event_rounded;
      color = AppColors.warning;
    } else {
      icon = Icons.calendar_month_rounded;
      color = AppColors.primary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: AppRadius.mediumBorder,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
