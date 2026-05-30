import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/features/collections/collection_tile.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class CollectionListPage extends ConsumerStatefulWidget {
  const CollectionListPage({super.key});

  @override
  ConsumerState<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends ConsumerState<CollectionListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(targetsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      body: targetsAsync.when(
        data: (targets) =>
            _buildList(context, ref, targets, theme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/collections/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  List<Target> _filterTargets(List<Target> targets) {
    if (_searchQuery.isEmpty) return targets;
    final q = _searchQuery.toLowerCase();
    return targets.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.building.toLowerCase().contains(q) ||
          t.area.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Target> targets,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final expectedTotal =
        targets.fold<int>(0, (v, t) => v + t.expectedAmount);
    final collectedTotal =
        targets.fold<int>(0, (v, t) => v + t.givenAmount);
    final remainingTotal = expectedTotal - collectedTotal;

    final filtered = _filterTargets(targets);

    return Column(
      children: [
        _SummaryBar(
          expectedTotal: expectedTotal,
          collectedTotal: collectedTotal,
          remainingTotal: remainingTotal,
          theme: theme,
          colorScheme: colorScheme,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by name, building or area...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
            ),
          ),
        ),
        if (filtered.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                targets.isEmpty
                    ? 'No sponsors yet'
                    : 'No sponsors match "$_searchQuery"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final target = filtered[index];
                return CollectionTile(
                  target: target,
                  onDelete: () => _handleDelete(context, ref, target),
                  onQuickUpdate: () =>
                      _handleQuickUpdate(context, ref, target),
                );
              },
            ),
          ),
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
          title: const Text('Update Received Amount'),
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
                'Expected: ₹${_fmt(target.expectedAmount)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Received Amount',
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

class _SummaryBar extends StatelessWidget {
  final int expectedTotal;
  final int collectedTotal;
  final int remainingTotal;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _SummaryBar({
    required this.expectedTotal,
    required this.collectedTotal,
    required this.remainingTotal,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Expected',
              amount: expectedTotal,
              color: colorScheme.primary,
              theme: theme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              label: 'Collected',
              amount: collectedTotal,
              color: colorScheme.tertiary,
              theme: theme,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              label: 'Remaining',
              amount: remainingTotal,
              color: remainingTotal > 0
                  ? colorScheme.error
                  : Colors.green.shade700,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final ThemeData theme;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            AmountText(
              amount: amount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
