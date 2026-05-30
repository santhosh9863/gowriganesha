import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/features/expenses/expense_tile.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class ExpenseListPage extends ConsumerWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) => _buildList(context, ref, expenses, theme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Expense> expenses,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses recorded',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first expense',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final totalExpenses =
        expenses.fold<int>(0, (sum, e) => sum + e.amount);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ExpenseTile(
                expense: expense,
                onDelete: () => _handleDelete(context, ref, expense),
              );
            },
          ),
        ),
        _ExpensesFooter(
          totalExpenses: totalExpenses,
          theme: theme,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final amountStr = '${AppConstants.currencySymbol}${formatter.format(expense.amount)}';
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Expense',
      message:
          'Delete expense of $amountStr? This cannot be undone.',
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

class _ExpensesFooter extends StatelessWidget {
  final int totalExpenses;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _ExpensesFooter({
    required this.totalExpenses,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 20,
            color: colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Expenses',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                AmountText(
                  amount: totalExpenses,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
