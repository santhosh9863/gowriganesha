import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final budgetProvider = FutureProvider<int>((ref) async {
  final service = ref.read(firestoreProvider);
  final budget = await service.getBudget(AppConstants.festivalId);
  if (budget > 0) {
    debugPrint('[BUDGET] Loaded: $budget');
    return budget;
  }
  const defaultBudget = 367000;
  debugPrint('[BUDGET] Not found — creating default: $defaultBudget');
  await service.setBudget(AppConstants.festivalId, defaultBudget);
  return defaultBudget;
});
