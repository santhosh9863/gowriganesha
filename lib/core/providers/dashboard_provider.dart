import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/daily_collection_provider.dart';
import 'package:ganesha_2026/core/providers/budget_provider.dart';

class DashboardData {
  final int expectedTotal;
  final int collectedTotal;
  final int totalExpenses;
  final int balance;
  final int remainingCollection;
  final double progressPercent;
  final int todayCollection;
  final int todayEntryCount;
  final int totalDailyCollections;
  final int pendingSponsorCount;
  final int pendingRemainingTotal;

  const DashboardData({
    required this.expectedTotal,
    required this.collectedTotal,
    required this.totalExpenses,
    required this.balance,
    required this.remainingCollection,
    required this.progressPercent,
    required this.todayCollection,
    required this.todayEntryCount,
    required this.totalDailyCollections,
    required this.pendingSponsorCount,
    required this.pendingRemainingTotal,
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final targetsAsync = ref.watch(targetsStreamProvider);
  final expensesAsync = ref.watch(expensesStreamProvider);
  final dailyCollectionsAsync = ref.watch(dailyCollectionsStreamProvider);
  final budgetAsync = ref.watch(budgetProvider);

  final targets = targetsAsync.valueOrNull ?? [];
  final expenses = expensesAsync.valueOrNull ?? [];
  final dailyCollections = dailyCollectionsAsync.valueOrNull ?? [];

  final expectedFromTargets =
      targets.fold<int>(0, (v, t) => v + t.expectedAmount);
  final budget = budgetAsync.valueOrNull ?? expectedFromTargets;
  final expectedTotal = budget > 0 ? budget : expectedFromTargets;
  final sponsorCollected =
      targets.fold<int>(0, (v, t) => v + t.givenAmount);
  final totalDaily =
      dailyCollections.fold<int>(0, (v, dc) => v + dc.amount);
  final collectedTotal = sponsorCollected + totalDaily;
  final totalExpenses =
      expenses.fold<int>(0, (v, e) => v + e.amount);
  final balance = collectedTotal - totalExpenses;
  final remainingCollection = expectedTotal - collectedTotal;
  final progressPercent = expectedTotal > 0
      ? (collectedTotal / expectedTotal) * 100
      : 0.0;

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));
  final todayItems = dailyCollections
      .where((dc) =>
          dc.date.toDate().isAfter(todayStart) &&
          dc.date.toDate().isBefore(todayEnd))
      .toList();
  final todayCollection = todayItems.fold<int>(0, (v, dc) => v + dc.amount);
  final todayEntryCount = todayItems.length;

  final totalDailyCollections = totalDaily;

  final pending = targets.where((t) => t.givenAmount < t.expectedAmount).toList();
  final pendingSponsorCount = pending.length;
  final pendingRemainingTotal = pending.fold<int>(0, (v, t) => v + (t.expectedAmount - t.givenAmount));

  return DashboardData(
    expectedTotal: expectedTotal,
    collectedTotal: collectedTotal,
    totalExpenses: totalExpenses,
    balance: balance,
    remainingCollection: remainingCollection,
    progressPercent: progressPercent,
    todayCollection: todayCollection,
    todayEntryCount: todayEntryCount,
    totalDailyCollections: totalDailyCollections,
    pendingSponsorCount: pendingSponsorCount,
    pendingRemainingTotal: pendingRemainingTotal,
  );
});
