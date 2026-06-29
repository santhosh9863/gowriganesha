import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';

class DailyCollectionFormPage extends ConsumerStatefulWidget {
  final String? dailyCollectionId;

  const DailyCollectionFormPage({super.key, this.dailyCollectionId});

  @override
  ConsumerState<DailyCollectionFormPage> createState() =>
      _DailyCollectionFormPageState();
}

class _DailyCollectionFormPageState
    extends ConsumerState<DailyCollectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    if (widget.dailyCollectionId != null) {
      _loadDailyCollection();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadDailyCollection() async {
    final service = ref.read(firestoreProvider);
    final dc = await service.getDailyCollection(widget.dailyCollectionId!);

    if (dc != null && mounted) {
      _amountController.text = fmtAmount(dc.amount);
      _noteController.text = dc.note;
      _selectedDate = dc.date.toDate();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select collection date',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.dailyCollectionId != null;
    final dateStr = _selectedDate != null
        ? DateFormat('dd MMM yyyy').format(_selectedDate!)
        : null;
    final role = ref.watch(roleProvider);

    if (role != UserRole.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/daily-collections');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Daily Collection' : 'Add Daily Collection'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText: 'e.g. 5,000',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: colorScheme.secondary,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: const [IndianAmountInputFormatter()],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Amount is required';
                        }
                        final n = tryParseAmount(v.trim());
                        if (n == null || n <= 0) {
                          return 'Enter an amount greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        hintText: 'Source or purpose of collection',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.calendar_today_rounded,
                            color: colorScheme.primary,
                          ),
                          suffixIcon:
                              const Icon(Icons.arrow_drop_down_rounded),
                        ),
                        child: Text(
                          dateStr ?? 'Select date',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: dateStr != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDate == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          'Date is required',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isEditing ? Icons.save_rounded : Icons.add_rounded),
                      label: Text(isEditing
                          ? 'Update Collection'
                          : 'Add Collection'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      context.showWarning('Please select a date');
      return;
    }
    if (_isSaving) return;
    if (!mounted) return;
    if (ref.read(roleProvider) != UserRole.admin) {
      context.showWarning('Access Denied');
      return;
    }
    setState(() => _isSaving = true);

    final service = ref.read(firestoreProvider);

    try {
      if (widget.dailyCollectionId != null) {
        final dc = DailyCollection(
          id: widget.dailyCollectionId!,
          festivalId: AppConstants.festivalId,
          amount: parseAmount(_amountController.text.trim()),
          note: _noteController.text.trim(),
          date: Timestamp.fromDate(_selectedDate!),
          createdAt: Timestamp.now(),
        );
        await service.updateDailyCollection(dc);
      } else {
        final dc = DailyCollection(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          amount: parseAmount(_amountController.text.trim()),
          note: _noteController.text.trim(),
          date: Timestamp.fromDate(_selectedDate!),
          createdAt: Timestamp.now(),
        );
        await service.addDailyCollection(dc);
        final activityService = ref.read(activityServiceProvider);
        final userId = ref.read(userIdProvider);
        final userName = ref.read(userNameProvider);
        await activityService.recordDailyCollectionRecorded(dc, userId: userId, userName: userName);
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.showError(e.toString());
      }
    }
  }
}
