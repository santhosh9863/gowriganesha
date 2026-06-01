import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/shared/widgets/app_page_header.dart';

class AppPageScaffold extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showHeader;
  final String? greeting;
  final String? festivalName;
  final String? date;
  final Widget? header;
  final VoidCallback? onRefresh;
  final VoidCallback? onSettings;
  final VoidCallback? onAdd;
  final VoidCallback? onFilter;
  final VoidCallback? onSearch;
  final bool showSettings;
  final bool showAdd;
  final bool showFilter;
  final bool showSearch;
  final bool showBack;
  final VoidCallback? onBack;
  final double bottomNavHeight;
  final bool showGreeting;

  const AppPageScaffold({
    super.key,
    required this.child,
    this.padding,
    this.showHeader = true,
    this.greeting,
    this.festivalName,
    this.date,
    this.header,
    this.onRefresh,
    this.onSettings,
    this.onAdd,
    this.onFilter,
    this.onSearch,
    this.showSettings = true,
    this.showAdd = false,
    this.showFilter = false,
    this.showSearch = false,
    this.showBack = false,
    this.onBack,
    this.bottomNavHeight = 0,
    this.showGreeting = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final showFab = onAdd != null && !keyboardOpen;
    final fab = showFab
        ? FloatingActionButton(
            onPressed: onAdd,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_rounded, size: 28),
          )
        : null;

    final page = Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _horizontalPad(context),
                  AppSpacing.xl,
                  _horizontalPad(context),
                  0,
                ),
                child: Row(
                  children: [
                    if (showBack)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: onBack ?? () => Navigator.of(context).pop(),
                          tooltip: 'Back',
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.card,
                            side: BorderSide(color: AppColors.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          iconSize: 18,
                        ),
                      ),
                    Expanded(
                      child: header ??
                          (showGreeting
                              ? AppPageHeader(
                                  greeting: greeting,
                                  festivalName: festivalName,
                                  date: date,
                                  onSettings: onSettings,
                                  onAdd: onAdd,
                                  onFilter: onFilter,
                                  onSearch: onSearch,
                                  showSettings: showSettings,
                                  showAdd: showAdd,
                                  showFilter: showFilter,
                                  showSearch: showSearch,
                                )
                              : Text(
                                  festivalName ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: AppColors.charcoal),
                                )),
                    ),
                  ],
                ),
              ),
            if (showHeader) const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildBody(showFab)),
          ],
        ),
      ),
    );

    return page;
  }

  Widget _buildBody(bool showFab) {
    var body = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    if (showFab) {
      body = Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: body,
      );
    }

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh?.call(),
        child: body,
      );
    }

    return body;
  }

  double _horizontalPad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w > 900 ? AppSpacing.xxxl : AppSpacing.lg;
  }
}
