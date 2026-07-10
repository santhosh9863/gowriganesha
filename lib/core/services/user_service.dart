import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/user.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';

class UserService {
  final FirestoreService _firestore;

  UserService({required FirestoreService firestore}) : _firestore = firestore;

  Future<bool> registerUser({
    required String userId,
    required String name,
    required UserRole role,
    required String firebaseUid,
    String email = '',
    String? device,
  }) async {
    final existing = await _firestore.getUser(userId);

    if (existing != null) {
      final updates = <String, dynamic>{
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true,
        'loginCount': FieldValue.increment(1),
        'device': device,
      };
      try {
        await _firestore.updateUser(userId, updates);
        debugPrint('[USER_SVC] Updated existing user: $userId');
      } catch (e) {
        debugPrint('[USER_SVC] Error updating user: $userId — $e');
        rethrow;
      }
      return false;
    }

    final user = AppUser(
      id: userId,
      festivalId: AppConstants.festivalId,
      name: name,
      email: email,
      role: role,
      firebaseUid: firebaseUid,
      registeredAt: Timestamp.now(),
      lastActive: Timestamp.now(),
      isOnline: true,
      device: device,
      loginCount: 1,
    );

    try {
      await _firestore.addUser(user);
      debugPrint('[USER_SVC] Created new user: $userId');
    } catch (e) {
      debugPrint('[USER_SVC] Error creating user: $userId — $e');
      rethrow;
    }
    return true;
  }

  Future<void> updateActivity(String userId) async {
    try {
      await _firestore.updateUser(userId, {
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      debugPrint('[USER_SVC] Error updating activity for $userId — $e');
    }
  }

  Future<void> setOffline(String userId) async {
    try {
      await _firestore.updateUser(userId, {
        'isOnline': false,
      });
    } catch (e) {
      debugPrint('[USER_SVC] Error setting offline for $userId — $e');
    }
  }

  Future<AppUser?> getUser(String userId) async {
    try {
      return await _firestore.getUser(userId);
    } catch (e) {
      debugPrint('[USER_SVC] Error fetching user $userId — $e');
      return null;
    }
  }

  Future<void> ensureUserExists({
    required String userId,
    required String name,
    required UserRole role,
    required String firebaseUid,
    String? device,
  }) async {
    final existing = await _firestore.getUser(userId);
    if (existing != null) return;

    final user = AppUser(
      id: userId,
      festivalId: AppConstants.festivalId,
      name: name,
      role: role,
      firebaseUid: firebaseUid,
      registeredAt: Timestamp.now(),
      lastActive: Timestamp.now(),
      isOnline: true,
      device: device,
      loginCount: 1,
    );

    try {
      await _firestore.addUser(user);
      debugPrint('[USER_SVC] Backfilled user: $userId');
    } catch (e) {
      debugPrint('[USER_SVC] Error backfilling user: $userId — $e');
    }
  }
}
