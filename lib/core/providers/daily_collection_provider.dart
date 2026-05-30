import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final dailyCollectionsStreamProvider = StreamProvider<List<DailyCollection>>((ref) {
  final service = ref.read(firestoreProvider);
  return service.watchDailyCollections(AppConstants.festivalId);
});
