import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/app_card.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/app_stagger.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class FollowUpListPage extends ConsumerStatefulWidget {
  const FollowUpListPage({super.key});

  @override
  ConsumerState<FollowUpListPage> createState() => _FollowUpListPageState();
}

class _FollowUpListPageState extends ConsumerState<FollowUpListPage>
    with SingleTickerProviderStateMixin {
  String _filter = 'active';
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
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allFollowUpsStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Follow-Ups')),
      body: allAsync.when(
        data: (allItems) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allFollowUpsStreamProvider);
          },
          child: _buildContent(context, allItems, theme, colorScheme),
        ),
        loading: () => const AppSkeletonList(),
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
      return f.status == 'completed';
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Active'),
                selected: _filter == 'active',
                onSelected: (_) => setState(() => _filter = 'active'),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilterChip(
                label: const Text('Completed'),
                selected: _filter == 'completed',
                onSelected: (_) => setState(() => _filter = 'completed'),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Expanded(
            child: AppEmptyState(
              icon: Icons.follow_the_signs_rounded,
              title: _filter == 'completed'
                  ? 'No completed follow-ups'
                  : 'No pending follow-ups',
              subtitle: 'Tap + to add a follow-up',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0, bottom: 80),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return AppStagger(
                  index: index,
                  controller: _staggerCtrl,
                  child: _FollowUpCard(
                    item: item,
                    onEdit: () =>
                        context.push('/followups/${item.id}/edit'),
                    onDelete: () => _handleDelete(context, ref, item),
                    onCollected: item.status == 'active'
                        ? () => _handleCollected(context, ref, item)
                        : null,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
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
                    service.addActivity(Activity(
                      id: service.generateId(),
                      festivalId: AppConstants.festivalId,
                      type: 'followup_undo',
                      title: 'Completion Undone',
                      description: '${item.sponsorName} follow-up restored',
                      createdAt: Timestamp.now(),
                    ));
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = item.followUpDate.toDate();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = dueDay.isBefore(today);
    final isDueToday = dueDay == today;
    final isActive = item.status == 'active';

    Color statusColor;
    IconData statusIcon;
    if (!isActive) {
      statusColor = const Color(0xFF22C55E);
      statusIcon = Icons.check_circle_rounded;
    } else if (isOverdue) {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.warning_amber_rounded;
    } else if (isDueToday) {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.notifications_active_rounded;
    } else {
      statusColor = const Color(0xFF3B82F6);
      statusIcon = Icons.follow_the_signs_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: AppRadius.cardBorder,
                  ),
                  child: Icon(statusIcon, size: 22, color: statusColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.sponsorName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive && isOverdue) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                          if (isActive && isDueToday) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DUE TODAY',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFFF59E0B),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            isActive
                                ? Icons.calendar_today_rounded
                                : Icons.check_circle_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            isActive
                                ? _formatDate(dueDate)
                                : 'Completed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isActive && onCollected != null)
                  GestureDetector(
                    onTap: onCollected,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Collect',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
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
              const SizedBox(height: AppSpacing.sm),
              AmountText(
                amount: item.amount!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
