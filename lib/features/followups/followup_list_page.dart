import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/utils/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_metric_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_section_header.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/app_status_chip.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class FollowUpListPage extends ConsumerStatefulWidget {
  const FollowUpListPage({super.key});

  @override
  ConsumerState<FollowUpListPage> createState() => _FollowUpListPageState();
}

class _FollowUpListPageState extends ConsumerState<FollowUpListPage> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('[LIFECYCLE] FollowUpListPage.initState');
  }

  @override
  void dispose() {
    debugPrint('[LIFECYCLE] FollowUpListPage.dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] FollowUpListPage.build');
    final allAsync = ref.watch(allFollowUpsStreamProvider);
    final theme = Theme.of(context);

    return AppPageScaffold(
      festivalName: 'Visits',
      onSettings: () => context.push('/settings'),
      onAdd: () => context.push('/followups/add'),
      showAdd: true,
      bottomNavHeight: 56,
      child: allAsync.when(
        data: (allItems) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allFollowUpsStreamProvider);
          },
          child: _buildContent(context, ref, allItems, theme),
        ),
        loading: () => const AppSkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<SponsorFollowup> allItems,
    ThemeData theme,
  ) {
    final role = ref.watch(roleProvider);
    final showAdminActions = canEditRecords(role) || canDelete(role);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overdue = allItems.where((f) {
      if (f.status != 'active') return false;
      final d = f.followUpDate.toDate();
      return DateTime(d.year, d.month, d.day).isBefore(today);
    }).toList()..sort((a, b) => a.followUpDate.compareTo(b.followUpDate));

    final dueToday = allItems.where((f) {
      if (f.status != 'active') return false;
      final d = f.followUpDate.toDate();
      return DateTime(d.year, d.month, d.day) == today;
    }).toList()..sort((a, b) => a.followUpDate.compareTo(b.followUpDate));

    final upcoming = allItems.where((f) {
      if (f.status != 'active') return false;
      final d = f.followUpDate.toDate();
      return DateTime(d.year, d.month, d.day).isAfter(today);
    }).toList()..sort((a, b) => a.followUpDate.compareTo(b.followUpDate));

    final completed = allItems.where((f) => f.status == 'completed').toList()
      ..sort((a, b) {
        final aDt = a.completedAt ?? a.createdAt;
        final bDt = b.completedAt ?? b.createdAt;
        return bDt.compareTo(aDt);
      });

    final hasAny = allItems.isNotEmpty;

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
                      label: 'Overdue',
                      value: '${overdue.length}',
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.errorBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Due Today',
                      value: '${dueToday.length}',
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Upcoming',
                      value: '${upcoming.length}',
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.warmGray500,
                      iconBgColor: AppColors.warmGray100,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Completed',
                      value: '${completed.length}',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      iconBgColor: AppColors.successBg,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Tab chips
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              _TabChip(
                label: 'Pending',
                count: allItems.length - completed.length,
                selected: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0),
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              _TabChip(
                label: 'Completed',
                count: completed.length,
                selected: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1),
                color: AppColors.success,
              ),
            ],
          ),
        ),
        // Pending sections
        if (_tabIndex == 0) ...[
          if (overdue.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: AppSectionHeader(
                title: 'Overdue',
                subtitle: '${overdue.length} pending',
              ),
            ),
            ...overdue.map((f) => _FollowUpCard(
                  item: f,
                  onEdit: () => context.push('/followups/${f.id}/edit'),
                  onDelete: () => _handleDelete(context, ref, f),
                  onCollected: () => _handleCollected(context, ref, f),
                  theme: theme,
                  showAdminActions: showAdminActions,
                )),
          ],
          if (dueToday.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: AppSectionHeader(
                title: 'Today',
                subtitle: '${dueToday.length} items',
              ),
            ),
            ...dueToday.map((f) => _FollowUpCard(
                  item: f,
                  onEdit: () => context.push('/followups/${f.id}/edit'),
                  onDelete: () => _handleDelete(context, ref, f),
                  onCollected: () => _handleCollected(context, ref, f),
                  theme: theme,
                  showAdminActions: showAdminActions,
                )),
          ],
          if (upcoming.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: AppSectionHeader(
                title: 'Upcoming',
                subtitle: '${upcoming.length} scheduled',
              ),
            ),
            ...upcoming.map((f) => _FollowUpCard(
                  item: f,
                  onEdit: () => context.push('/followups/${f.id}/edit'),
                  onDelete: () => _handleDelete(context, ref, f),
                  onCollected: () => _handleCollected(context, ref, f),
                  theme: theme,
                  showAdminActions: showAdminActions,
                )),
          ],
        ],
        // Completed section
        if (_tabIndex == 1 && completed.isNotEmpty) ...[
          ...completed.map((f) => _FollowUpCard(
                item: f,
                onEdit: () => context.push('/followups/${f.id}/edit'),
                onDelete: () => _handleDelete(context, ref, f),
                theme: theme,
                showAdminActions: showAdminActions,
              )),
        ],
        // Empty state
        if (!hasAny)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxxl),
            child: AppEmptyState(
              icon: Icons.follow_the_signs_rounded,
              title: 'No visits yet',
              subtitle: 'Tap + to create your first visit',
              action: FilledButton.icon(
                onPressed: () => context.push('/followups/add'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Visit'),
              ),
            ),
          ),
        // Empty pending state
        if (hasAny && _tabIndex == 0 && allItems.length == completed.length)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxxl),
            child: AppEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'All caught up!',
              subtitle: 'No pending visits',
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
          'This visit will be marked as completed and removed from pending.',
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
      final activityService = ref.read(activityServiceProvider);
      final userId = ref.read(userIdProvider);
      final userName = ref.read(userNameProvider);
      await activityService.recordFollowUpCompleted(updated, userId: userId, userName: userName);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      context.showSuccess('Visit marked as completed', action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                try {
                  final restored = item.copyWith(
                    status: 'active',
                    clearCompletedAt: true,
                  );
                  await service.updateFollowUp(restored);
                  await service.addActivity(Activity(
                    id: service.generateId(),
                    festivalId: AppConstants.festivalId,
                    type: 'followup_undo',
                    title: 'Completion Undone',
                    description: 'Visit restored for ${item.sponsorName}',
                    createdAt: Timestamp.now(),
                    recordId: item.id,
                    entityType: 'sponsor_followup',
                  ));
                } on Exception {
                  // silent
                }
              },
            ),
        );
    } on Exception {
      if (context.mounted) {
        context.showError('Failed to update visit');
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
      title: 'Delete Visit',
      message:
          'Delete visit for "${item.sponsorName}"? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteFollowUp(item.id);
    } on Exception {
      if (context.mounted) {
        context.showError('Failed to delete visit. Please try again.');
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
  final bool showAdminActions;

  const _FollowUpCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.onCollected,
    required this.theme,
    this.showAdminActions = false,
  });

  String _relDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Today';
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('d MMM').format(d);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}';
    return name.isNotEmpty ? name[0] : '?';
  }

  String _relTime(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'yesterday';
    if (d.inDays < 30) return '${d.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = item.followUpDate.toDate();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = item.status == 'active' && dueDay.isBefore(today);
    final isDueToday = item.status == 'active' && dueDay == today;
    final isComplete = item.status == 'completed';

    final Color accentColor;
    final AppChipVariant chipVariant;
    String statusLabel;

    if (isComplete) {
      accentColor = AppColors.success;
      chipVariant = AppChipVariant.success;
      statusLabel = 'Completed';
    } else if (isOverdue) {
      accentColor = AppColors.error;
      chipVariant = AppChipVariant.error;
      statusLabel = 'Overdue';
    } else if (isDueToday) {
      accentColor = AppColors.warning;
      chipVariant = AppChipVariant.warning;
      statusLabel = 'Due Today';
    } else {
      accentColor = AppColors.warmGray500;
      chipVariant = AppChipVariant.neutral;
      statusLabel = 'Upcoming';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(color: AppColors.outline),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.large),
                    bottomLeft: Radius.circular(AppRadius.large),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Avatar + Name + Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.mediumBorder,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(item.sponsorName),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.sponsorName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppColors.charcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: AppColors.warmGray400,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_relDate(dueDate)}${isComplete && item.completedAt != null ? ' (${_relTime(item.completedAt!.toDate())})' : ''}',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: AppColors.warmGray400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AppStatusChip(
                            label: statusLabel,
                            variant: chipVariant,
                          ),
                        ],
                      ),
                      // Notes preview
                      if (item.note.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.note,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warmGray500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Amount (if present)
                      if (item.amount != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${AppConstants.currencySymbol}${fmtAmount(item.amount!)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      // Quick actions
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          if (item.status == 'active' && onCollected != null)
                            _ActionButton(
                              label: 'Collect',
                              icon: Icons.check_circle_rounded,
                              color: accentColor,
                              onTap: onCollected!,
                              theme: theme,
                            ),
                          if (item.status == 'active' && onCollected != null)
                            const SizedBox(width: AppSpacing.sm),
                          if (showAdminActions) ...[
                            _ActionButton(
                              label: 'Edit',
                              icon: Icons.edit_rounded,
                              color: AppColors.warmGray500,
                              onTap: onEdit,
                              theme: theme,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _ActionButton(
                              label: 'Delete',
                              icon: Icons.delete_rounded,
                              color: AppColors.warmGray400,
                              onTap: onDelete,
                              theme: theme,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.mediumBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _TabChip({
    required this.label,
    required this.count,
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
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: AppRadius.mediumBorder,
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.3)
                : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? color : AppColors.warmGray500,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: selected ? color : AppColors.warmGray200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? Colors.white : AppColors.warmGray500,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
