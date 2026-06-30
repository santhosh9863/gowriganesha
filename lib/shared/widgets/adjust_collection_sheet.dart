import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';

Future<void> showAdjustCollectionSheet(
    BuildContext context, WidgetRef ref, Target target) async {
  debugPrint('[ADJUST] STEP 2: showAdjustCollectionSheet called for target=${target.name} currentTotal=${target.givenAmount}');

  debugPrint('[ADJUST] STEP 3: About to open modal bottom sheet');
  final result = await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (_) => _AdjustSheetContent(target: target),
  );
  debugPrint('[ADJUST] STEP 6: Bottom sheet closed');

  if (result == null) {
    debugPrint('[ADJUST] STEP 6b: Result was null (user cancelled), returning');
    return;
  }

  final newTotal = result['newTotal'] as int;
  final reason = result['reason'] as String;
  debugPrint('[ADJUST] STEP 7: newTotal=$newTotal reason="$reason"');

  try {
    final service = ref.read(firestoreProvider);
    debugPrint('[ADJUST] STEP 8: Starting recordCorrection');
    await service.recordCorrection(
      targetId: target.id,
      currentTotal: target.givenAmount,
      newTotal: newTotal,
      note: reason,
    );
    debugPrint('[ADJUST] STEP 9: recordCorrection completed');

    final delta = newTotal - target.givenAmount;
    debugPrint('[ADJUST] STEP 10: Starting addActivity');
    await service.addActivity(Activity(
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
    debugPrint('[ADJUST] STEP 11: addActivity completed');
    debugPrint('[ADJUST] STEP 12: Scheduling post-frame snackbar');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[ADJUST] STEP 13: Post-frame callback executing');
      if (!context.mounted) {
        debugPrint('[ADJUST] STEP 13b: Context NOT mounted, skipping snackbar');
        return;
      }
      context.showSuccess('${AppConstants.currencySymbol}${fmtAmount(target.givenAmount)} → ${AppConstants.currencySymbol}${fmtAmount(newTotal)} ($reason)');
      debugPrint('[ADJUST] STEP 14: Snackbar shown');
    });
  } on Exception catch (e) {
    debugPrint('[ADJUST] ERROR: Exception caught: $e');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[ADJUST] ERROR post-frame: context.mounted=${context.mounted}');
      if (!context.mounted) return;
      context.showError('Error: $e');
    });
  }
  debugPrint('[ADJUST] STEP 15: showAdjustCollectionSheet complete');
}

class _AdjustSheetContent extends StatefulWidget {
  final Target target;
  const _AdjustSheetContent({required this.target});

  @override
  State<_AdjustSheetContent> createState() => _AdjustSheetContentState();
}

class _AdjustSheetContentState extends State<_AdjustSheetContent> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _reasonCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
            widget.target.name,
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
              'Current: ${AppConstants.currencySymbol}${fmtAmount(widget.target.givenAmount)}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _amountCtrl,
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
            controller: _reasonCtrl,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    debugPrint('[ADJUST] STEP 4: Apply button pressed');
                    final v = tryParseAmount(_amountCtrl.text.trim());
                    final reason = _reasonCtrl.text.trim();
                    if (v != null && v >= 0) {
                      debugPrint('[ADJUST] STEP 5: Popping bottom sheet with newTotal=$v');
                      final data = {'newTotal': v, 'reason': reason};
                      Navigator.pop(context, data);
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
  }
}
