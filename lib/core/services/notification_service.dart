import 'package:flutter/foundation.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService({required NotificationRepository repository})
      : _repository = repository;

  Future<String> createNotification(AppNotification notification) async {
    final enriched = notification.copyWith(
      festivalId: AppConstants.festivalId,
    );

    if (!enriched.isValid) {
      throw ArgumentError(
        'Invalid notification: title, body, and senderUserId are required',
      );
    }

    await _repository.createNotification(enriched);
    debugPrint('[NOTIFICATION_SVC] Created: ${enriched.id}');
    return enriched.id;
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    debugPrint('[NOTIFICATION_SVC] Deleted: $id');
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    await _repository.markAsRead(notificationId, userId);
  }

  Future<int> markAllAsRead(String userId, {String? targetRole}) async {
    return _repository.markAllAsRead(userId, targetRole: targetRole);
  }

  Future<int> getUnreadCount(String userId, {String? targetRole}) async {
    return _repository.getUnreadCount(userId, targetRole: targetRole);
  }

  Future<void> archiveNotification(String id) async {
    await _repository.archiveNotification(id);
    debugPrint('[NOTIFICATION_SVC] Archived: $id');
  }

  Future<void> unarchiveNotification(String id) async {
    await _repository.unarchiveNotification(id);
    debugPrint('[NOTIFICATION_SVC] Unarchived: $id');
  }
}
