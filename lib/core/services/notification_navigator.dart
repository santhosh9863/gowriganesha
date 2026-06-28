import 'package:ganesha_2026/core/models/app_notification.dart';

class NotificationNavigator {
  static const Map<String, String> _routeTemplates = {
    'expense': '/expenses/{entityId}',
    'target': '/collections/{entityId}',
    'followup': '/followups/{entityId}',
    'daily_collection': '/daily-collections',
    'settings': '/settings',
  };

  String? resolveRoute(AppNotification notification) {
    if (notification.entityType != null &&
        notification.entityId != null &&
        _routeTemplates.containsKey(notification.entityType)) {
      return _routeTemplates[notification.entityType]!
          .replaceAll('{entityId}', notification.entityId!);
    }
    if (notification.actionRoute != null) {
      return notification.actionRoute;
    }
    return null;
  }

  String? resolveRouteFor({required String entityType, String? entityId}) {
    final template = _routeTemplates[entityType];
    if (template == null) return null;
    if (entityId != null) return template.replaceAll('{entityId}', entityId);
    return template;
  }
}
