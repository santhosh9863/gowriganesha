import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';

class AppActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback? onTap;
  final String? subtitle;

  const AppActionTile({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = iconBgColor ?? AppColors.primaryBg;
    final iconCol = iconColor ?? AppColors.primary;

    return Material(
      color: AppColors.card,
      borderRadius: AppRadius.largeBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.largeBorder,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.largeBorder,
            border: Border.all(color: AppColors.outline),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.mediumBorder,
                ),
                child: Icon(icon, size: 22, color: iconCol),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.charcoal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.warmGray500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
