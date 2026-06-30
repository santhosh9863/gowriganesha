import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/models/contribution.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final contributionsStreamProvider =
    StreamProvider.family<List<Contribution>, String>((ref, targetId) {
  final service = ref.read(firestoreProvider);
  return service.streamContributions(targetId);
});
