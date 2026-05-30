import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/providers/daily_collection_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/features/daily_collections/daily_collection_tile.dart';
import 'package:ganesha_2026/shared/widgets/app_card.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
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
  final _noteController = TextEditingController();
  bool _isSaving = false;

  static const _amountChips = [1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyCollectionAsync = ref.watch(dailyCollectionsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Collections')),
      body: dailyCollectionAsync.when(
        data: (collections) =>
            _buildContent(context, ref, collections, theme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<DailyCollection> collections,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayCollections = collections.where((dc) {
      final d = dc.date.toDate();
      return d.isAfter(todayStart) && d.isBefore(todayEnd);
    }).toList();

    final todayTotal =
        todayCollections.fold<int>(0, (v, dc) => v + dc.amount);

    final earlierCollections = collections.where((dc) {
      final d = dc.date.toDate();
      return !d.isAfter(todayStart);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        _TodayTotalCard(
          total: todayTotal,
          theme: theme,
          colorScheme: colorScheme,
          fmt: _fmt,
        ),
        const SizedBox(height: 12),
        _QuickAddCard(
          amountController: _amountController,
          noteController: _noteController,
          isSaving: _isSaving,
          amountChips: _amountChips,
          onChipTap: _onChipTap,
          onRecord: _handleRecord,
          theme: theme,
          colorScheme: colorScheme,
        ),
        if (todayCollections.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionHeader(
            label: "Today's Entries",
            count: todayCollections.length,
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 4),
          ...todayCollections.map((dc) => DailyCollectionTile(
                dailyCollection: dc,
                onDelete: () => _handleDelete(context, ref, dc),
              )),
        ],
        if (earlierCollections.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionHeader(
            label: 'Earlier',
            count: earlierCollections.length,
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 4),
          ...earlierCollections.map((dc) => DailyCollectionTile(
                dailyCollection: dc,
                onDelete: () => _handleDelete(context, ref, dc),
              )),
        ],
        if (collections.isEmpty)
          AppEmptyState(
            icon: Icons.account_balance_wallet_rounded,
            title: 'No collections recorded yet',
          ),
      ],
    );
  }

  void _onChipTap(int amount) {
    _amountController.text = amount.toString();
  }

  Future<void> _handleRecord() async {
    final amountStr = _amountController.text.trim();
    final note = _noteController.text.trim();

    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount')),
      );
      return;
    }

    final amount = int.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a note')),
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
        note: note,
        date: now,
        createdAt: now,
      );
      await service.addDailyCollection(dc);

      _amountController.clear();
      _noteController.clear();
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
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final amountStr =
        '${AppConstants.currencySymbol}${formatter.format(dc.amount)}';
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
    return NumberFormat('#,##,###', 'en_IN').format(n);
  }
}

class _TodayTotalCard extends StatelessWidget {
  final int total;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _TodayTotalCard({
    required this.total,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withAlpha(80),
              borderRadius: AppRadius.cardBorder,
            ),
            child: Icon(
              Icons.today_rounded,
              color: colorScheme.secondary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Collection",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${AppConstants.currencySymbol}${fmt(total)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final bool isSaving;
  final List<int> amountChips;
  final ValueChanged<int> onChipTap;
  final VoidCallback onRecord;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _QuickAddCard({
    required this.amountController,
    required this.noteController,
    required this.isSaving,
    required this.amountChips,
    required this.onChipTap,
    required this.onRecord,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle_rounded,
                  size: 20,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Add Collection',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 5000',
                prefixText: '${AppConstants.currencySymbol} ',
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amountChips
                  .map((a) => ActionChip(
                        label: Text(
                          '${AppConstants.currencySymbol}${NumberFormat('#,##,###', 'en_IN').format(a)}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => onChipTap(a),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Source or purpose',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isSaving ? null : onRecord,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(isSaving ? 'Saving...' : 'Record Collection'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
