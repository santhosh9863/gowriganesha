import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final activeFollowUpsStreamProvider =
    StreamProvider<List<SponsorFollowup>>((ref) {
  final service = ref.read(firestoreProvider);
  return service.watchActiveFollowUps(AppConstants.festivalId);
});

final allFollowUpsStreamProvider =
    StreamProvider<List<SponsorFollowup>>((ref) {
  final service = ref.read(firestoreProvider);
  return service.watchAllFollowUps(AppConstants.festivalId);
});

final activeFollowUpsProvider = Provider<List<SponsorFollowup>>((ref) {
  final async = ref.watch(activeFollowUpsStreamProvider);
  final list = async.valueOrNull ?? [];
  return List<SponsorFollowup>.from(list)
    ..sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
});
