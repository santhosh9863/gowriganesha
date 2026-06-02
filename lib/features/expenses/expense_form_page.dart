import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  final String? expenseId;

  const ExpenseFormPage({super.key, this.expenseId});

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
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
    if (widget.expenseId != null) {
      _loadExpense();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadExpense() async {
    final service = ref.read(firestoreProvider);
    final expense = await service.getExpense(widget.expenseId!);

    if (expense != null && mounted) {
      _amountController.text = fmtAmount(expense.amount);
      _noteController.text = expense.note;
      _selectedDate = expense.date.toDate();
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
      helpText: 'Select expense date',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.expenseId != null;
    final dateStr = _selectedDate != null
        ? DateFormat('dd MMM yyyy').format(_selectedDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
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
                          color: colorScheme.error,
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
                        hintText: 'What was this expense for?',
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
                          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
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
                          : Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                      label: Text(isEditing ? 'Update Expense' : 'Add Expense'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final service = ref.read(firestoreProvider);

    try {
      if (widget.expenseId != null) {
        final expense = Expense(
          id: widget.expenseId!,
          festivalId: AppConstants.festivalId,
          amount: parseAmount(_amountController.text.trim()),
          note: _noteController.text.trim(),
          date: Timestamp.fromDate(_selectedDate!),
          createdAt: Timestamp.now(),
        );
        await service.updateExpense(expense);
      } else {
        final expense = Expense(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          amount: parseAmount(_amountController.text.trim()),
          note: _noteController.text.trim(),
          date: Timestamp.fromDate(_selectedDate!),
          createdAt: Timestamp.now(),
        );
        await service.addExpense(expense);
        service.addActivity(Activity(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          type: 'expense_added',
          title: 'Expense Added',
          description: 'Expense of ${AppConstants.currencySymbol}${fmtAmount(expense.amount)} recorded${expense.note.isNotEmpty ? ' — ${expense.note}' : ''}',
          createdAt: Timestamp.now(),
          recordId: expense.id,
          entityType: 'expense',
        ));
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
