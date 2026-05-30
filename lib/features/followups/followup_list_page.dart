import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class FollowUpListPage extends ConsumerStatefulWidget {
  const FollowUpListPage({super.key});

  @override
  ConsumerState<FollowUpListPage> createState() => _FollowUpListPageState();
}

class _FollowUpListPageState extends ConsumerState<FollowUpListPage> {
  String _filter = 'active';

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allFollowUpsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Follow-Ups')),
      body: allAsync.when(
        data: (allItems) => _buildContent(context, allItems, theme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/followups/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SponsorFollowup> allItems,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final items = allItems.where((f) {
      if (_filter == 'active') return f.status == 'active';
      if (_filter == 'completed') return f.status == 'completed';
      return true;
    }).toList();

    return Column(
      children: [
        _FilterBar(
          filter: _filter,
          onChanged: (v) => setState(() => _filter = v),
          theme: theme,
          colorScheme: colorScheme,
        ),
        if (items.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.follow_the_signs_rounded,
                    size: 64,
                    color: colorScheme.onSurface.withAlpha(60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filter == 'completed'
                        ? 'No completed follow-ups'
                        : 'No pending follow-ups',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a follow-up',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(128),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _FollowUpCard(
                  item: item,
                  onEdit: () =>
                      context.push('/followups/${item.id}/edit'),
                  onDelete: () => _handleDelete(context, ref, item),
                  onCollected: item.status == 'active'
                      ? () => _handleCollected(context, ref, item)
                      : null,
                  theme: theme,
                  colorScheme: colorScheme,
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _handleCollected(
    BuildContext context,
    WidgetRef ref,
    SponsorFollowup item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Collection Completed?'),
        content: const Text(
          'This follow-up will be marked as completed and removed from pending follow-ups.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Collected'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final service = ref.read(firestoreProvider);
      final updated = item.copyWith(
        status: 'completed',
        completedAt: Timestamp.now(),
      );
      await service.updateFollowUp(updated);
      service.addActivity(Activity(
        id: service.generateId(),
        festivalId: AppConstants.festivalId,
        type: 'followup_completed',
        title: 'Follow-Up Completed',
        description: '${item.sponsorName} marked as collected',
        createdAt: Timestamp.now(),
      ));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Follow-up marked as completed'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                try {
                  final restored = item.copyWith(
                    status: 'active',
                    clearCompletedAt: true,
                  );
                  await service.updateFollowUp(restored);
                } on Exception {
                  // silent
                }
              },
            ),
          ),
        );
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow-up')),
        );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    SponsorFollowup item,
  ) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Follow-Up',
      message:
          'Delete follow-up for "${item.sponsorName}"? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteFollowUp(item.id);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete follow-up. Please try again.')),
        );
      }
    }
  }
}

class _FilterBar extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _FilterBar({
    required this.filter,
    required this.onChanged,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _FilterChip(
            label: 'Pending',
            selected: filter == 'active',
            onTap: () => onChanged('active'),
            color: colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completed',
            selected: filter == 'completed',
            onTap: () => onChanged('completed'),
            color: Colors.green.shade700,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'All',
            selected: filter == 'all',
            onTap: () => onChanged('all'),
            color: colorScheme.onSurfaceVariant,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final ThemeData theme;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? color : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final SponsorFollowup item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onCollected;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _FollowUpCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.onCollected,
    required this.theme,
    required this.colorScheme,
  });

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Today';
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('dd MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = item.followUpDate.toDate().isBefore(DateTime.now());
    final isActive = item.status == 'active';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isOverdue
                            ? colorScheme.errorContainer.withAlpha(80)
                            : colorScheme.primaryContainer.withAlpha(80))
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isActive
                        ? (isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.follow_the_signs_rounded)
                        : Icons.check_circle_rounded,
                    size: 22,
                    color: isActive
                        ? (isOverdue
                            ? colorScheme.error
                            : colorScheme.primary)
                        : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.sponsorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.calendar_today_rounded
                                : Icons.check_circle_rounded,
                            size: 14,
                            color: isActive
                                ? (isOverdue
                                    ? colorScheme.error
                                    : colorScheme.primary)
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive
                                ? _formatDate(item.followUpDate.toDate())
                                : 'Completed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isActive
                                  ? (isOverdue
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant)
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (item.amount != null) ...[
              const SizedBox(height: 8),
              Text(
                '₹${NumberFormat('#,##,###', 'en_IN').format(item.amount)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              item.note,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: onCollected,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Collected'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
