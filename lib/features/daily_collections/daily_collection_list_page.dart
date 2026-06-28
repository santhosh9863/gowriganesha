import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/daily_collection_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/features/daily_collections/daily_collection_tile.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_metric_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_section_header.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class DailyCollectionListPage extends ConsumerStatefulWidget {
  const DailyCollectionListPage({super.key});

  @override
  ConsumerState<DailyCollectionListPage> createState() =>
      _DailyCollectionListPageState();
}

class _DailyCollectionListPageState
    extends ConsumerState<DailyCollectionListPage> {
  final _amountController = TextEditingController();
  bool _isSaving = false;

  static const _amountChips = [1000, 2000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    debugPrint('[LIFECYCLE] DailyCollectionListPage.initState');
  }

  @override
  void dispose() {
    debugPrint('[LIFECYCLE] DailyCollectionListPage.dispose');
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] DailyCollectionListPage.build');
    final dailyCollectionAsync = ref.watch(dailyCollectionsStreamProvider);
    final role = ref.watch(roleProvider);
    final theme = Theme.of(context);
    final showAdd = role == UserRole.admin;

    return AppPageScaffold(
      festivalName: 'Daily Collections',
      onSettings: () => context.push('/settings'),
      onAdd: showAdd ? () => context.push('/daily-collections/add') : null,
      bottomNavHeight: 56,
      child: dailyCollectionAsync.when(
        data: (collections) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dailyCollectionsStreamProvider);
          },
          child: _buildContent(context, ref, collections, theme, role),
        ),
        loading: () => const AppSkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<DailyCollection> _todayItems(List<DailyCollection> all) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return all.where((dc) {
      final d = dc.date.toDate();
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();
  }

  List<DailyCollection> _yesterdayItems(List<DailyCollection> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 1));
    final end = today;
    return all.where((dc) {
      final d = dc.date.toDate();
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();
  }

  List<DailyCollection> _earlierItems(List<DailyCollection> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    return all.where((dc) {
      final d = dc.date.toDate();
      return d.isBefore(yesterday);
    }).toList();
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<DailyCollection> collections,
    ThemeData theme,
    UserRole role,
  ) {
    final now = DateTime.now();
    final todayItems = _todayItems(collections);
    final yesterdayItems = _yesterdayItems(collections);
    final earlierItems = _earlierItems(collections);

    final todayTotal = todayItems.fold<int>(0, (v, dc) => v + dc.amount);
    final todayCount = todayItems.length;
    final avgCollection = todayCount > 0 ? (todayTotal / todayCount).round() : 0;
    final largest = todayItems.fold<int>(0, (v, dc) => v > dc.amount ? v : dc.amount);

    final hasToday = todayItems.isNotEmpty;
    final hasYesterday = yesterdayItems.isNotEmpty;
    final hasEarlier = earlierItems.isNotEmpty;
    final hasAny = collections.isNotEmpty;

    if (hasAny) {
      for (final dc in collections) {
        final d = dc.date.toDate();
        final inToday = !d.isBefore(DateTime(now.year, now.month, now.day)) &&
            d.isBefore(DateTime(now.year, now.month, now.day).add(const Duration(days: 1)));
        final inYesterday = !d.isBefore(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1))) &&
            d.isBefore(DateTime(now.year, now.month, now.day));
        final inEarlier = d.isBefore(DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)));
        debugPrint('[DATE_BUCKET] amount=${dc.amount} date=$d → today=$inToday yesterday=$inYesterday earlier=$inEarlier');
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 72),
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
                      label: "Today's Collection",
                      value: '${AppConstants.currencySymbol}${_fmt(todayTotal)}',
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Entries',
                      value: '$todayCount',
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.info,
                      iconBgColor: AppColors.infoBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Average',
                      value: '${AppConstants.currencySymbol}${_fmt(avgCollection)}',
                      icon: Icons.calculate_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Largest',
                      value: '${AppConstants.currencySymbol}${_fmt(largest)}',
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.success,
                      iconBgColor: AppColors.successBg,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (role == UserRole.admin)
          // Quick add
          Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.largeBorder,
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: AppRadius.mediumBorder,
                      ),
                      child: const Icon(
                        Icons.add_circle_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Record Collection',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [IndianAmountInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'e.g. 5,000',
                    prefixText: '${AppConstants.currencySymbol} ',
                    filled: true,
                    fillColor: AppColors.warmGray50,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mediumBorder,
                      borderSide: BorderSide(color: AppColors.outline),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _amountChips.map((a) => _AmountChip(
                    amount: a,
                    isSelected: _amountController.text == fmtAmount(a),
                    onTap: () {
                      _amountController.text = fmtAmount(a);
                    },
                    theme: theme,
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _isSaving ? null : () => _handleRecord(ref),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_isSaving ? 'Saving...' : 'Record Collection'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Section: Today
        if (hasToday) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: 'Today',
              subtitle: '$todayCount entries',
            ),
          ),
          ...todayItems.map((dc) => DailyCollectionTile(
                dailyCollection: dc,
                onDelete: () => _handleDelete(context, ref, dc),
              )),
        ],
        // Section: Yesterday
        if (hasYesterday) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: 'Yesterday',
              subtitle: '${yesterdayItems.length} entries',
            ),
          ),
          ...yesterdayItems.map((dc) => DailyCollectionTile(
                dailyCollection: dc,
                onDelete: () => _handleDelete(context, ref, dc),
              )),
        ],
        // Section: Earlier
        if (hasEarlier) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: 'Earlier',
              subtitle: '${earlierItems.length} entries',
            ),
          ),
          ...earlierItems.map((dc) => DailyCollectionTile(
                dailyCollection: dc,
                onDelete: () => _handleDelete(context, ref, dc),
              )),
        ],
        // Empty state
        if (!hasAny)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxxl),
            child: AppEmptyState(
              icon: Icons.account_balance_wallet_rounded,
              title: 'No collections recorded yet',
              subtitle: 'Use the form above to record your first collection',
            ),
          ),
      ],
    );
  }

  Future<void> _handleRecord(WidgetRef ref) async {
    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) return;
    final amount = tryParseAmount(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(firestoreProvider);
      final now = Timestamp.now();
      final dc = DailyCollection(
        id: service.generateId(),
        festivalId: AppConstants.festivalId,
        amount: amount,
        note: '',
        date: now,
        createdAt: now,
      );
      await service.addDailyCollection(dc);

      _amountController.clear();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    DailyCollection dc,
  ) async {
    final amountStr = '${AppConstants.currencySymbol}${fmtAmount(dc.amount)}';
    final dateStr = DateFormat('dd MMM yyyy').format(dc.date.toDate());
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Collection',
      message:
          'Delete collection of $amountStr from $dateStr? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteDailyCollection(dc.id);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Failed to delete collection. Please try again.')),
        );
      }
    }
  }

  String _fmt(int n) {
    return fmtAmount(n);
  }
}

class _AmountChip extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _AmountChip({
    required this.amount,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBg
              : Colors.transparent,
          borderRadius: AppRadius.mediumBorder,
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.outline,
          ),
        ),
        child: Text(
          '${AppConstants.currencySymbol}${fmtAmount(amount)}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.warmGray500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
