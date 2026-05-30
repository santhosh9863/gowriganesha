import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';

class CollectionDetailPage extends ConsumerStatefulWidget {
  final String targetId;

  const CollectionDetailPage({super.key, required this.targetId});

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState extends ConsumerState<CollectionDetailPage> {
  String _relativeTime(Timestamp? ts) {
    if (ts == null) return '';
    final updated = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(updated);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return DateFormat('d MMM').format(updated);
  }

  Future<void> _handleReceiveAmount(Target target) async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Receive Amount'),
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
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g. Collected by Sanjay',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
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
          ],
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
        description: '₹${_fmt(amount)} received from ${target.name}${noteTxt.isNotEmpty ? ' — $noteTxt' : ''}',
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

    final allFollowUps = ref.watch(allFollowUpsStreamProvider).valueOrNull ?? [];
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

    return Scaffold(
      appBar: AppBar(title: Text(target.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _AmountRow(
                      label: 'Expected Sponsorship',
                      amount: target.expectedAmount,
                      color: colorScheme.primary,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _AmountRow(
                      label: 'Received Amount',
                      amount: target.givenAmount,
                      color: colorScheme.tertiary,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _AmountRow(
                      label: 'Remaining Amount',
                      amount: remaining,
                      color: remaining > 0 ? colorScheme.error : Colors.green.shade700,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: colorScheme.primaryContainer.withAlpha(80),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updated ${_relativeTime(target.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _handleReceiveAmount(target),
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: const Text('Receive Amount'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/followups/add?sponsorId=${target.id}&sponsorName=${Uri.encodeComponent(target.name)}',
                    ),
                    icon: const Icon(Icons.add_alert_rounded, size: 18),
                    label: const Text('Add Follow-Up'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/collections/${target.id}/edit'),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Sponsor'),
                  ),
                ),
              ],
            ),
            if (sponsorFollowUps.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Follow-Up History',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...active.map((fu) => _FollowUpRow(
                    followup: fu,
                    theme: theme,
                    colorScheme: colorScheme,
                    isActive: true,
                  )),
              if (completed.isNotEmpty) ...[
                const Divider(height: 24),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AmountText(
          amount: amount,
          style: theme.textTheme.titleMedium?.copyWith(
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
    final dateStr = DateFormat('d MMM').format(followup.followUpDate.toDate());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primaryContainer.withAlpha(100)
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive
                  ? Icons.schedule_rounded
                  : Icons.check_circle_rounded,
              size: 18,
              color: isActive
                  ? colorScheme.primary
                  : Colors.green.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
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
              color: isActive
                  ? colorScheme.primary.withAlpha(30)
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive ? 'Pending' : 'Collected',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? colorScheme.primary
                    : Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
