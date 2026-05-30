import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/providers/daily_collection_provider.dart';

class DailyCollectionPoint {
  final DateTime date;
  final int amount;
  final String label;
  DailyCollectionPoint({
    required this.date,
    required this.amount,
    required this.label,
  });
}

final dailyChartProvider = Provider<List<DailyCollectionPoint>>((ref) {
  final collections =
      ref.watch(dailyCollectionsStreamProvider).valueOrNull ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dayAmounts = <int, int>{};

  for (final dc in collections) {
    final d = dc.date.toDate();
    final dayKey = DateTime(d.year, d.month, d.day);
    final diff = dayKey.difference(today).inDays;
    if (diff > -14 && diff <= 0) {
      dayAmounts[dayKey.millisecondsSinceEpoch] =
          (dayAmounts[dayKey.millisecondsSinceEpoch] ?? 0) + dc.amount;
    }
  }

  final result = <DailyCollectionPoint>[];
  for (int i = 13; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    final key = d.millisecondsSinceEpoch;
    final amount = dayAmounts[key] ?? 0;
    String label;
    if (i == 0) {
      label = 'Today';
    } else if (i == 1) {
      label = 'Yest';
    } else {
      label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
    }
    result.add(DailyCollectionPoint(
      date: d,
      amount: amount,
      label: label,
    ));
  }

  return result;
});
