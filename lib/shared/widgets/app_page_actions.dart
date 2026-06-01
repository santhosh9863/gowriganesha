import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';

class AppPageActions extends StatelessWidget {
  final VoidCallback? onSettings;
  final VoidCallback? onAdd;
  final VoidCallback? onFilter;
  final VoidCallback? onSearch;
  final bool showSettings;
  final bool showAdd;
  final bool showFilter;
  final bool showSearch;

  const AppPageActions({
    super.key,
    this.onSettings,
    this.onAdd,
    this.onFilter,
    this.onSearch,
    this.showSettings = true,
    this.showAdd = false,
    this.showFilter = false,
    this.showSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAdd && onAdd != null) ...[
          _ActionButton(
            icon: Icons.add_rounded,
            onTap: onAdd,
            tooltip: 'Add',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (showFilter && onFilter != null) ...[
          _ActionButton(
            icon: Icons.filter_list_rounded,
            onTap: onFilter,
            tooltip: 'Filter',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (showSearch && onSearch != null) ...[
          _ActionButton(
            icon: Icons.search_rounded,
            onTap: onSearch,
            tooltip: 'Search',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (showSettings && onSettings != null)
          _ActionButton(
            icon: Icons.settings_rounded,
            onTap: onSettings,
            tooltip: 'Settings',
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outline),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22, color: AppColors.warmGray500),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        splashRadius: 24,
      ),
    );
  }
}
