import 'package:flutter/foundation.dart';

abstract class LocalNotificationService {
  Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  });

  Future<void> cancel(String id);

  Future<void> cancelAll();
}

class LocalNotificationServiceStub implements LocalNotificationService {
  @override
  Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) {
    debugPrint('[LOCAL_NOTIF] Stub: schedule "$title" at $scheduledAt');
    throw UnimplementedError(
      'LocalNotificationService is not yet implemented. '
      'Install flutter_local_notifications and provide a concrete implementation.',
    );
  }

  @override
  Future<void> cancel(String id) {
    debugPrint('[LOCAL_NOTIF] Stub: cancel $id');
    throw UnimplementedError(
      'LocalNotificationService is not yet implemented.',
    );
  }

  @override
  Future<void> cancelAll() {
    debugPrint('[LOCAL_NOTIF] Stub: cancelAll');
    throw UnimplementedError(
      'LocalNotificationService is not yet implemented.',
    );
  }
}
