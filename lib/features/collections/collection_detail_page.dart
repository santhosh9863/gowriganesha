import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/app_card.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class CollectionDetailPage extends ConsumerStatefulWidget {
  final String targetId;

  const CollectionDetailPage({super.key, required this.targetId});

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState extends ConsumerState<CollectionDetailPage> {
  Future<void> _handleReceiveAmount(Target target) async {
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
                'Receive Amount',
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
                'Expected: ₹${_fmt(target.expectedAmount)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
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
                  hintText: 'e.g. Collected by Sanjay',
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
                        final v = int.tryParse(amountCtrl.text.trim());
                        if (v != null && v > 0) {
                          Navigator.pop(ctx, {
                            'amount': v,
                            'note': noteCtrl.text.trim(),
                          });
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

    amountCtrl.dispose();
    noteCtrl.dispose();

    if (result == null) return;

    final amount = result['amount'] as int;

    try {
      final service = ref.read(firestoreProvider);
      final updated = target.copyWith(
        givenAmount: target.givenAmount + amount,
        updatedAt: Timestamp.now(),
      );
      await service.updateTarget(updated);
      final noteTxt = result['note'] as String;
      service.addActivity(Activity(
        id: service.generateId(),
        festivalId: AppConstants.festivalId,
        type: 'collection_recorded',
        title: 'Collection Recorded',
        description:
            '₹${_fmt(amount)} received from ${target.name}${noteTxt.isNotEmpty ? ' — $noteTxt' : ''}',
        createdAt: Timestamp.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('₹${_fmt(amount)} recorded successfully')),
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
      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _fmt(int n) {
    return NumberFormat('#,##,###', 'en_IN').format(n);
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(targetByIdProvider(widget.targetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (target == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(target.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded),
            tooltip: 'Add Follow-Up',
            onPressed: () => context.push(
              '/followups/add?sponsorId=${target.id}&sponsorName=${Uri.encodeComponent(target.name)}',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Sponsor',
            onPressed: () =>
                context.push('/collections/${target.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Delete Sponsor',
            onPressed: () => _deleteTarget(target),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AmountRow(
                          label: 'Expected',
                          amount: target.expectedAmount,
                          color: colorScheme.primary,
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _AmountRow(
                          label: 'Received',
                          amount: target.givenAmount,
                          color: colorScheme.tertiary,
                          theme: theme,
                        ),
                      ),
                      Expanded(
                        child: _AmountRow(
                          label: 'Remaining',
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
                    '${AppConstants.currencySymbol}${_fmt(target.givenAmount)} of ${AppConstants.currencySymbol}${_fmt(target.expectedAmount)} collected (${(progress * 100).toStringAsFixed(0)}%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _handleReceiveAmount(target),
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: const Text('Receive Amount'),
              ),
            ),
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
                        '${active.where((f) { final d = f.followUpDate.toDate(); return DateTime(d.year, d.month, d.day).isBefore(today); }).length} follow-up${active.where((f) { final d = f.followUpDate.toDate(); return DateTime(d.year, d.month, d.day).isBefore(today); }).length == 1 ? '' : 's'} overdue — take action',
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
                'Follow-Up History',
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
                    '₹${NumberFormat('#,##,###', 'en_IN').format(followup.amount)}',
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
