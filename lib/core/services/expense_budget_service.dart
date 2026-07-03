import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/expense_budget.dart';
import 'package:ganesha_2026/core/services/expense_budget_repository.dart';

class ExpenseBudgetService {
  final ExpenseBudgetRepository _repository;

  ExpenseBudgetService(this._repository);

  Stream<List<ExpenseBudget>> watchAll() => _repository.watchAll();

  Future<void> create(ExpenseBudget item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Category name is required');
    }
    if (item.plannedAmount <= 0) {
      throw ArgumentError('Planned amount must be positive');
    }
    final now = Timestamp.now();
    final enriched = item.copyWith(
      createdAt: now,
      updatedAt: now,
    );
    await _repository.set(enriched);
  }

  Future<void> update(ExpenseBudget item) async {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Category name is required');
    }
    if (item.plannedAmount <= 0) {
      throw ArgumentError('Planned amount must be positive');
    }
    await _repository.set(item);
  }

  Future<void> delete(String id) async {
    if (id.isEmpty) throw ArgumentError('ID is required');
    await _repository.delete(id);
  }

  Future<void> reorder(List<String> orderedIds) async {
    if (orderedIds.length < 2) return;
    await _repository.reorder(orderedIds);
  }
}
