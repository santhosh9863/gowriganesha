import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/models/notification_preferences.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  static const Duration _dedupWindow = Duration(seconds: 60);

  NotificationRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _preferences =>
      _firestore.collection('notification_preferences');

  String createNotificationId() => _firestore.collection('_').doc().id;

  static String? _computeDedupKey(AppNotification notification) {
    final entityType = notification.entityType;
    final entityId = notification.entityId;
    if (entityType == null || entityId == null) return null;
    return '$entityType:$entityId:${notification.type.value}:${notification.senderUserId}';
  }

  /// Creates a notification document.
  ///
  /// Returns `true` if the notification was deduplicated (merged into an existing
  /// document), `false` if a new document was created.
  Future<bool> createNotification(AppNotification notification) async {
    try {
      final dedupKey = _computeDedupKey(notification);
      if (dedupKey != null) {
        final deduped = await _tryDedup(notification, dedupKey);
        if (deduped) return true;
      }

      final notificationWithDedupKey = dedupKey != null
          ? notification.copyWith(dedupKey: dedupKey)
          : notification;

      await _notifications.doc(notification.id).set(notificationWithDedupKey.toMap());
      debugPrint('[NOTIFICATION_REPO] Created: ${notification.id}');
      return false;
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error creating: $e');
      throw FirestoreException('Failed to create notification', originalError: e);
    }
  }

  Future<bool> _tryDedup(AppNotification notification, String dedupKey) async {
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(_dedupWindow),
    );

    try {
      final snapshot = await _notifications
          .where('festivalId', isEqualTo: AppConstants.festivalId)
          .where('dedupKey', isEqualTo: dedupKey)
          .where('createdAt', isGreaterThan: cutoff)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final existing = snapshot.docs.first;
      final existingId = existing.id;

      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(existing.reference);
        if (!docSnapshot.exists) return;
        final existingData = docSnapshot.data()!;
        final existingMetadata =
            existingData['metadata'] as Map<String, dynamic>? ?? {};
        final incomingMetadata = notification.metadata ?? <String, dynamic>{};

        final mergedMetadata = <String, dynamic>{
          ...existingMetadata,
          ...incomingMetadata,
        };

        transaction.update(existing.reference, {
          'lastUpdatedAt': FieldValue.serverTimestamp(),
          'metadata': mergedMetadata,
          if (notification.isPinned) 'isPinned': true,
        });
      });

      debugPrint('[NOTIFICATION_REPO] Dedup merged into: $existingId');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Dedup query failed: $e');
      return false;
    }
  }

  Future<AppNotification?> getNotification(String id) async {
    try {
      final doc = await _notifications.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppNotification.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error fetching: $e');
      throw FirestoreException('Failed to get notification', originalError: e);
    }
  }

  Future<void> updateNotification(AppNotification notification) async {
    try {
      await _notifications.doc(notification.id).update(notification.toMap());
      debugPrint('[NOTIFICATION_REPO] Updated: ${notification.id}');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error updating: $e');
      throw FirestoreException('Failed to update notification', originalError: e);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notifications.doc(id).delete();
      debugPrint('[NOTIFICATION_REPO] Deleted: $id');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error deleting: $e');
      throw FirestoreException('Failed to delete notification', originalError: e);
    }
  }

  Stream<List<AppNotification>> watchNotifications({String? targetRole}) {
    return _notifications
        .where('festivalId', isEqualTo: AppConstants.festivalId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => _isTargetedForUser(doc.data(), targetRole))
          .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<AppNotification> watchNotification(String id) {
    return _notifications.doc(id).snapshots().handleError((e) {
      debugPrint('[NOTIFICATION_REPO] Error watching doc: $e');
    }).map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw FirestoreException('Notification not found');
      }
      return AppNotification.fromMap(snapshot.id, snapshot.data()!);
    });
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _notifications.doc(notificationId).update({
        'readBy.$userId': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[NOTIFICATION_REPO] Marked read: $notificationId for $userId');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error marking read: $e');
      throw FirestoreException('Failed to mark notification as read', originalError: e);
    }
  }

  Future<int> markAllAsRead(String userId, {String? targetRole}) async {
    try {
      final unreadDocs = await _findUnreadNotifications(userId, targetRole: targetRole);
      if (unreadDocs.isEmpty) return 0;
      await _batchMarkAsRead(unreadDocs, userId);
      debugPrint('[NOTIFICATION_REPO] Marked ${unreadDocs.length} notifications as read for $userId');
      return unreadDocs.length;
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error marking all as read: $e');
      throw FirestoreException('Failed to mark all notifications as read', originalError: e);
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _findUnreadNotifications(
    String userId, {
    String? targetRole,
  }) async {
    final snapshot = await _notifications
        .where('archivedAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final unread = <DocumentSnapshot<Map<String, dynamic>>>[];
    for (final doc in snapshot.docs) {
      if (!_isTargetedForUser(doc.data(), targetRole)) continue;
      final data = doc.data();
      final readBy = data['readBy'] as Map<String, dynamic>? ?? {};
      if (!readBy.containsKey(userId)) {
        unread.add(doc);
      }
    }
    return unread;
  }

  Future<void> _batchMarkAsRead(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
    String userId,
  ) async {
    final batch = _firestore.batch();
    for (final doc in docs) {
      batch.update(doc.reference, {
        'readBy.$userId': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<int> getUnreadCount(String userId, {String? targetRole}) async {
    try {
      final snapshot = await _notifications
          .where('archivedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      int count = 0;
      for (final doc in snapshot.docs) {
        if (!_isTargetedForUser(doc.data(), targetRole)) continue;
        final data = doc.data();
        final readBy = data['readBy'] as Map<String, dynamic>? ?? {};
        if (readBy.containsKey(userId)) continue;
        count++;
      }
      return count;
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error counting unread: $e');
      throw FirestoreException('Failed to count unread notifications', originalError: e);
    }
  }

  Future<List<AppNotification>> getNotificationsPage({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? targetRole,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _notifications
          .where('archivedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .where((doc) => _isTargetedForUser(doc.data(), targetRole))
          .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error fetching page: $e');
      throw FirestoreException('Failed to fetch notifications page', originalError: e);
    }
  }

  Future<void> archiveNotification(String id) async {
    try {
      await _notifications.doc(id).update({
        'archivedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[NOTIFICATION_REPO] Archived: $id');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error archiving: $e');
      throw FirestoreException('Failed to archive notification', originalError: e);
    }
  }

  Future<void> unarchiveNotification(String id) async {
    try {
      await _notifications.doc(id).update({
        'archivedAt': FieldValue.delete(),
      });
      debugPrint('[NOTIFICATION_REPO] Unarchived: $id');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error unarchiving: $e');
      throw FirestoreException('Failed to unarchive notification', originalError: e);
    }
  }

  Future<int> getRetentionDays() async {
    try {
      final doc = await _firestore
          .collection('settings')
          .doc(AppConstants.festivalId)
          .get();
      if (!doc.exists || doc.data() == null) return 90;
      return (doc.data()!['notificationRetentionDays'] as int?) ?? 90;
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error reading retention: $e');
      return 90;
    }
  }

  Future<int> archiveOldNotifications({int? olderThanDays}) async {
    try {
      final days = olderThanDays ?? await getRetentionDays();
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );

      final snapshot = await _notifications
          .where('archivedAt', isNull: true)
          .where('createdAt', isLessThan: cutoff)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'archivedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      debugPrint('[NOTIFICATION_REPO] Archived ${snapshot.docs.length} notifications');
      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error archiving: $e');
      throw FirestoreException('Failed to archive notifications', originalError: e);
    }
  }

  /// Checks whether a notification document is visible to a user with the given role.
  /// A notification with no targetRole (null) is visible to everyone.
  bool _isTargetedForUser(Map<String, dynamic> data, String? targetRole) {
    if (targetRole == null) return true;
    final notificationRole = data['targetRole'] as String?;
    return notificationRole == null || notificationRole == targetRole;
  }

  /// Saves a device token for push notifications.
  Future<void> saveDeviceToken(
    String token, {
    required String userId,
    required String platform,
  }) async {
    try {
      await _firestore.collection('device_tokens').doc(token).set({
        'token': token,
        'userId': userId,
        'platform': platform,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[NOTIFICATION_REPO] Device token saved for user $userId');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error saving device token: $e');
      throw FirestoreException('Failed to save device token', originalError: e);
    }
  }

  /// Removes a device token.
  Future<void> removeDeviceToken(String token) async {
    try {
      await _firestore.collection('device_tokens').doc(token).delete();
      debugPrint('[NOTIFICATION_REPO] Device token removed');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error removing device token: $e');
      throw FirestoreException('Failed to remove device token', originalError: e);
    }
  }

  Future<NotificationPreferences?> getPreferences(String userId) async {
    try {
      final doc = await _preferences.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return NotificationPreferences.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error fetching preferences: $e');
      throw FirestoreException('Failed to load notification preferences', originalError: e);
    }
  }

  Future<void> setPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    try {
      final data = preferences.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _preferences.doc(userId).set(data);
      debugPrint('[NOTIFICATION_REPO] Preferences saved for $userId');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error saving preferences: $e');
      throw FirestoreException('Failed to save notification preferences', originalError: e);
    }
  }
}
