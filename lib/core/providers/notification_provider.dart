import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';
import 'package:ganesha_2026/core/services/notification_service.dart';
import 'package:ganesha_2026/core/services/notification_navigator.dart';
import 'package:ganesha_2026/core/services/notification_permission_service.dart';
import 'package:ganesha_2026/core/services/local_notification_service.dart';
import 'package:ganesha_2026/core/services/activity_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationService(repository: repo);
});

final activityServiceProvider = Provider<ActivityService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final notificationRepo = ref.watch(notificationRepositoryProvider);
  return ActivityService(
    firestore: firestore,
    notificationService: notificationService,
    notificationRepository: notificationRepo,
  );
});

final notificationNavigatorProvider = Provider<NotificationNavigator>((ref) {
  return NotificationNavigator();
});

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>((ref) {
  return NotificationPermissionServiceStub();
});

final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationServiceStub();
});

final notificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final role = ref.watch(roleProvider);
  final targetRole =
      role == UserRole.none || role == UserRole.admin ? null : role.name;
  return repo.watchNotifications(targetRole: targetRole);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider);
  final userId = ref.watch(userIdProvider);
  return notifications.valueOrNull
          ?.where((n) => n.isUnreadBy(userId))
          .length ??
      0;
});
