import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/festival.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/providers/budget_provider.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_section_header.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalAsync = ref.watch(festivalProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);

    return AppPageScaffold(
      showBack: true,
      festivalName: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.xxxl),
        children: [
          // ── Festival Configuration ──
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: 'Festival Configuration',
              subtitle: 'Budget and festival details',
            ),
          ),
          _BudgetCard(
            budgetAsync: budgetAsync,
            expensesAsync: expensesAsync,
            ref: ref,
          ),
          const SizedBox(height: AppSpacing.sm),
          festivalAsync.when(
            data: (festival) => _FestivalInfoCard(festival: festival, ref: ref),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppSettingCard(child: SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppSettingCard(
                child: Text('Error loading festival: $e'),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Application ──
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: 'Application',
              subtitle: 'App information',
            ),
          ),
          _AboutCard(),

          const SizedBox(height: AppSpacing.xl),

          // ── Data ──
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: 'Data',
              subtitle: 'Manage app data',
            ),
          ),
          _ExportCard(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Shared card wrapper
// ──────────────────────────────────────────────
class AppSettingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppSettingCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.subtle,
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────
// Budget Hero Card
// ──────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final AsyncValue<int> budgetAsync;
  final AsyncValue<List<Expense>> expensesAsync;
  final WidgetRef ref;

  const _BudgetCard({
    required this.budgetAsync,
    required this.expensesAsync,
    required this.ref,
  });

  Future<void> _editBudget(BuildContext context) async {
    final current = budgetAsync.valueOrNull ?? 0;
    final controller = TextEditingController(text: current.toString());
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Festival Budget',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '\u20B9 ',
                  prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final v = int.tryParse(controller.text.trim());
                  if (v != null && v > 0) {
                    Navigator.of(ctx).pop(v);
                  }
                },
                child: const Text('Save Budget'),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
    if (result == null || result <= 0 || !context.mounted) return;

    final service = ref.read(firestoreProvider);
    await service.setBudget(AppConstants.festivalId, result);
    ref.invalidate(budgetProvider);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Budget updated to \u20B9${NumberFormat('#,##,###', 'en_IN').format(result)}',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,##,###', 'en_IN');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(color: AppColors.primaryBg),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Festival Budget',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total budget for the festival',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.warmGray500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _editBudget(context),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            budgetAsync.when(
              data: (budget) => AmountText(
                amount: budget,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Text(
                'Error loading budget',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Budget context: remaining + spent
            expensesAsync.when(
              data: (expenses) {
                final total = expenses.fold<int>(0, (s, e) => s + e.amount);
                final budget = budgetAsync.valueOrNull ?? 0;
                final remaining = budget - total;
                final isOver = remaining < 0;
                return Row(
                  children: [
                    Icon(
                      isOver ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                      size: 14,
                      color: isOver ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOver
                          ? 'Over budget by \u20B9${formatter.format(remaining.abs())}'
                          : '\u20B9${formatter.format(remaining)} remaining',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isOver ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\u00B7 \u20B9${formatter.format(total)} spent',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Festival Info Card
// ──────────────────────────────────────────────
class _FestivalInfoCard extends StatelessWidget {
  final Festival festival;
  final WidgetRef ref;

  const _FestivalInfoCard({required this.festival, required this.ref});

  Future<void> _editText(BuildContext context, String label, String? current,
      {required bool isUpi}) async {
    final controller = TextEditingController(text: current ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: isUpi ? TextInputType.text : TextInputType.name,
            textCapitalization: isUpi
                ? TextCapitalization.none
                : TextCapitalization.words,
            decoration: InputDecoration(
              labelText: label,
              hintText: isUpi ? 'e.g. example@upi' : 'e.g. Sri Ganesha Temple',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null || !context.mounted) return;
    final updated = isUpi
        ? festival.copyWith(
            upiId: result.isNotEmpty ? result : null,
            clearUpiId: result.isEmpty,
          )
        : festival.copyWith(
            accountName: result.isNotEmpty ? result : null,
            clearAccountName: result.isEmpty,
          );
    final service = ref.read(firestoreProvider);
    await service.setFestival(updated);
    ref.invalidate(festivalProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('$label updated')),
      );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = festival.festivalDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Select festival date',
    );
    if (picked == null || !context.mounted) return;
    final updated = festival.copyWith(festivalDate: picked);
    final service = ref.read(firestoreProvider);
    await service.setFestival(updated);
    ref.invalidate(festivalProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Festival date updated to ${DateFormat('d MMMM yyyy').format(picked)}'),
        ),
      );
  }

  Future<void> _uploadQrImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) return;
    final file = File(picked.path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Uploading...'),
          ]),
          duration: Duration(seconds: 30),
        ),
      );
    try {
      final service = ref.read(firestoreProvider);
      final url = await service.uploadQrImage(file);
      final updated = festival.copyWith(qrImageUrl: url);
      await service.setFestival(updated);
      ref.invalidate(festivalProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('QR image updated')),
        );
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            action: SnackBarAction(label: 'Retry', onPressed: () => _uploadQrImage(context)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = festival.festivalDate != null
        ? DateFormat('d MMMM yyyy').format(festival.festivalDate!)
        : 'Not set';

    final upiDisplay = festival.upiId ?? 'Not set';
    final accountDisplay = festival.accountName ?? 'Not set';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppSettingCard(
        child: Column(
          children: [
            _InfoRow(
              label: 'Festival Name',
              value: festival.name,
              icon: Icons.festival_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Year',
              value: festival.year.toString(),
              icon: Icons.calendar_today_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Location',
              value: festival.location,
              icon: Icons.location_on_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            _DateRow(
              label: 'Festival Date',
              value: dateStr,
              icon: Icons.event_rounded,
              theme: theme,
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: AppSpacing.md),
            _EditRow(
              label: 'UPI ID',
              value: upiDisplay,
              icon: Icons.payments_rounded,
              theme: theme,
              onTap: () => _editText(context, 'UPI ID', festival.upiId, isUpi: true),
            ),
            const SizedBox(height: AppSpacing.md),
            _EditRow(
              label: 'Account Name',
              value: accountDisplay,
              icon: Icons.badge_rounded,
              theme: theme,
              onTap: () => _editText(context, 'Account Name', festival.accountName, isUpi: false),
            ),
            const SizedBox(height: AppSpacing.md),
            _QrPreviewRow(
              qrImageUrl: festival.qrImageUrl,
              onUpload: () => _uploadQrImage(context),
              onReplace: () => _uploadQrImage(context),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onTap;

  const _EditRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.warmGray400),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 14, color: AppColors.warmGray400),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumBorder,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.warmGray400),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 14, color: AppColors.warmGray400),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.warmGray400),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// QR Preview Row
// ──────────────────────────────────────────────
class _QrPreviewRow extends StatelessWidget {
  final String? qrImageUrl;
  final VoidCallback onUpload;
  final VoidCallback onReplace;
  final ThemeData theme;

  const _QrPreviewRow({
    required this.qrImageUrl,
    required this.onUpload,
    required this.onReplace,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = qrImageUrl != null && qrImageUrl!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.qr_code_rounded, size: 18, color: AppColors.warmGray400),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Festival QR Code',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasImage ? 'Uploaded' : 'Not uploaded',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasImage ? AppColors.success : AppColors.warmGray400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: hasImage ? onReplace : onUpload,
              icon: Icon(hasImage ? Icons.swap_horiz_rounded : Icons.upload_rounded, size: 14),
              label: Text(hasImage ? 'Replace' : 'Upload'),
            ),
          ],
        ),
        if (hasImage) ...[
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Image.network(
              qrImageUrl!,
              height: 120,
              width: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.warmGray50,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_rounded, size: 24, color: AppColors.warmGray300),
                    const SizedBox(height: 4),
                    Text('Load failed', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.warmGray400)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────
// About Card
// ──────────────────────────────────────────────
class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppSettingCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Version 1.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warmGray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Built with Flutter & Firebase',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Export Card
// ──────────────────────────────────────────────
class _ExportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppSettingCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warmGray100,
                borderRadius: AppRadius.mediumBorder,
              ),
              child: const Icon(
                Icons.download_rounded,
                color: AppColors.warmGray500,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Data',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Download expenses and reports',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    const SnackBar(content: Text('Export coming soon')),
                  );
              },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }
}
