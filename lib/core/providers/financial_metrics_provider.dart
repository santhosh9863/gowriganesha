import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/daily_collection_provider.dart';
import 'package:ganesha_2026/core/providers/budget_provider.dart';

class FinancialMetrics {
  /// Total money collected from ALL sources (sponsors + daily collections)
  final int totalCollected;

  /// Sum of all sponsor givenAmounts
  final int sponsorCollected;

  /// Sum of all sponsor expectedAmounts (commitments)
  final int sponsorCommitments;

  /// Sponsor commitments minus sponsor collected
  final int sponsorRemaining;

  /// Sum of all daily collection amounts
  final int dailyCollected;

  /// Sum of all expenses
  final int totalExpenses;

  /// Cash on hand: totalCollected - totalExpenses
  final int cashBalance;

  /// How much more needs to be collected: festivalGoal - totalCollected
  final int remainingGoal;

  /// How much of the budget is left to spend: festivalBudget - totalExpenses
  final int remainingBudget;

  /// The festival goal (budget from Firestore, or sum of sponsor commitments)
  final int festivalGoal;

  /// The festival budget from Firestore settings
  final int festivalBudget;

  /// Percentage of goal achieved: (totalCollected / festivalGoal) * 100
  final double progressPercentage;

  const FinancialMetrics({
    required this.totalCollected,
    required this.sponsorCollected,
    required this.sponsorCommitments,
    required this.sponsorRemaining,
    required this.dailyCollected,
    required this.totalExpenses,
    required this.cashBalance,
    required this.remainingGoal,
    required this.remainingBudget,
    required this.festivalGoal,
    required this.festivalBudget,
    required this.progressPercentage,
  });
}

final financialMetricsProvider = Provider<FinancialMetrics>((ref) {
  final targetsAsync = ref.watch(targetsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final dailyCollectionsAsync = ref.watch(dailyCollectionsStreamProvider);
  final budgetAsync = ref.watch(budgetProvider);

  final targets = targetsAsync.valueOrNull ?? [];
  final expenses = expensesAsync.valueOrNull ?? [];
  final dailyCollections = dailyCollectionsAsync.valueOrNull ?? [];

  final sponsorCollected = targets.fold<int>(0, (v, t) => v + t.givenAmount);
  final sponsorCommitments = targets.fold<int>(0, (v, t) => v + t.expectedAmount);
  final sponsorRemaining = sponsorCommitments - sponsorCollected;
  final dailyCollected = dailyCollections.fold<int>(0, (v, dc) => v + dc.amount);
  final totalCollected = sponsorCollected + dailyCollected;

  final totalExpenses = expenses.fold<int>(0, (v, e) => v + e.amount);

  final expectedFromTargets = sponsorCommitments;
  final festivalBudget = budgetAsync.valueOrNull ?? expectedFromTargets;
  final festivalGoal = festivalBudget > 0 ? festivalBudget : expectedFromTargets;

  final cashBalance = totalCollected - totalExpenses;
  final remainingGoal = festivalGoal - totalCollected;
  final remainingBudget = festivalBudget - totalExpenses;
  final progressPercentage = festivalGoal > 0
      ? (totalCollected / festivalGoal) * 100
      : 0.0;

  return FinancialMetrics(
    totalCollected: totalCollected,
    sponsorCollected: sponsorCollected,
    sponsorCommitments: sponsorCommitments,
    sponsorRemaining: sponsorRemaining,
    dailyCollected: dailyCollected,
    totalExpenses: totalExpenses,
    cashBalance: cashBalance,
    remainingGoal: remainingGoal,
    remainingBudget: remainingBudget,
    festivalGoal: festivalGoal,
    festivalBudget: festivalBudget,
    progressPercentage: progressPercentage,
  );
});
