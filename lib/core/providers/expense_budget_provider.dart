import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/models/expense_budget.dart';
import 'package:ganesha_2026/core/services/expense_budget_repository.dart';
import 'package:ganesha_2026/core/services/expense_budget_service.dart';

final expenseBudgetRepositoryProvider = Provider<ExpenseBudgetRepository>((ref) {
  return ExpenseBudgetRepository(FirebaseFirestore.instance);
});

final expenseBudgetServiceProvider = Provider<ExpenseBudgetService>((ref) {
  final repo = ref.watch(expenseBudgetRepositoryProvider);
  return ExpenseBudgetService(repo);
});

final expenseBudgetStreamProvider =
    StreamProvider<List<ExpenseBudget>>((ref) {
  final service = ref.watch(expenseBudgetServiceProvider);
  return service.watchAll();
});
