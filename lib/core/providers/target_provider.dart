import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final targetsStreamProvider = StreamProvider<List<Target>>((ref) {
  final service = ref.read(firestoreProvider);
  return service.watchTargets(AppConstants.festivalId);
});

final targetByIdProvider = Provider.family<Target?, String>((ref, id) {
  final targets = ref.watch(targetsStreamProvider).valueOrNull ?? [];
  return targets.where((t) => t.id == id).firstOrNull;
});
