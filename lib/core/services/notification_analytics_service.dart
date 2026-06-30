import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Aggregated notification analytics with periodic batch upload.
///
/// Maintains in-memory counters and flushes to Firestore daily-bucketed
/// documents every 30s or when 50 events accumulate, whichever comes first.
class NotificationAnalyticsService {
  final FirebaseFirestore _firestore;
  Timer? _flushTimer;

  int _pendingCount = 0;

  static const int _flushThreshold = 50;
  static const Duration _flushInterval = Duration(seconds: 30);

  final Map<String, _DailyCounter> _dailyCounters = {};

  NotificationAnalyticsService(this._firestore);

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  _DailyCounter _counterFor(String? category) {
    final key = '$_todayKey:${category ?? 'unknown'}';
    return _dailyCounters.putIfAbsent(key, () => _DailyCounter());
  }

  void trackSent({String? category}) {
    _counterFor(category).sent++;
    _increment();
  }

  void trackOpened({String? category}) {
    _counterFor(category).opened++;
    _increment();
  }

  void trackFailed({String? category, String? error}) {
    _counterFor(category).failed++;
    _increment();
  }

  void trackDeduplicated({String? category}) {
    _counterFor(category).deduplicated++;
    _increment();
  }

  void _increment() {
    _pendingCount++;
    if (_pendingCount >= _flushThreshold) {
      _flushNow();
    } else if (_flushTimer == null || !_flushTimer!.isActive) {
      _flushTimer = Timer(_flushInterval, _flushNow);
    }
  }

  Future<void> _flushNow() async {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_dailyCounters.isEmpty) return;

    final pending = Map<String, _DailyCounter>.from(_dailyCounters);
    _dailyCounters.clear();
    _pendingCount = 0;

    try {
      final batch = _firestore.batch();
      for (final entry in pending.entries) {
        final parts = entry.key.split(':');
        final dateKey = parts[0];
        final category = parts[1];
        final counter = entry.value;

        final docRef = _firestore
            .collection('notification_analytics')
            .doc(dateKey);

        batch.set(docRef, {
          'date': dateKey,
          'categories.$category.sent':
              FieldValue.increment(counter.sent),
          'categories.$category.opened':
              FieldValue.increment(counter.opened),
          'categories.$category.failed':
              FieldValue.increment(counter.failed),
          'categories.$category.deduplicated':
              FieldValue.increment(counter.deduplicated),
          'total.sent': FieldValue.increment(counter.sent),
          'total.opened': FieldValue.increment(counter.opened),
          'total.failed': FieldValue.increment(counter.failed),
          'total.deduplicated':
              FieldValue.increment(counter.deduplicated),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('[ANALYTICS] Flushed ${pending.length} buckets');
    } on FirebaseException catch (e) {
      debugPrint('[ANALYTICS] Flush error: $e');
      for (final entry in pending.entries) {
        _dailyCounters[entry.key] = entry.value;
      }
      _pendingCount = pending.values
          .fold(0, (total, c) => total + c.sent + c.opened + c.failed + c.deduplicated);
    }
  }

  void dispose() {
    _flushTimer?.cancel();
  }
}

class _DailyCounter {
  int sent = 0;
  int opened = 0;
  int failed = 0;
  int deduplicated = 0;
}
