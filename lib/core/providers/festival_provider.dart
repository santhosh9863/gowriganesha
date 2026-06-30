import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/festival.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';

final firestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final festivalProvider = FutureProvider<Festival>((ref) async {
  final service = ref.read(firestoreProvider);
  final festival = await service.getFestival(AppConstants.festivalId);
  if (festival != null) {
    debugPrint('[FIRESTORE] Connection successful');
    return festival;
  }
  throw FirestoreException(
    'Festival "${AppConstants.festivalId}" not found. Please seed it in Firebase Console.',
  );
});
