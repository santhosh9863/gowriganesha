import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _preferences =>
      _firestore.collection('notification_preferences');

  String createNotificationId() => _firestore.collection('_').doc().id;

  Future<void> createNotification(AppNotification notification) async {
    try {
      await _notifications.doc(notification.id).set(notification.toMap());
      debugPrint('[NOTIFICATION_REPO] Created: ${notification.id}');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error creating: $e');
      throw FirestoreException('Failed to create notification', originalError: e);
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
        .where('archivedAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
      debugPrint('[NOTIFICATION_REPO] Error watching stream: $e');
    }).map((snapshot) {
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
        'readAt': FieldValue.serverTimestamp(),
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
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<int> getUnreadCount(String userId, {String? targetRole}) async {
    try {
      final snapshot = await _notifications
          .where('archivedAt', isNull: true)
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

  Future<int> archiveOldNotifications({int olderThanDays = 90}) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: olderThanDays)),
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

  /// Retrieves raw notification preferences for the given user.
  ///
  /// NOTE: Returns raw Map. A typed NotificationPreferences model will replace
  /// this in a later phase. Do not pass this raw map beyond the repository boundary.
  Future<Map<String, dynamic>?> getPreferences(String userId) async {
    try {
      final doc = await _preferences.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return doc.data();
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error fetching preferences: $e');
      throw FirestoreException('Failed to load notification preferences', originalError: e);
    }
  }

  /// Saves raw notification preferences for the given user.
  ///
  /// NOTE: Accepts raw Map. A typed NotificationPreferences model will replace
  /// this in a later phase. Do not pass raw maps from outside the repository.
  Future<void> setPreferences(String userId, Map<String, dynamic> preferences) async {
    try {
      await _preferences.doc(userId).set({
        ...preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[NOTIFICATION_REPO] Preferences saved for $userId');
    } on FirebaseException catch (e) {
      debugPrint('[NOTIFICATION_REPO] Error saving preferences: $e');
      throw FirestoreException('Failed to save notification preferences', originalError: e);
    }
  }
}
