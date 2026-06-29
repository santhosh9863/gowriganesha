import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

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
}

class SankalpaLocalNotificationService implements LocalNotificationService {
  late final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _plugin = FlutterLocalNotificationsPlugin();

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    );

    await _createChannels();
    _initialized = true;
    debugPrint('[LOCAL_NOTIF] Initialized');
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final channel in _channels) {
      await android.createNotificationChannel(channel);
    }
    debugPrint('[LOCAL_NOTIF] Created ${_channels.length} channels');
  }

  static const List<AndroidNotificationChannel> _channels = [
    AndroidNotificationChannel(
      'critical_alerts', 'Critical Alerts',
      description: 'Large expenses, overdue sponsors',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
      groupId: 'sankalpa_critical',
    ),
    AndroidNotificationChannel(
      'visit_reminders', 'Visit Reminders',
      description: 'Follow-up due and overdue reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      groupId: 'sankalpa_reminder',
    ),
    AndroidNotificationChannel(
      'festival_updates', 'Festival Updates',
      description: 'Countdown milestones and festival alerts',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      groupId: 'sankalpa_festival',
    ),
    AndroidNotificationChannel(
      'collections', 'Collections',
      description: 'Sponsor and daily collection notifications',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      groupId: 'sankalpa_collection',
    ),
    AndroidNotificationChannel(
      'expenses', 'Expenses',
      description: 'Expense recorded alerts',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      groupId: 'sankalpa_expense',
    ),
    AndroidNotificationChannel(
      'announcements', 'Announcements',
      description: 'Admin broadcasts and system alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      groupId: 'sankalpa_announce',
    ),
    AndroidNotificationChannel(
      'background_sync', 'Background Sync',
      description: 'Silent sync operations',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    ),
  ];

  @override
  Future<void> show({
    required String id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    if (!_initialized) await initialize();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId ?? 'announcements',
        'Announcements',
        importance: Importance.defaultImportance,
      ),
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
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId ?? 'announcements',
        'Announcements',
        importance: Importance.defaultImportance,
      ),
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
