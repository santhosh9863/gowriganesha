import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/providers/dashboard_provider.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';

class BalancePage extends ConsumerWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Balance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FinanceRow(
              label: 'Expected Collection',
              amount: dashboard.expectedTotal,
              color: colorScheme.primary,
              theme: theme,
            ),
            const SizedBox(height: 8),
            _FinanceRow(
              label: 'Collected Amount',
              amount: dashboard.collectedTotal,
              color: colorScheme.tertiary,
              theme: theme,
            ),
            const SizedBox(height: 8),
            _FinanceRow(
              label: 'Remaining Collection',
              amount: dashboard.remainingCollection,
              color: colorScheme.error,
              theme: theme,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            _FinanceRow(
              label: 'Total Expenses',
              amount: dashboard.totalExpenses,
              color: colorScheme.error,
              theme: theme,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            const SizedBox(height: 8),
            _BalanceCard(
              balance: dashboard.balance,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),
            _EfficiencySection(
              percent: dashboard.progressPercent,
              theme: theme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final ThemeData theme;

  const _FinanceRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AmountText(
          amount: amount,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _BalanceCard({
    required this.balance,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance > 0;
    final isNegative = balance < 0;
    final displayColor = isPositive
        ? colorScheme.tertiary
        : isNegative
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;

    return Card(
      color: displayColor.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: displayColor.withAlpha(60)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              isPositive
                  ? Icons.arrow_circle_up_rounded
                  : isNegative
                      ? Icons.arrow_circle_down_rounded
                      : Icons.remove_circle_outline_rounded,
              color: displayColor,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: displayColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AmountText(
                    amount: balance.abs(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: displayColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EfficiencySection extends StatelessWidget {
  final double percent;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _EfficiencySection({
    required this.percent,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collection Efficiency',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 12,
            backgroundColor: colorScheme.primaryContainer.withAlpha(80),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Sponsor: ${percent.toStringAsFixed(1)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
