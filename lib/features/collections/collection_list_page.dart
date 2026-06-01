import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/features/collections/collection_tile.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_metric_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/app_stagger.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class CollectionListPage extends ConsumerStatefulWidget {
  const CollectionListPage({super.key});

  @override
  ConsumerState<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends ConsumerState<CollectionListPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'all';
  bool _initialized = false;
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _staggerCtrl.forward());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final filter = GoRouterState.of(context).uri.queryParameters['filter'];
      if (filter == 'pending') _filter = 'pending';
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(targetsStreamProvider);
    final theme = Theme.of(context);

    return AppPageScaffold(
      festivalName: 'Sponsors',
      onSettings: () => context.push('/settings'),
      onAdd: () => context.push('/collections/add'),
      showAdd: true,
      bottomNavHeight: 56,
      child: targetsAsync.when(
        data: (targets) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(targetsStreamProvider);
          },
          child: _buildList(context, ref, targets, theme),
        ),
        loading: () => const AppSkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<Target> _filterTargets(List<Target> targets) {
    var result = targets;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.name.toLowerCase().contains(q) ||
            t.building.toLowerCase().contains(q) ||
            t.area.toLowerCase().contains(q);
      }).toList();
    }
    if (_filter == 'pending') {
      result = result.where((t) => t.givenAmount < t.expectedAmount).toList();
    } else if (_filter == 'collected') {
      result = result.where((t) => t.givenAmount >= t.expectedAmount).toList();
    }
    return result;
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Target> targets,
    ThemeData theme,
  ) {
    final totalSponsors = targets.length;
    final collectedSponsors = targets.where((t) => t.givenAmount >= t.expectedAmount).length;
    final pendingSponsors = targets.where((t) => t.givenAmount < t.expectedAmount).length;
    final expectedTotal = targets.fold<int>(0, (v, t) => v + t.expectedAmount);
    final collectedTotal = targets.fold<int>(0, (v, t) => v + t.givenAmount);
    final remainingTotal = expectedTotal - collectedTotal;

    final filtered = _filterTargets(targets);

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Summary metrics 2x2
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = (constraints.maxWidth - AppSpacing.sm) / 2;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Total Sponsors',
                      value: '$totalSponsors',
                      icon: Icons.people_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Achieved',
                      value: '$collectedSponsors',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      iconBgColor: AppColors.successBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Active',
                      value: '$pendingSponsors',
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'To Reach',
                      value: '${AppConstants.currencySymbol}${_fmt(remainingTotal)}',
                      icon: Icons.trending_down_rounded,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.errorBg,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search sponsors...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.warmGray50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.outline),
              ),
            ),
          ),
        ),
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
                color: AppColors.warmGray500,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Active',
                selected: _filter == 'pending',
                onTap: () => setState(() => _filter = 'pending'),
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Achieved',
                selected: _filter == 'collected',
                onTap: () => setState(() => _filter = 'collected'),
                color: AppColors.success,
              ),
            ],
          ),
        ),
        // List or empty state
        if (filtered.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: AppEmptyState(
                icon: targets.isEmpty
                    ? Icons.people_outline_rounded
                    : Icons.search_off_rounded,
                title: targets.isEmpty
                    ? 'No sponsors yet'
                    : 'No sponsors match "$_searchQuery"',
                subtitle: targets.isEmpty
                    ? 'Tap + to add your first sponsor'
                    : null,
                action: targets.isEmpty
                    ? FilledButton.icon(
                        onPressed: () => context.push('/collections/add'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Sponsor'),
                      )
                    : null,
              ),
            ),
          )
        else
          ...List.generate(filtered.length, (index) {
            final target = filtered[index];
            return AppStagger(
              index: index,
              controller: _staggerCtrl,
              child: SponsorCard(
                target: target,
                onDelete: () => _handleDelete(context, ref, target),
                onQuickUpdate: () =>
                    _handleQuickUpdate(context, ref, target),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _handleQuickUpdate(
      BuildContext context, WidgetRef ref, Target target) async {
    final controller =
        TextEditingController(text: target.givenAmount.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Record Contribution'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Commitment: ₹${_fmt(target.expectedAmount)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                  labelText: 'Amount Raised',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final v = int.tryParse(controller.text.trim());
                if (v != null && v >= 0) {
                  Navigator.pop(context, v);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result == target.givenAmount) return;

    try {
      final service = ref.read(firestoreProvider);
      final updated = target.copyWith(
        givenAmount: result,
        updatedAt: Timestamp.now(),
      );
      await service.updateTarget(updated);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update amount')),
        );
      }
    }
  }

  Future<void> _handleDelete(
      BuildContext context, WidgetRef ref, Target target) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Sponsor',
      message: 'Delete "${target.name}"? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteTarget(target.id);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete sponsor. Please try again.')),
        );
      }
    }
  }

  String _fmt(int n) {
    final fmt = NumberFormat('#,##,###', 'en_IN');
    return fmt.format(n);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.3) : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? color : AppColors.warmGray500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
