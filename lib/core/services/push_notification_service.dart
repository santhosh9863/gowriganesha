import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';

class PushNotificationService {
  final NotificationRepository _repository;
  final FirebaseMessaging _messaging;
  final void Function({required String entityType, String? entityId})? _onNavigate;
  static const _channel = MethodChannel('sankalpa/notifications');

  bool _initialized = false;
  String? _currentToken;
  String? _userId;

  PushNotificationService({
    required NotificationRepository repository,
    FirebaseMessaging? messaging,
    void Function({required String entityType, String? entityId})? onNavigate,
  })  : _repository = repository,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _onNavigate = onNavigate;

  Future<void> initialize({String? userId}) async {
    if (_initialized) return;
    _initialized = true;
    _userId = userId;

    await _createNotificationChannel();
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

    debugPrint('[FCM] Initialized. Token: ${_currentToken?.substring(0, 20)}...');
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

  Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod('createNotificationChannel', {
        'id': 'sankalpa_notifications',
        'name': 'Sankalpa Notifications',
        'description': 'Notifications from the Sankalpa app',
        'importance': 4,
      });
      debugPrint('[FCM] Notification channel created');
    } catch (e) {
      debugPrint('[FCM] Channel creation skipped: $e');
    }
  }
  // MIGRATION NOTE: When flutter_local_notifications is added in a future phase,
  // replace _createNotificationChannel() to use FlutterLocalNotificationsPlugin.
  // No changes to NotificationRepository, NotificationService, or features needed.

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );
    debugPrint('[FCM] Authorization: ${settings.authorizationStatus}');
  }

  Future<void> _onTokenRefresh(String newToken) async {
    _currentToken = newToken;
    debugPrint('[FCM] Token refreshed');
    if (_userId != null && _userId!.isNotEmpty) {
      await _repository.saveDeviceToken(
        newToken,
        userId: _userId!,
        platform: _platform,
      );
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.messageId}');
  }

  void _onNotificationTap(RemoteMessage message) {
    final data = message.data;
    final entityType = data['entityType'] as String?;
    final entityId = data['entityId'] as String?;
    if (entityType != null && _onNavigate != null) {
      _onNavigate(entityType: entityType, entityId: entityId);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    debugPrint('[FCM] Background: ${message.messageId}');
  }
}
