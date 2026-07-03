import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/expense_budget.dart';
import 'package:ganesha_2026/core/services/expense_budget_repository.dart';

class _SeedCategory {
  final String name;
  final int amount;
  const _SeedCategory(this.name, this.amount);
}

const _seedCategories = [
  // Decorations & Setup
  _SeedCategory('Gowri Ganesha', 50000),
  _SeedCategory('Tent', 70000),
  _SeedCategory('Flower Decoration', 40000),
  _SeedCategory('Lightings and Sounds', 50000),
  _SeedCategory('Flags and Shawl', 5000),
  _SeedCategory('Banner, Book and Pamphlets', 7000),
  // Entertainment & Activities
  _SeedCategory('Tamte', 60000),
  _SeedCategory('Crackers', 5000),
  _SeedCategory('Paper Blast', 10000),
  _SeedCategory('Prizes', 7000),
  // Food & Supplies
  _SeedCategory('Annadhaana', 60000),
  _SeedCategory('Fruits and Flowers', 12000),
  _SeedCategory('Plates', 10000),
  // Personnel & Miscellaneous
  _SeedCategory('Tractors and Generator', 5000),
  _SeedCategory('Sanmaana', 3000),
  _SeedCategory('Poojaari', 5000),
  _SeedCategory('T-shirt', 5000),
  _SeedCategory('Others', 15000),
];

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

  Future<int> seedIfEmpty() async {
    final empty = await _repository.isEmpty();
    if (!empty) {
      debugPrint('[EXP_BUDGET_SERVICE] Categories exist — skipping seed');
      return 0;
    }

    final now = Timestamp.now();
    var count = 0;
    for (var i = 0; i < _seedCategories.length; i++) {
      final cat = _seedCategories[i];
      await _repository.set(ExpenseBudget(
        id: _repository.generateId(),
        name: cat.name,
        plannedAmount: cat.amount,
        displayOrder: i,
        createdAt: now,
        updatedAt: now,
      ));
      count++;
    }
    debugPrint('[EXP_BUDGET_SERVICE] Seeded $count categories');
    return count;
  }
}
