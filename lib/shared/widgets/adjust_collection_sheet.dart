import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';

Future<void> showAdjustCollectionSheet(
    BuildContext context, WidgetRef ref, Target target) async {
  final amountCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();

  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current: ${AppConstants.currencySymbol}${fmtAmount(target.givenAmount)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: const [IndianAmountInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'New Total',
                prefixText: '\u20B9 ',
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
                labelText: 'Reason (optional)',
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
                      if (v != null && v >= 0) {
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
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppConstants.currencySymbol}${fmtAmount(target.givenAmount)} → ${AppConstants.currencySymbol}${fmtAmount(newTotal)} ($reason)',
        ),
      ),
    );
  } on Exception catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }

  amountCtrl.dispose();
  reasonCtrl.dispose();
}
