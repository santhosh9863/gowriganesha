import 'package:flutter/foundation.dart';

abstract class NotificationPermissionService {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<void> openSettings();
}

class NotificationPermissionServiceStub
    implements NotificationPermissionService {
  @override
  Future<bool> hasPermission() async {
    debugPrint('[NOTIFICATION_PERM] Stub: hasPermission → true');
    return true;
  }

  @override
  Future<bool> requestPermission() async {
    debugPrint('[NOTIFICATION_PERM] Stub: requestPermission → true');
    return true;
  }

  @override
  Future<void> openSettings() async {
    debugPrint('[NOTIFICATION_PERM] Stub: openSettings (no-op)');
  }
}
