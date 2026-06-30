import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/shared/widgets/app_page_header.dart';

class AppPageScaffold extends ConsumerStatefulWidget {
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
  final bool showNotifications;

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
    this.showNotifications = true,
  });

  @override
  ConsumerState<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends ConsumerState<AppPageScaffold> {
  @override
  void initState() {
    super.initState();
    debugPrint('[DIAG:AppPageScaffold] initState key=${widget.key}');
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('[DIAG:AppPageScaffold] deactivate key=${widget.key}');
  }

  @override
  void dispose() {
    debugPrint('[DIAG:AppPageScaffold] dispose key=${widget.key}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DIAG:AppPageScaffold] build key=${widget.key}');
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final showFab = widget.onAdd != null && !keyboardOpen;
    final fab = showFab
        ? AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              child: FloatingActionButton(
                onPressed: widget.onAdd,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          )
        : null;

    final page = Scaffold(
      key: const ValueKey('app_page_scaffold'),
      backgroundColor: AppColors.surface,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _horizontalPad(context),
                  AppSpacing.xl,
                  _horizontalPad(context),
                  0,
                ),
                child: Row(
                  children: [
                    if (widget.showBack)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
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
                      child: widget.header ??
                          (widget.showGreeting
                              ? AppPageHeader(
                                  greeting: widget.greeting,
                                  festivalName: widget.festivalName,
                                  date: widget.date,
                                  onSettings: widget.onSettings,
                                  onAdd: widget.onAdd,
                                  onFilter: widget.onFilter,
                                  onSearch: widget.onSearch,
                                  showSettings: widget.showSettings,
                                  showAdd: widget.showAdd,
                                  showFilter: widget.showFilter,
                                  showSearch: widget.showSearch,
                                  showNotifications: widget.showNotifications,
                                )
                              : Text(
                                  widget.festivalName ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: AppColors.charcoal),
                                )),
                    ),
                  ],
                ),
              ),
            if (widget.showHeader) const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );

    return page;
  }

  Widget _buildBody() {
    var body = widget.padding != null
        ? Padding(padding: widget.padding!, child: widget.child)
        : widget.child;

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => widget.onRefresh?.call(),
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
