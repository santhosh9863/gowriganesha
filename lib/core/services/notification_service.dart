import 'package:flutter/foundation.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';
import 'package:ganesha_2026/core/services/notification_analytics_service.dart';

class NotificationService {
  final NotificationRepository _repository;
  final NotificationAnalyticsService? _analytics;

  NotificationService({
    required NotificationRepository repository,
    NotificationAnalyticsService? analytics,
  })  : _repository = repository,
        _analytics = analytics;

  Future<String> createNotification(AppNotification notification) async {
    final enriched = notification.copyWith(
      festivalId: AppConstants.festivalId,
    );

    if (!enriched.isValid) {
      throw ArgumentError(
        'Invalid notification: title, body, and senderUserId are required',
      );
    }

    final deduped = await _repository.createNotification(enriched);

    if (deduped) {
      _analytics?.trackDeduplicated(
        category: notification.category.value,
      );
    } else {
      _analytics?.trackSent(
        category: notification.category.value,
      );
    }

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
