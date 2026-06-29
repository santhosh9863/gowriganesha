import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/models/notification_preferences.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/services/notification_analytics_service.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';
import 'package:ganesha_2026/core/services/notification_service.dart';
import 'package:ganesha_2026/core/services/notification_navigator.dart';
import 'package:ganesha_2026/core/services/notification_permission_service.dart';
import 'package:ganesha_2026/core/services/local_notification_service.dart';
import 'package:ganesha_2026/core/services/push_notification_service.dart';
import 'package:ganesha_2026/core/services/activity_service.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance);
});

final notificationAnalyticsServiceProvider =
    Provider<NotificationAnalyticsService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final service = NotificationAnalyticsService(firestore);
  ref.onDispose(() => service.dispose());
  return service;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final analytics = ref.watch(notificationAnalyticsServiceProvider);
  return NotificationService(repository: repo, analytics: analytics);
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
  return SankalpaLocalNotificationService();
});

final notificationsStreamProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider);
  final userId = ref.watch(userIdProvider);
  final role = ref.watch(roleProvider);
  final targetRole =
      role == UserRole.none || role == UserRole.admin ? null : role.name;
  return notifications.valueOrNull
          ?.where((n) => n.isUnreadBy(userId))
          .where((n) =>
              targetRole == null ||
              n.targetRole == null ||
              n.targetRole == targetRole)
          .length ??
      0;
});

final pendingNotificationTapProvider =
    StateProvider<({String entityType, String? entityId})?>((ref) => null);

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final localService = ref.watch(localNotificationServiceProvider);
  final analytics = ref.watch(notificationAnalyticsServiceProvider);
  return PushNotificationService(
    repository: repo,
    localService: localService,
    analytics: analytics,
    onNavigate: ({required entityType, entityId}) {
      ref.read(pendingNotificationTapProvider.notifier).state = (
        entityType: entityType,
        entityId: entityId,
      );
    },
  );
});

final notificationPreferencesProvider =
    FutureProvider.family<NotificationPreferences?, String>((ref, userId) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getPreferences(userId);
});

final updateNotificationPreferencesProvider =
    FutureProvider.family<void, ({String userId, NotificationPreferences prefs})>(
  (ref, params) async {
    final repo = ref.watch(notificationRepositoryProvider);
    await repo.setPreferences(params.userId, params.prefs);
    ref.invalidate(notificationPreferencesProvider(params.userId));
  },
);

final pushNotificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(pushNotificationServiceProvider);
  final userId = ref.watch(userIdProvider);
  await service.initialize(userId: userId);
});
