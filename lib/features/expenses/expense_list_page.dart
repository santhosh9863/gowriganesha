import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/providers/budget_provider.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/features/expenses/expense_tile.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_metric_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_section_header.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class ExpenseListPage extends ConsumerWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final budgetAsync = ref.watch(budgetProvider);

    return AppPageScaffold(
      festivalName: 'Expenses',
      onSettings: () => context.push('/settings'),
      onAdd: () => context.push('/expenses/add'),
      bottomNavHeight: 56,
      child: expensesAsync.when(
        data: (expenses) => _buildContent(context, ref, expenses, budgetAsync),
        loading: () => const AppSkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Expense> expenses,
    AsyncValue<int> budgetAsync,
  ) {
    if (expenses.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        children: [
          AppEmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No expenses recorded',
            subtitle: 'Tap + to record your first expense',
            action: FilledButton.icon(
              onPressed: () => context.push('/expenses/add'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Expense'),
            ),
          ),
        ],
      );
    }

    final totalExpenses = expenses.fold<int>(0, (s, e) => s + e.amount);
    final largestExpense = expenses.fold<int>(0, (s, e) => s > e.amount ? s : e.amount);
    final budget = budgetAsync.valueOrNull ?? 0;
    final remaining = budget - totalExpenses;
    final isOverBudget = remaining < 0;

    // Group by month
    final grouped = <String, List<Expense>>{};
    for (final e in expenses) {
      final d = e.date.toDate();
      final key = DateFormat('MMMM yyyy').format(d);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(e);
    }

    // Sort groups reverse chronologically
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      final da = DateFormat('MMMM yyyy').parse(a);
      final db = DateFormat('MMMM yyyy').parse(b);
      return db.compareTo(da);
    });

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.xxxl),
      children: [
        // Summary 2x2
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
                      label: 'Total Expenses',
                      value: '${AppConstants.currencySymbol}${fmtAmount(totalExpenses)}',
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.errorBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: isOverBudget ? 'Over Budget' : 'Remaining Balance',
                      value: isOverBudget
                          ? '-${AppConstants.currencySymbol}${fmtAmount(remaining.abs())}'
                          : '${AppConstants.currencySymbol}${fmtAmount(remaining)}',
                      icon: isOverBudget
                          ? Icons.warning_amber_rounded
                          : Icons.account_balance_wallet_rounded,
                      iconColor: isOverBudget ? AppColors.error : AppColors.success,
                      iconBgColor: isOverBudget ? AppColors.errorBg : AppColors.successBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Largest Expense',
                      value: '${AppConstants.currencySymbol}${fmtAmount(largestExpense)}',
                      icon: Icons.arrow_upward_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Expense Count',
                      value: '${expenses.length}',
                      icon: Icons.format_list_numbered_rounded,
                      iconColor: AppColors.info,
                      iconBgColor: AppColors.infoBg,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Grouped expenses
        for (final key in sortedKeys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionHeader(
              title: key,
              subtitle: '${grouped[key]!.length} entries · ${AppConstants.currencySymbol}${fmtAmount(grouped[key]!.fold<int>(0, (s, e) => s + e.amount))}',
            ),
          ),
          ...grouped[key]!.map((e) => ExpenseTile(
                expense: e,
                onDelete: () => _handleDelete(context, ref, e),
              )),
        ],
      ],
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final amountStr = '${AppConstants.currencySymbol}${fmtAmount(expense.amount)}';
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Expense',
      message: 'Delete expense of $amountStr? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteExpense(expense.id);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete expense. Please try again.')),
        );
      }
    }
  }
}
