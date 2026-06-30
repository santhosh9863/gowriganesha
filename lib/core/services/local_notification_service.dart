import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

const String _notificationIcon = '@mipmap/ic_launcher';

abstract class LocalNotificationService {
  Future<void> initialize();
  Future<void> show({
    required String id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
  });
  Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    String? channelId,
  });
  Future<void> cancel(String id);
  Future<void> cancelAll();

  static String channelFor(String? entityType) {
    return switch (entityType) {
      'target' => 'collections',
      'daily_collection' => 'collections',
      'followup' => 'visit_reminders',
      'expense' => 'expenses',
      'settings' => 'announcements',
      _ => 'announcements',
    };
  }

  static AndroidNotificationDetails detailsFor(String channelId) {
    return _channelDetails[channelId] ?? _channelDetails['announcements']!;
  }
}

final Map<String, AndroidNotificationDetails> _channelDetails = {
  'critical_alerts': const AndroidNotificationDetails(
    'critical_alerts', 'Critical Alerts',
    channelDescription: 'Large expenses, overdue sponsors',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
    icon: _notificationIcon,
  ),
  'visit_reminders': const AndroidNotificationDetails(
    'visit_reminders', 'Visit Reminders',
    channelDescription: 'Follow-up due and overdue reminders',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
    icon: _notificationIcon,
  ),
  'festival_updates': const AndroidNotificationDetails(
    'festival_updates', 'Festival Updates',
    channelDescription: 'Countdown milestones and festival alerts',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
    icon: _notificationIcon,
  ),
  'collections': const AndroidNotificationDetails(
    'collections', 'Collections',
    channelDescription: 'Sponsor and daily collection notifications',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
    icon: _notificationIcon,
  ),
  'expenses': const AndroidNotificationDetails(
    'expenses', 'Expenses',
    channelDescription: 'Expense recorded alerts',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
    icon: _notificationIcon,
  ),
  'announcements': const AndroidNotificationDetails(
    'announcements', 'Announcements',
    channelDescription: 'Admin broadcasts and system alerts',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
    icon: _notificationIcon,
  ),
  'background_sync': const AndroidNotificationDetails(
    'background_sync', 'Background Sync',
    channelDescription: 'Silent sync operations',
    importance: Importance.low,
    priority: Priority.low,
    playSound: false,
    enableVibration: false,
    channelShowBadge: false,
    icon: _notificationIcon,
  ),
};

class SankalpaLocalNotificationService implements LocalNotificationService {
  late final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _plugin = FlutterLocalNotificationsPlugin();

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(_notificationIcon);
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    _initialized = true;
    debugPrint('[LOCAL_NOTIF] Initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[LOCAL_NOTIF] Tapped: ${response.payload}');
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final entry in _channelDetails.entries) {
      final d = entry.value;
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          d.channelId, d.channelName,
          description: d.channelDescription,
          importance: d.importance ?? Importance.defaultImportance,
          playSound: d.playSound ?? true,
          enableVibration: d.enableVibration ?? true,
          showBadge: d.channelShowBadge ?? true,
        ),
      );
    }
    debugPrint('[LOCAL_NOTIF] Created ${_channelDetails.length} channels');
  }

  @override
  Future<void> show({
    required String id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    if (!_initialized) await initialize();
    final actualChannel = channelId ?? 'announcements';
    final details = NotificationDetails(
      android: LocalNotificationService.detailsFor(actualChannel),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(id.hashCode, title, body, details, payload: payload);
  }

  @override
  Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    String? channelId,
  }) async {
    if (!_initialized) await initialize();
    final actualChannel = channelId ?? 'announcements';
    final details = NotificationDetails(
      android: LocalNotificationService.detailsFor(actualChannel),
      iOS: const DarwinNotificationDetails(),
    );
    final tzScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);
    await _plugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tzScheduledAt,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancel(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
