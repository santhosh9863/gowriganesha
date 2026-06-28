import 'package:flutter/material.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/shared/widgets/app_greeting_section.dart';
import 'package:ganesha_2026/shared/widgets/app_page_actions.dart';

class AppPageHeader extends StatelessWidget {
  final String? greeting;
  final String? festivalName;
  final String? date;
  final Widget? actions;
  final VoidCallback? onSettings;
  final VoidCallback? onAdd;
  final VoidCallback? onFilter;
  final VoidCallback? onSearch;
  final bool showSettings;
  final bool showAdd;
  final bool showFilter;
  final bool showSearch;
  final bool showNotifications;

  const AppPageHeader({
    super.key,
    this.greeting,
    this.festivalName,
    this.date,
    this.actions,
    this.onSettings,
    this.onAdd,
    this.onFilter,
    this.onSearch,
    this.showSettings = true,
    this.showAdd = false,
    this.showFilter = false,
    this.showSearch = false,
    this.showNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppGreetingSection(
            greeting: greeting,
            festivalName: festivalName ?? 'Sri Gowri Ganesha Festival',
            date: date,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        actions ??
            AppPageActions(
              onSettings: onSettings,
              onAdd: onAdd,
              onFilter: onFilter,
              onSearch: onSearch,
              showSettings: showSettings,
              showAdd: showAdd,
              showFilter: showFilter,
              showSearch: showSearch,
              showNotifications: showNotifications,
            ),
      ],
    );
  }
}
