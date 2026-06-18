import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/festival.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/budget_provider.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart'; // exports firestoreProvider
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/utils/permissions.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/utils/export_data.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_section_header.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('[DIAG:SettingsPage] initState');
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('[DIAG:SettingsPage] deactivate');
  }

  @override
  void dispose() {
    debugPrint('[DIAG:SettingsPage] dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DIAG:SettingsPage] build');
    final festivalAsync = ref.watch(festivalProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);
    final role = ref.watch(roleProvider);

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
          ),
          const SizedBox(height: AppSpacing.sm),
          festivalAsync.when(
            data: (festival) => _FestivalInfoCard(festival: festival),
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
          if (canExport(role))
            _ExportCard(),
          if (role != UserRole.none) ...[
            const SizedBox(height: AppSpacing.xl),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: AppSectionHeader(
                title: 'Account',
                subtitle: 'Your session details',
              ),
            ),
            _AccountCard(),
          ],
          if (canAccessSettings(role)) ...[
            const SizedBox(height: AppSpacing.xl),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: AppSectionHeader(
                title: 'Administration',
                subtitle: 'Admin settings and controls',
              ),
            ),
            _AdminPermissionsCard(),
          ],
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
// Budget Edit Sheet
// ──────────────────────────────────────────────
class _EditBudgetSheet extends StatefulWidget {
  final int current;

  const _EditBudgetSheet({required this.current});

  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: const [IndianAmountInputFormatter()],
            decoration: const InputDecoration(
              labelText: 'Budget Amount',
              prefixText: '${AppConstants.currencySymbol} ',
              prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              final v = tryParseAmount(_controller.text.trim());
              if (v != null && v > 0) {
                Navigator.of(context).pop(v);
              }
            },
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Budget Hero Card
// ──────────────────────────────────────────────
class _BudgetCard extends ConsumerStatefulWidget {
  final AsyncValue<int> budgetAsync;
  final AsyncValue<List<Expense>> expensesAsync;

  const _BudgetCard({
    required this.budgetAsync,
    required this.expensesAsync,
  });

