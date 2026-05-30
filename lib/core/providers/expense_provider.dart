import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final service = ref.read(firestoreProvider);
  return service.watchExpenses(AppConstants.festivalId);
});
