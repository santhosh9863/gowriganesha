import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/festival.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/contribution.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';

class FirestoreException implements Exception {
  final String message;
  final dynamic originalError;
  const FirestoreException(this.message, {this.originalError});
  @override
  String toString() => message;
}

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  CollectionReference<Map<String, dynamic>> get _festivals =>
      _firestore.collection('festivals');

  CollectionReference<Map<String, dynamic>> get _targets =>
      _firestore.collection('targets');

  CollectionReference<Map<String, dynamic>> get _expenses =>
      _firestore.collection('expenses');

  CollectionReference<Map<String, dynamic>> get _dailyCollections =>
      _firestore.collection('daily_collections');

  CollectionReference<Map<String, dynamic>> get _followUps =>
      _firestore.collection('sponsor_followups');

  CollectionReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('settings');

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore.collection('activities');

  String generateId() => _firestore.collection('_').doc().id;

  Future<int> getBudget(String settingsId) async {
    try {
      final doc = await _settings.doc(settingsId).get();
      if (!doc.exists || doc.data() == null) return 0;
      return doc.data()!['festivalBudget'] as int? ?? 0;
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching budget: $e');
      throw FirestoreException('Failed to load budget', originalError: e);
    }
  }

  Future<void> setBudget(String settingsId, int amount) async {
    try {
      await _settings.doc(settingsId).set({'festivalBudget': amount});
      debugPrint('[FIRESTORE] Budget updated: $settingsId → $amount');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error setting budget: $e');
      throw FirestoreException('Failed to save budget', originalError: e);
    }
  }

  Reference get _qrRef => FirebaseStorage.instance
      .ref('festival-assets/${AppConstants.festivalId}/payment_qr.png');

  Future<String> uploadQrImage(File image) async {
    try {
      final task = await _qrRef.putFile(image);
      final url = await task.ref.getDownloadURL();
      debugPrint('[STORAGE] QR image uploaded');
      return url;
    } on FirebaseException catch (e) {
      debugPrint('[STORAGE] Error uploading QR: $e');
      throw FirestoreException('Failed to upload QR image', originalError: e);
    }
  }

  Future<void> deleteQrImage() async {
    try {
      await _qrRef.delete();
      debugPrint('[STORAGE] QR image deleted');
    } on FirebaseException catch (e) {
      debugPrint('[STORAGE] Error deleting QR: $e');
    }
  }

  Future<Festival?> getFestival(String festivalId) async {
    try {
      final doc = await _festivals.doc(festivalId).get();
      if (!doc.exists || doc.data() == null) {
        debugPrint('[FIRESTORE] Festival not found: $festivalId');
        return null;
      }
      debugPrint('[FIRESTORE] Festival found: $festivalId');
      return Festival.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching festival: $e');
      throw FirestoreException('Failed to load festival data', originalError: e);
    }
  }

  Future<void> setFestival(Festival festival) async {
    try {
      await _festivals.doc(festival.id).set(festival.toMap());
      debugPrint('[FIRESTORE] Festival created: ${festival.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error creating festival: $e');
      throw FirestoreException('Failed to create festival', originalError: e);
    }
  }

  Future<List<Target>> getAllTargets(String festivalId) async {
    try {
      final snapshot = await _targets
          .where('festivalId', isEqualTo: festivalId)
          .get();
      return snapshot.docs
          .map((doc) => Target.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching all targets: $e');
      throw FirestoreException('Failed to load targets', originalError: e);
    }
  }

  Future<List<Expense>> getAllExpenses(String festivalId) async {
    try {
      final snapshot = await _expenses
          .where('festivalId', isEqualTo: festivalId)
          .get();
      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching all expenses: $e');
      throw FirestoreException('Failed to load expenses', originalError: e);
    }
  }

  Future<List<DailyCollection>> getAllDailyCollections(String festivalId) async {
    try {
      final snapshot = await _dailyCollections
          .where('festivalId', isEqualTo: festivalId)
          .get();
      return snapshot.docs
          .map((doc) => DailyCollection.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching all daily collections: $e');
      throw FirestoreException('Failed to load daily collections', originalError: e);
    }
  }

  Future<List<SponsorFollowup>> getAllFollowUps(String festivalId) async {
    try {
      final snapshot = await _followUps
          .where('festivalId', isEqualTo: festivalId)
          .get();
      return snapshot.docs
          .map((doc) => SponsorFollowup.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching all follow-ups: $e');
      throw FirestoreException('Failed to load follow-ups', originalError: e);
    }
  }

  Future<List<Activity>> getAllActivities(String festivalId) async {
    try {
      final snapshot = await _activities
          .where('festivalId', isEqualTo: festivalId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Activity.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching all activities: $e');
      throw FirestoreException('Failed to load activities', originalError: e);
    }
  }

  Stream<List<Target>> watchTargets(String festivalId) {
    return _targets
        .where('festivalId', isEqualTo: festivalId)
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error watching targets: $e');
    }).map((snapshot) {
      final targets = snapshot.docs.map((doc) {
        return Target.fromMap(doc.id, doc.data());
      }).toList();
      targets.sort((a, b) => b.expectedAmount.compareTo(a.expectedAmount));
      return targets;
    });
  }

  Future<Target?> getTarget(String targetId) async {
    try {
      final doc = await _targets.doc(targetId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Target.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching target: $e');
      throw FirestoreException('Failed to load target', originalError: e);
    }
  }

  Future<bool> targetsExist(String festivalId) async {
    try {
      final snapshot = await _targets
          .where('festivalId', isEqualTo: festivalId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error checking targets: $e');
      throw FirestoreException('Failed to check existing targets', originalError: e);
    }
  }

  Future<void> addTarget(Target target) async {
    try {
      await _targets.doc(target.id).set(target.toMap());
      debugPrint('[FIRESTORE] Target added: ${target.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error adding target: $e');
      throw FirestoreException('Failed to add target', originalError: e);
    }
  }

  Future<void> updateTarget(Target target) async {
    try {
      await _targets.doc(target.id).update(target.toMap());
      debugPrint('[FIRESTORE] Target updated: ${target.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error updating target: $e');
      throw FirestoreException('Failed to update target', originalError: e);
    }
  }

  Future<void> deleteTarget(String targetId) async {
    try {
      await _targets.doc(targetId).delete();
      debugPrint('[FIRESTORE] Target deleted: $targetId');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error deleting target: $e');
      throw FirestoreException('Failed to delete target', originalError: e);
    }
  }

  Future<int> deleteAllTargets(String festivalId) async {
    try {
      final snapshot = await _targets
          .where('festivalId', isEqualTo: festivalId)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('[FIRESTORE] Deleted ${snapshot.docs.length} targets');
      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error deleting all targets: $e');
      throw FirestoreException('Failed to clear targets', originalError: e);
    }
  }

  Stream<List<Contribution>> streamContributions(String targetId) {
    return _targets
        .doc(targetId)
        .collection('contributions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error streaming contributions: $e');
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) => Contribution.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> recordContribution({
    required String targetId,
    required int amount,
    String note = '',
    String recordedBy = 'system',
  }) async {
    try {
      final batch = _firestore.batch();
      final targetRef = _targets.doc(targetId);
      final contributionRef = targetRef.collection('contributions').doc();

      batch.update(targetRef, {
        'givenAmount': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(contributionRef, {
        'type': ContributionType.contribution.name,
        'amount': amount,
        'note': note,
        'recordedBy': recordedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('[FIRESTORE] Contribution recorded: ${contributionRef.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error recording contribution: $e');
      throw FirestoreException('Failed to record contribution', originalError: e);
    }
  }

  Future<void> recordCorrection({
    required String targetId,
    required int currentTotal,
    required int newTotal,
    String note = '',
    String recordedBy = 'system',
  }) async {
    if (newTotal < 0) {
      throw FirestoreException('New total cannot be negative');
    }

    final delta = newTotal - currentTotal;
    if (delta == 0) return;

    try {
      final batch = _firestore.batch();
      final targetRef = _targets.doc(targetId);
      final contributionRef = targetRef.collection('contributions').doc();

      batch.update(targetRef, {
        'givenAmount': FieldValue.increment(delta),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(contributionRef, {
        'type': ContributionType.correction.name,
        'amount': delta,
        'note': note,
        'recordedBy': recordedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('[FIRESTORE] Correction recorded: ${contributionRef.id} (delta=$delta)');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error recording correction: $e');
      throw FirestoreException('Failed to record correction', originalError: e);
    }
  }

  Stream<List<Expense>> watchExpenses(String festivalId) {
    return _expenses
        .where('festivalId', isEqualTo: festivalId)
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error watching expenses: $e');
    }).map((snapshot) {
      final expenses = snapshot.docs.map((doc) {
        return Expense.fromMap(doc.id, doc.data());
      }).toList();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    });
  }

  Future<Expense?> getExpense(String expenseId) async {
    try {
      final doc = await _expenses.doc(expenseId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Expense.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching expense: $e');
      throw FirestoreException('Failed to load expense', originalError: e);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _expenses.doc(expense.id).set(expense.toMap());
      debugPrint('[FIRESTORE] Expense added: ${expense.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error adding expense: $e');
      throw FirestoreException('Failed to add expense', originalError: e);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _expenses.doc(expense.id).update(expense.toMap());
      debugPrint('[FIRESTORE] Expense updated: ${expense.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error updating expense: $e');
      throw FirestoreException('Failed to update expense', originalError: e);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expenses.doc(expenseId).delete();
      debugPrint('[FIRESTORE] Expense deleted: $expenseId');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error deleting expense: $e');
      throw FirestoreException('Failed to delete expense', originalError: e);
    }
  }

  Stream<List<DailyCollection>> watchDailyCollections(String festivalId) {
    return _dailyCollections
        .where('festivalId', isEqualTo: festivalId)
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error watching daily collections: $e');
    }).map((snapshot) {
      final collections = snapshot.docs.map((doc) {
        return DailyCollection.fromMap(doc.id, doc.data());
      }).toList();
      collections.sort((a, b) => b.date.compareTo(a.date));
      return collections;
    });
  }

  Future<DailyCollection?> getDailyCollection(String id) async {
    try {
      final doc = await _dailyCollections.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return DailyCollection.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching daily collection: $e');
      throw FirestoreException('Failed to load daily collection', originalError: e);
    }
  }

  Future<void> addDailyCollection(DailyCollection dc) async {
    try {
      await _dailyCollections.doc(dc.id).set(dc.toMap());
      debugPrint('[FIRESTORE] Daily collection added: ${dc.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error adding daily collection: $e');
      throw FirestoreException('Failed to add daily collection', originalError: e);
    }
  }

  Future<void> updateDailyCollection(DailyCollection dc) async {
    try {
      await _dailyCollections.doc(dc.id).update(dc.toMap());
      debugPrint('[FIRESTORE] Daily collection updated: ${dc.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error updating daily collection: $e');
      throw FirestoreException('Failed to update daily collection', originalError: e);
    }
  }

  Future<void> deleteDailyCollection(String id) async {
    try {
      await _dailyCollections.doc(id).delete();
      debugPrint('[FIRESTORE] Daily collection deleted: $id');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error deleting daily collection: $e');
      throw FirestoreException('Failed to delete daily collection', originalError: e);
    }
  }

  Stream<List<SponsorFollowup>> watchActiveFollowUps(String festivalId) {
    return _followUps
        .where('festivalId', isEqualTo: festivalId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error watching active follow-ups: $e');
    }).map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return SponsorFollowup.fromMap(doc.id, doc.data());
      }).toList();
      items.sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
      return items;
    });
  }

  Stream<List<SponsorFollowup>> watchAllFollowUps(String festivalId) {
    return _followUps
        .where('festivalId', isEqualTo: festivalId)
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error watching all follow-ups: $e');
    }).map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return SponsorFollowup.fromMap(doc.id, doc.data());
      }).toList();
      items.sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
      return items;
    });
  }

  Future<SponsorFollowup?> getFollowUp(String id) async {
    try {
      final doc = await _followUps.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return SponsorFollowup.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error fetching follow-up: $e');
      throw FirestoreException('Failed to load follow-up', originalError: e);
    }
  }

  Future<void> addFollowUp(SponsorFollowup item) async {
    try {
      await _followUps.doc(item.id).set(item.toMap());
      debugPrint('[FIRESTORE] Follow-up added: ${item.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error adding follow-up: $e');
      throw FirestoreException('Failed to add follow-up', originalError: e);
    }
  }

  Future<void> updateFollowUp(SponsorFollowup item) async {
    try {
      await _followUps.doc(item.id).update(item.toMap());
      debugPrint('[FIRESTORE] Follow-up updated: ${item.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error updating follow-up: $e');
      throw FirestoreException('Failed to update follow-up', originalError: e);
    }
  }

  Future<void> deleteFollowUp(String id) async {
    try {
      await _followUps.doc(id).delete();
      debugPrint('[FIRESTORE] Follow-up deleted: $id');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error deleting follow-up: $e');
      throw FirestoreException('Failed to delete follow-up', originalError: e);
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      await _activities.doc(activity.id).set(activity.toMap());
      debugPrint('[FIRESTORE] Activity added: ${activity.id}');
    } on FirebaseException catch (e) {
      debugPrint('[FIRESTORE] Error adding activity: $e');
    }
  }

  Stream<List<Activity>> watchActivities(String festivalId) {
    return _activities
        .where('festivalId', isEqualTo: festivalId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .handleError((e) {
      debugPrint('[FIRESTORE] Error watching activities: $e');
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) => Activity.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
