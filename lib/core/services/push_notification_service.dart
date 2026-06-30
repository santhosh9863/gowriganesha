import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ganesha_2026/core/services/local_notification_service.dart';
import 'package:ganesha_2026/core/services/notification_analytics_service.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';

final FlutterLocalNotificationsPlugin _backgroundPlugin = FlutterLocalNotificationsPlugin();

class PushNotificationService {
  final NotificationRepository _repository;
  final LocalNotificationService _localService;
  final NotificationAnalyticsService? _analytics;
  final FirebaseMessaging _messaging;
  final void Function({required String entityType, String? entityId})? _onNavigate;

  bool _initialized = false;
  String? _currentToken;
  String? _userId;

  PushNotificationService({
    required NotificationRepository repository,
    required LocalNotificationService localService,
    NotificationAnalyticsService? analytics,
    FirebaseMessaging? messaging,
    void Function({required String entityType, String? entityId})? onNavigate,
  })  : _repository = repository,
        _localService = localService,
        _analytics = analytics,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _onNavigate = onNavigate;

  Future<void> initialize({String? userId}) async {
    if (_initialized) return;
    _initialized = true;
    _userId = userId;

    await _localService.initialize();
    await _requestPermissions();

    _currentToken = await _messaging.getToken();
    if (_currentToken != null && _userId != null && _userId!.isNotEmpty) {
      await _repository.saveDeviceToken(
        _currentToken!,
        userId: _userId!,
        platform: _platform,
      );
    }

    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationTap(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> removeCurrentToken() async {
    if (_currentToken != null) {
      await _repository.removeDeviceToken(_currentToken!);
      _currentToken = null;
    }
    _userId = null;
  }

  Future<void> updateUserId(String userId) async {
    if (userId.isEmpty) return;
    _userId = userId;
    if (_currentToken != null) {
      await _repository.saveDeviceToken(
        _currentToken!,
        userId: userId,
        platform: _platform,
      );
    }
  }

  String get _platform {
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'web';
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );
  }

  Future<void> _onTokenRefresh(String newToken) async {
    _currentToken = newToken;
    if (_userId != null && _userId!.isNotEmpty) {
      await _repository.saveDeviceToken(
        newToken,
        userId: _userId!,
        platform: _platform,
      );
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final category = message.data['category'] as String?;
    _analytics?.trackOpened(category: category);
  }

  void _onNotificationTap(RemoteMessage message) {
    final data = message.data;
    final entityType = data['entityType'] as String?;
    final entityId = data['entityId'] as String?;
    final category = data['category'] as String?;
    _analytics?.trackOpened(category: category);
    if (entityType != null && _onNavigate != null) {
      _onNavigate(entityType: entityType, entityId: entityId);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Sankalpa';
    final body = message.notification?.body ?? '';
    final entityType = message.data['entityType'] as String?;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _backgroundPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final channel = LocalNotificationService.channelFor(entityType);
    await _backgroundPlugin.show(
      message.messageId?.hashCode ?? 0,
      title,
      body,
      NotificationDetails(
        android: LocalNotificationService.detailsFor(channel),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.messageId,
    );
  }
}
