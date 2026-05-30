import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final activitiesStreamProvider = StreamProvider<List<Activity>>((ref) {
  final service = ref.read(firestoreProvider);
  return service.watchActivities(AppConstants.festivalId);
});
