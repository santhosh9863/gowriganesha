import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/expense_budget.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';

class ExpenseBudgetRepository {
  final FirebaseFirestore _firestore;

  ExpenseBudgetRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('expense_budget');

  String generateId() => _firestore.collection('_').doc().id;

  Stream<List<ExpenseBudget>> watchAll() {
    return _collection
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseBudget.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<ExpenseBudget?> get(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ExpenseBudget.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[EXP_BUDGET_REPO] Error fetching: $e');
      throw FirestoreException('Failed to fetch expense budget item', originalError: e);
    }
  }

  Future<void> set(ExpenseBudget item) async {
    try {
      await _collection.doc(item.id).set(item.toMap());
      debugPrint('[EXP_BUDGET_REPO] Set: ${item.id}');
    } on FirebaseException catch (e) {
      debugPrint('[EXP_BUDGET_REPO] Error setting: $e');
      throw FirestoreException('Failed to save expense budget item', originalError: e);
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).update(data);
      debugPrint('[EXP_BUDGET_REPO] Updated: $id');
    } on FirebaseException catch (e) {
      debugPrint('[EXP_BUDGET_REPO] Error updating: $e');
      throw FirestoreException('Failed to update expense budget item', originalError: e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _collection.doc(id).delete();
      debugPrint('[EXP_BUDGET_REPO] Deleted: $id');
    } on FirebaseException catch (e) {
      debugPrint('[EXP_BUDGET_REPO] Error deleting: $e');
      throw FirestoreException('Failed to delete expense budget item', originalError: e);
    }
  }

  Future<void> reorder(List<String> orderedIds) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(_collection.doc(orderedIds[i]), {
          'displayOrder': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('[EXP_BUDGET_REPO] Reordered ${orderedIds.length} items');
    } on FirebaseException catch (e) {
      debugPrint('[EXP_BUDGET_REPO] Error reordering: $e');
      throw FirestoreException('Failed to reorder expense budget', originalError: e);
    }
  }
}