  @override
  ConsumerState<_BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends ConsumerState<_BudgetCard> {
  @override
  void initState() {
    super.initState();
    debugPrint('[DIAG:_BudgetCard] initState');
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('[DIAG:_BudgetCard] deactivate');
  }

  @override
  void dispose() {
    debugPrint('[DIAG:_BudgetCard] dispose');
    super.dispose();
  }

  Future<void> _editBudget(BuildContext context, WidgetRef ref) async {
    debugPrint('[DIAG:_editBudget] BEFORE modal bottom sheet');
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _EditBudgetSheet(current: widget.budgetAsync.valueOrNull ?? 0),
    );
    if (result == null || result <= 0 || !context.mounted) {
      debugPrint('[DIAG:_editBudget] cancelled or not mounted result=$result mounted=${context.mounted}');
      return;
    }

    debugPrint('[DIAG:_editBudget] BEFORE firestore write result=$result');
    final service = ref.read(firestoreProvider);
    await service.setBudget(AppConstants.festivalId, result);
    debugPrint('[DIAG:_editBudget] AFTER firestore write');
    if (!context.mounted) {
      debugPrint('[DIAG:_editBudget] NOT MOUNTED after firestore write');
      return;
    }

    debugPrint('[DIAG:_editBudget] BEFORE snackbar');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Budget updated to ${AppConstants.currencySymbol}${fmtAmount(result)}',
          ),
        ),
      );
    debugPrint('[DIAG:_editBudget] AFTER snackbar');

    debugPrint('[DIAG:_editBudget] BEFORE addPostFrameCallback');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[DIAG:_editBudget] INSIDE addPostFrameCallback');
      debugPrint('[DIAG:_editBudget] BEFORE ref.invalidate(budgetProvider)');
      ref.invalidate(budgetProvider);
      debugPrint('[DIAG:_editBudget] AFTER ref.invalidate(budgetProvider)');
    });
    debugPrint('[DIAG:_editBudget] AFTER addPostFrameCallback scheduled');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[DIAG:_BudgetCard] build');
    final theme = Theme.of(context);
    final role = ref.watch(roleProvider);

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
                if (canChangeBudget(role))
                  TextButton.icon(
                    onPressed: () => _editBudget(context, ref),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            widget.budgetAsync.when(
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
            widget.expensesAsync.when(
              data: (expenses) {
                final total = expenses.fold<int>(0, (s, e) => s + e.amount);
                final budget = widget.budgetAsync.valueOrNull ?? 0;
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
                          ? 'Over budget by ${AppConstants.currencySymbol}${fmtAmount(remaining.abs())}'
                          : '${AppConstants.currencySymbol}${fmtAmount(remaining)} remaining',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isOver ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\u00B7 ${AppConstants.currencySymbol}${fmtAmount(total)} spent',
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
// Edit Text Dialog
// ──────────────────────────────────────────────
class _EditTextDialog extends StatefulWidget {
  final String label;
  final String? current;
  final bool isUpi;

  const _EditTextDialog({
    required this.label,
    this.current,
    required this.isUpi,
  });

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.label}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.isUpi ? TextInputType.text : TextInputType.name,
        textCapitalization: widget.isUpi
            ? TextCapitalization.none
            : TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.isUpi ? 'e.g. example@upi' : 'e.g. Sri Ganesha Temple',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Festival Info Card
// ──────────────────────────────────────────────
class _FestivalInfoCard extends ConsumerStatefulWidget {
  final Festival festival;

  const _FestivalInfoCard({required this.festival});

  @override
  ConsumerState<_FestivalInfoCard> createState() => _FestivalInfoCardState();
}

class _FestivalInfoCardState extends ConsumerState<_FestivalInfoCard> {
  @override
  void initState() {
    super.initState();
    debugPrint('[DIAG:_FestivalInfoCard] initState');
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('[DIAG:_FestivalInfoCard] deactivate');
  }

  @override
  void dispose() {
    debugPrint('[DIAG:_FestivalInfoCard] dispose');
    super.dispose();
  }

  Future<void> _editText(BuildContext context, String label, String? current,
      {required bool isUpi}) async {
    debugPrint('[DIAG:_editText] BEFORE dialog label=$label');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditTextDialog(label: label, current: current, isUpi: isUpi),
    );
    if (result == null || !context.mounted) {
      debugPrint('[DIAG:_editText] cancelled or not mounted result=$result mounted=${context.mounted}');
      return;
    }
    final updated = isUpi
        ? widget.festival.copyWith(
            upiId: result.isNotEmpty ? result : null,
            clearUpiId: result.isEmpty,
          )
        : widget.festival.copyWith(
            accountName: result.isNotEmpty ? result : null,
            clearAccountName: result.isEmpty,
          );

    debugPrint('[DIAG:_editText] BEFORE firestore write label=$label result=$result');
    final service = ref.read(firestoreProvider);
    await service.setFestival(updated);
    service.addActivity(Activity(
      id: service.generateId(),
      festivalId: AppConstants.festivalId,
      type: 'festival_updated',
      title: 'Festival Setting Updated',
      description: '$label updated',
      createdAt: Timestamp.now(),
      recordId: widget.festival.id,
      entityType: 'festival',
    ));
    debugPrint('[DIAG:_editText] AFTER firestore write');
    if (!context.mounted) {
      debugPrint('[DIAG:_editText] NOT MOUNTED after firestore write');
      return;
    }

    debugPrint('[DIAG:_editText] BEFORE snackbar');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('$label updated')),
      );
    debugPrint('[DIAG:_editText] AFTER snackbar');

    debugPrint('[DIAG:_editText] BEFORE addPostFrameCallback');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[DIAG:_editText] INSIDE addPostFrameCallback');
      debugPrint('[DIAG:_editText] BEFORE ref.invalidate(festivalProvider)');
      ref.invalidate(festivalProvider);
      debugPrint('[DIAG:_editText] AFTER ref.invalidate(festivalProvider)');
    });
    debugPrint('[DIAG:_editText] AFTER addPostFrameCallback scheduled');
  }

  Future<void> _pickDate(BuildContext context) async {
    debugPrint('[DIAG:_pickDate] BEFORE date picker');
    final now = DateTime.now();
    final initial = widget.festival.festivalDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Select festival date',
    );
    if (picked == null || !context.mounted) {
      debugPrint('[DIAG:_pickDate] cancelled or not mounted picked=$picked mounted=${context.mounted}');
      return;
    }
    final updated = widget.festival.copyWith(festivalDate: picked);

    debugPrint('[DIAG:_pickDate] BEFORE firestore write picked=${DateFormat('d MMMM yyyy').format(picked)}');
    final service = ref.read(firestoreProvider);
    await service.setFestival(updated);
    service.addActivity(Activity(
      id: service.generateId(),
      festivalId: AppConstants.festivalId,
      type: 'festival_updated',
      title: 'Festival Date Updated',
      description: 'Festival date set to ${DateFormat('d MMMM yyyy').format(picked)}',
      createdAt: Timestamp.now(),
      recordId: widget.festival.id,
      entityType: 'festival',
    ));
    debugPrint('[DIAG:_pickDate] AFTER firestore write');
    if (!context.mounted) {
      debugPrint('[DIAG:_pickDate] NOT MOUNTED after firestore write');
      return;
    }

    debugPrint('[DIAG:_pickDate] BEFORE snackbar');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Festival date updated to ${DateFormat('d MMMM yyyy').format(picked)}'),
        ),
      );
    debugPrint('[DIAG:_pickDate] AFTER snackbar');

    debugPrint('[DIAG:_pickDate] BEFORE addPostFrameCallback');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[DIAG:_pickDate] INSIDE addPostFrameCallback');
      debugPrint('[DIAG:_pickDate] BEFORE ref.invalidate(festivalProvider)');
      ref.invalidate(festivalProvider);
      debugPrint('[DIAG:_pickDate] AFTER ref.invalidate(festivalProvider)');
    });
    debugPrint('[DIAG:_pickDate] AFTER addPostFrameCallback scheduled');
  }

  Future<void> _uploadQrImage(BuildContext context) async {
    debugPrint('[DIAG:_uploadQrImage] BEFORE image picker');
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) {
      debugPrint('[DIAG:_uploadQrImage] cancelled or not mounted');
      return;
    }
    debugPrint('[DIAG:_uploadQrImage] platform: ${kIsWeb ? "web" : "mobile"}');

    if (!context.mounted) {
      debugPrint('[DIAG:_uploadQrImage] NOT MOUNTED after pick');
      return;
    }

    debugPrint('[DIAG:_uploadQrImage] BEFORE uploading snackbar');
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
      debugPrint('[DIAG:_uploadQrImage] BEFORE firestore upload');
      final service = ref.read(firestoreProvider);
      final url = kIsWeb
          ? await service.uploadQrImageBytes(await picked.readAsBytes())
          : await service.uploadQrImage(File(picked.path));
      final updated = widget.festival.copyWith(qrImageUrl: url);
      await service.setFestival(updated);
      service.addActivity(Activity(
        id: service.generateId(),
        festivalId: AppConstants.festivalId,
        type: 'qr_updated',
        title: 'QR Code Updated',
        description: 'Payment QR code updated',
        createdAt: Timestamp.now(),
        recordId: widget.festival.id,
        entityType: 'festival',
      ));
      debugPrint('[DIAG:_uploadQrImage] AFTER firestore upload');
      if (!context.mounted) {
        debugPrint('[DIAG:_uploadQrImage] NOT MOUNTED after upload');
        return;
      }

      debugPrint('[DIAG:_uploadQrImage] BEFORE success snackbar');
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('QR image updated')),
        );
      debugPrint('[DIAG:_uploadQrImage] AFTER success snackbar');

      debugPrint('[DIAG:_uploadQrImage] BEFORE addPostFrameCallback');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[DIAG:_uploadQrImage] INSIDE addPostFrameCallback');
        debugPrint('[DIAG:_uploadQrImage] BEFORE ref.invalidate(festivalProvider)');
        ref.invalidate(festivalProvider);
        debugPrint('[DIAG:_uploadQrImage] AFTER ref.invalidate(festivalProvider)');
      });
      debugPrint('[DIAG:_uploadQrImage] AFTER addPostFrameCallback scheduled');
    } on Exception catch (e) {
      debugPrint('[DIAG:_uploadQrImage] EXCEPTION: $e');
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
    debugPrint('[DIAG:_FestivalInfoCard] build');
    final theme = Theme.of(context);
    final role = ref.watch(roleProvider);
    final canEdit = role == UserRole.admin;
    final dateStr = widget.festival.festivalDate != null
        ? DateFormat('d MMMM yyyy').format(widget.festival.festivalDate!)
        : 'Not set';

    final upiDisplay = widget.festival.upiId ?? 'Not set';
    final accountDisplay = widget.festival.accountName ?? 'Not set';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppSettingCard(
        child: Column(
          children: [
            _InfoRow(
              label: 'Festival Name',
              value: widget.festival.name,
              icon: Icons.festival_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Year',
              value: widget.festival.year.toString(),
              icon: Icons.calendar_today_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              label: 'Location',
              value: widget.festival.location,
              icon: Icons.location_on_rounded,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.md),
            canEdit
                ? _DateRow(
                    label: 'Festival Date',
                    value: dateStr,
                    icon: Icons.event_rounded,
                    theme: theme,
                    onTap: () => _pickDate(context),
                  )
                : _InfoRow(
                    label: 'Festival Date',
                    value: dateStr,
                    icon: Icons.event_rounded,
                    theme: theme,
                  ),
            const SizedBox(height: AppSpacing.md),
            canEdit
                ? _EditRow(
                    label: 'UPI ID',
                    value: upiDisplay,
                    icon: Icons.payments_rounded,
                    theme: theme,
                    onTap: () => _editText(context, 'UPI ID', widget.festival.upiId, isUpi: true),
                  )
                : _InfoRow(
                    label: 'UPI ID',
                    value: upiDisplay,
                    icon: Icons.payments_rounded,
                    theme: theme,
                  ),
            const SizedBox(height: AppSpacing.md),
            canEdit
                ? _EditRow(
                    label: 'Account Name',
                    value: accountDisplay,
                    icon: Icons.badge_rounded,
                    theme: theme,
                    onTap: () => _editText(context, 'Account Name', widget.festival.accountName, isUpi: false),
                  )
                : _InfoRow(
                    label: 'Account Name',
                    value: accountDisplay,
                    icon: Icons.badge_rounded,
                    theme: theme,
                  ),
            const SizedBox(height: AppSpacing.md),
            _QrPreviewRow(
              qrImageUrl: widget.festival.qrImageUrl,
              onUpload: canEdit ? () => _uploadQrImage(context) : null,
              onReplace: canEdit ? () => _uploadQrImage(context) : null,
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
      ],
    );
  }
}

// ──────────────────────────────────────────────
// QR Preview Row
// ──────────────────────────────────────────────
class _QrPreviewRow extends StatelessWidget {
  final String? qrImageUrl;
  final VoidCallback? onUpload;
  final VoidCallback? onReplace;
  final ThemeData theme;

  const _QrPreviewRow({
    required this.qrImageUrl,
    required this.theme,
    this.onUpload,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = qrImageUrl != null && qrImageUrl!.isNotEmpty;
    final showButton = hasImage ? onReplace != null : onUpload != null;
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
            if (showButton)
              TextButton.icon(
                onPressed: hasImage ? onReplace! : onUpload!,
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
class _ExportCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.read(firestoreProvider);
    final role = ref.watch(roleProvider);

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
                    'Sponsors, collections, expenses & visits',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                ],
              ),
            ),
            if (canExport(role))
              TextButton(
                onPressed: () => exportAllData(context, service),
                child: const Text('Export'),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Account Card
// ──────────────────────────────────────────────
class _AccountCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(roleProvider);
    final userName = ref.watch(userNameProvider);

    if (role == UserRole.none) return const SizedBox.shrink();

    final isAdmin = role == UserRole.admin;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(color: isAdmin ? AppColors.warningBg : AppColors.outline),
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
                    color: isAdmin ? AppColors.warningBg : AppColors.primaryBg,
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: Icon(
                    isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                    color: isAdmin ? AppColors.warning : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isNotEmpty ? userName : 'Guest',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isAdmin ? 'Admin' : 'Volunteer',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isAdmin ? AppColors.warning : AppColors.warmGray500,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await ref.read(roleProvider.notifier).clearSession();
                    if (context.mounted) context.go('/entry');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Logout'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showSwitchToAdmin(context, ref),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Switch to Admin'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(roleProvider.notifier).clearSession();
                      if (context.mounted) context.go('/entry');
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('Logout'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSwitchToAdmin(BuildContext context, WidgetRef ref) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Switch to Admin'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter admin password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, passwordController.text),
            child: const Text('Login'),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) return;

    final notifier = ref.read(roleProvider.notifier);
    final success = await notifier.loginAsAdmin(password);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Switched to Admin mode')));
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Incorrect admin password')));
    }
  }
}

// ──────────────────────────────────────────────
// Admin Permissions Card
// ──────────────────────────────────────────────
class _AdminPermissionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(color: AppColors.warningBg),
          boxShadow: AppShadows.soft,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: AppRadius.mediumBorder,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          title: Text(
            'Admin Controls',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Tap to view admin permissions',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.warmGray500,
            ),
          ),
          children: _buildPermissionList(theme),
        ),
      ),
    );
  }

  List<Widget> _buildPermissionList(ThemeData theme) {
    final sections = [
      ('Sponsors', ['Add Sponsors', 'Edit Sponsors', 'Delete Sponsors']),
      ('Collections', ['Record Collections', 'Edit Collections', 'Delete Collections']),
      ('Expenses', ['Add Expenses', 'Edit Expenses', 'Delete Expenses']),
      ('Visits', ['Manage Visits', 'Mark Visits as Collected']),
      ('Data', ['Export Data', 'Clear Activity Feed']),
      ('Festival', ['Update Festival Settings', 'Update QR Code & UPI Details']),
      ('Mode', ['Switch Between Admin & Volunteer Modes']),
    ];

    final widgets = <Widget>[];
    for (final (category, perms) in sections) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            category,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.warmGray500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      for (final perm in perms) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  perm,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray700,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
