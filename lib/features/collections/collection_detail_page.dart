import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/utils/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/contribution_provider.dart';
import 'package:ganesha_2026/core/models/contribution.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/app_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class CollectionDetailPage extends ConsumerStatefulWidget {
  final String targetId;

  const CollectionDetailPage({super.key, required this.targetId});

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState extends ConsumerState<CollectionDetailPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('[LIFECYCLE] CollectionDetailPage.initState targetId=${widget.targetId}');
  }

  @override
  void dispose() {
    debugPrint('[LIFECYCLE] CollectionDetailPage.dispose targetId=${widget.targetId}');
    super.dispose();
  }

  Future<void> _handleReceiveAmount(Target target) async {
    debugPrint('[ACTION] CollectionDetailPage._handleReceiveAmount target=${target.name}');
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Contribution',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                target.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Commitment: ₹${_fmt(target.expectedAmount)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: const [IndianAmountInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. Received from Chikthayappa',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        final v = tryParseAmount(amountCtrl.text.trim());
                        if (v != null && v > 0) {
                          final data = {
                            'amount': v,
                            'note': noteCtrl.text.trim(),
                          };
                          Navigator.pop(ctx, data);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    final amount = result['amount'] as int;

    try {
      final service = ref.read(firestoreProvider);
      final noteTxt = result['note'] as String;
      await service.recordContribution(
        targetId: target.id,
        amount: amount,
        note: noteTxt,
      );
      debugPrint('[ACTION] CollectionDetailPage: Firestore write complete, triggering cascade');
      service.addActivity(Activity(
        id: service.generateId(),
        festivalId: AppConstants.festivalId,
        type: 'collection_recorded',
        title: 'Collection Recorded',
        description:
            'Collection of ${AppConstants.currencySymbol}${fmtAmount(amount)} received from ${target.name}${noteTxt.isNotEmpty ? ' — $noteTxt' : ''}',
        createdAt: Timestamp.now(),
        recordId: target.id,
        entityType: 'target',
      ));
      debugPrint('[ACTION] CollectionDetailPage: Activity written, mounted=$mounted');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppConstants.currencySymbol}${fmtAmount(amount)} recorded')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleAdjustCollection(Target target) async {
    debugPrint('[ACTION] CollectionDetailPage._handleAdjustCollection target=${target.name} givenAmount=${target.givenAmount}');
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xxl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust Collection',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                target.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Current: ${AppConstants.currencySymbol}${_fmt(target.givenAmount)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: const [IndianAmountInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'New Total',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter new total amount. Use a lower value to record a refund.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason (required)',
                  hintText: 'e.g. Refund, correction, adjustment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        final v = tryParseAmount(amountCtrl.text.trim());
                        final reason = reasonCtrl.text.trim();
                        if (v != null && v >= 0 && reason.isNotEmpty) {
                          final data = {'newTotal': v, 'reason': reason};
                          Navigator.pop(ctx, data);
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    final newTotal = result['newTotal'] as int;
    final reason = result['reason'] as String;

    try {
      final service = ref.read(firestoreProvider);
      await service.recordCorrection(
        targetId: target.id,
        currentTotal: target.givenAmount,
        newTotal: newTotal,
        note: reason,
      );
      final delta = newTotal - target.givenAmount;
      service.addActivity(Activity(
        id: service.generateId(),
        festivalId: AppConstants.festivalId,
        type: 'collection_corrected',
        title: 'Collection Adjusted',
        description:
            '${target.name} — ${delta >= 0 ? '+' : ''}${AppConstants.currencySymbol}${fmtAmount(delta)}: $reason',
        createdAt: Timestamp.now(),
        recordId: target.id,
        entityType: 'target',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppConstants.currencySymbol}${fmtAmount(target.givenAmount)} → ${AppConstants.currencySymbol}${fmtAmount(newTotal)} ($reason)',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTarget(Target target) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Sponsor',
      message: 'Delete "${target.name}"? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteTarget(target.id);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _fmt(int n) {
    return fmtAmount(n);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] CollectionDetailPage.build targetId=${widget.targetId}');
    final target = ref.watch(targetByIdProvider(widget.targetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (target == null) {
      return AppPageScaffold(
        showBack: true,
        festivalName: 'Sponsor',
        child: const AppSkeletonList(),
      );
    }

    final remaining = target.expectedAmount - target.givenAmount;
    final progress = target.expectedAmount > 0
        ? target.givenAmount / target.expectedAmount
        : 0.0;

    final allFollowUps =
        ref.watch(allFollowUpsStreamProvider).valueOrNull ?? [];
    final sponsorFollowUps = allFollowUps
        .where((f) {
          if (f.sponsorId.isNotEmpty) return f.sponsorId == target.id;
          return f.sponsorName.toLowerCase() == target.name.toLowerCase();
        })
        .toList();
    final active = sponsorFollowUps
        .where((f) => f.status == 'active')
        .toList()
          ..sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
    final completed = sponsorFollowUps
        .where((f) => f.status == 'completed')
        .toList()
          ..sort((a, b) {
            final aDt = a.completedAt ?? a.followUpDate;
            final bDt = b.completedAt ?? b.followUpDate;
            return bDt.compareTo(aDt);
          });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasOverdue = active.any((f) {
      final d = f.followUpDate.toDate();
      return DateTime(d.year, d.month, d.day).isBefore(today);
    });

    return AppPageScaffold(
      showBack: true,
      festivalName: target.name,
      onSettings: () => context.push('/settings'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_alert_rounded),
                  tooltip: 'Add Visit',
                  onPressed: () => context.push(
                    '/followups/add?sponsorId=${target.id}&sponsorName=${Uri.encodeComponent(target.name)}',
                  ),
                ),
                if (canEditRecords(ref.watch(roleProvider)))
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Edit Sponsor',
                    onPressed: () =>
                        context.push('/collections/${target.id}/edit'),
                  ),
                if (canDelete(ref.watch(roleProvider)))
                  IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    tooltip: 'Delete Sponsor',
                    onPressed: () => _deleteTarget(target),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AmountRow(
                          label: 'Commitment',
                          amount: target.expectedAmount,
                          color: colorScheme.primary,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _AmountRow(
                          label: 'Raised',
                          amount: target.givenAmount,
                          color: colorScheme.tertiary,
                          theme: theme,
                        ),
                      ),
                      Expanded(
                        child: _AmountRow(
                          label: 'To Reach',
                          amount: remaining,
                          color: remaining > 0
                              ? colorScheme.error
                              : colorScheme.tertiary,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ClipRRect(
                    borderRadius: AppRadius.cardBorder,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor:
                          colorScheme.primaryContainer.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${AppConstants.currencySymbol}${_fmt(target.givenAmount)} of ${AppConstants.currencySymbol}${_fmt(target.expectedAmount)} raised (${(progress * 100).toStringAsFixed(0)}%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _handleReceiveAmount(target),
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: const Text('Record Contribution'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAdjustCollection(target),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('Adjust Collection'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ContributionList(targetId: target.id),
            if (hasOverdue) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.error.withAlpha(15),
                  borderRadius: AppRadius.cardBorder,
                  border: Border.all(
                    color: colorScheme.error.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 20, color: colorScheme.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${active.where((f) { final d = f.followUpDate.toDate(); return DateTime(d.year, d.month, d.day).isBefore(today); }).length} visit${active.where((f) { final d = f.followUpDate.toDate(); return DateTime(d.year, d.month, d.day).isBefore(today); }).length == 1 ? '' : 's'} overdue — take action',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (sponsorFollowUps.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Visit History',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...active.map((fu) => _FollowUpRow(
                    followup: fu,
                    theme: theme,
                    colorScheme: colorScheme,
                    isActive: true,
                  )),
              if (completed.isNotEmpty) ...[
                const Divider(height: AppSpacing.xxl),
                ...completed.map((fu) => _FollowUpRow(
                      followup: fu,
                      theme: theme,
                      colorScheme: colorScheme,
                      isActive: false,
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final ThemeData theme;

  const _AmountRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AmountText(
          amount: amount,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FollowUpRow extends StatelessWidget {
  final SponsorFollowup followup;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isActive;

  const _FollowUpRow({
    required this.followup,
    required this.theme,
    required this.colorScheme,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('d MMM').format(followup.followUpDate.toDate());

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = followup.followUpDate.toDate();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = isActive && dueDay.isBefore(today);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOverdue
                  ? colorScheme.error.withAlpha(80)
                  : isActive
                      ? colorScheme.primaryContainer.withAlpha(100)
                      : colorScheme.tertiary.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isOverdue
                  ? Icons.warning_amber_rounded
                  : isActive
                      ? Icons.schedule_rounded
                      : Icons.check_circle_rounded,
              size: 18,
              color: isOverdue
                  ? colorScheme.error
                  : isActive
                      ? colorScheme.primary
                      : colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'OVERDUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (followup.note.isNotEmpty)
                  Text(
                    followup.note,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (followup.amount != null)
                  Text(
                    '${AppConstants.currencySymbol}${fmtAmount(followup.amount!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isOverdue
                  ? colorScheme.error.withAlpha(25)
                  : isActive
                      ? colorScheme.primary.withAlpha(30)
                      : colorScheme.tertiary.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isOverdue
                  ? 'Overdue'
                  : isActive
                      ? 'Pending'
                      : 'Collected',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isOverdue
                    ? colorScheme.error
                    : isActive
                        ? colorScheme.primary
                        : colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionList extends ConsumerWidget {
  final String targetId;

  const _ContributionList({required this.targetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsStreamProvider(targetId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Contribution History',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            contributionsAsync.whenOrNull(
              data: (contributions) => Text(
                '  ${contributions.length} ${contributions.length == 1 ? 'entry' : 'entries'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ) ?? const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        contributionsAsync.when(
          loading: () => Column(
            children: List.generate(3, (_) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AppSkeleton(width: 34, height: 34, borderRadius: 8),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(width: double.infinity, height: 14),
                        SizedBox(height: 6),
                        AppSkeleton(width: 100, height: 10),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  AppSkeleton(width: 80, height: 16),
                ],
              ),
            )),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Failed to load contributions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          data: (contributions) {
            if (contributions.isEmpty) {
              return AppEmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No contribution history',
                subtitle: 'Contributions and corrections will appear here.',
              );
            }

            return Column(
              children: contributions
                  .map((c) => _ContributionRow(
                        contribution: c,
                        theme: theme,
                        colorScheme: theme.colorScheme,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ContributionRow extends StatelessWidget {
  final Contribution contribution;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ContributionRow({
    required this.contribution,
    required this.theme,
    required this.colorScheme,
  });

  String _relativeTime(Timestamp ts) {
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final isCorrection = contribution.type == ContributionType.correction;
    final icon = isCorrection ? Icons.tune_rounded : Icons.payments_rounded;
    final iconColor = isCorrection ? colorScheme.error : colorScheme.primary;
    final iconBg = isCorrection
        ? colorScheme.error.withAlpha(25)
        : colorScheme.primary.withAlpha(30);
    final amountColor =
        isCorrection ? colorScheme.error : colorScheme.primary;
    final amountPrefix = isCorrection && contribution.amount >= 0 ? '+' : '';
    final typeLabel = isCorrection ? 'Correction' : 'Contribution';
    final note = contribution.note.isNotEmpty
        ? contribution.note
        : (isCorrection ? 'Amount adjusted' : 'Received from sponsor');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _relativeTime(contribution.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$amountPrefix${AppConstants.currencySymbol}${fmtAmount(contribution.amount)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
