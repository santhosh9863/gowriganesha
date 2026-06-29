import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/notification_type.dart';

class AppNotification {
  final String id;
  final String? festivalId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final int schemaVersion;
  final String senderUserId;
  final String senderUserName;
  final Timestamp createdAt;
  final Timestamp? lastUpdatedAt;
  final Timestamp? scheduledAt;
  final Timestamp? archivedAt;
  final Map<String, Timestamp> readBy;
  final bool isPinned;
  final String? actionRoute;
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic>? actionArguments;
  final Map<String, dynamic>? metadata;
  final String? targetRole;
  final String? dedupKey;

  NotificationCategory get category => type.category;

  const AppNotification({
    required this.id,
    this.festivalId,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.schemaVersion = 1,
    required this.senderUserId,
    required this.senderUserName,
    required this.createdAt,
    this.lastUpdatedAt,
    this.scheduledAt,
    this.archivedAt,
    this.readBy = const {},
    this.isPinned = false,
    this.actionRoute,
    this.entityType,
    this.entityId,
    this.actionArguments,
    this.metadata,
    this.targetRole,
    this.dedupKey,
  });

  NotificationStatus statusFor(String userId) {
    if (archivedAt != null && !isPinned) return NotificationStatus.archived;
    if (readBy.containsKey(userId)) return NotificationStatus.read;
    return NotificationStatus.unread;
  }

  bool isUnreadBy(String userId) => statusFor(userId) == NotificationStatus.unread;

  bool get isValid => title.isNotEmpty && body.isNotEmpty && senderUserId.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'schemaVersion': schemaVersion,
      if (festivalId != null) 'festivalId': festivalId,
      'title': title,
      'body': body,
      'type': type.value,
      'category': category.value,
      'priority': priority.value,
      'senderUserId': senderUserId,
      'senderUserName': senderUserName,
      'createdAt': createdAt,
      if (lastUpdatedAt != null) 'lastUpdatedAt': lastUpdatedAt,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
      if (archivedAt != null) 'archivedAt': archivedAt,
      'readBy': readBy.map((k, v) => MapEntry(k, v)),
      'isPinned': isPinned,
      if (actionRoute != null) 'actionRoute': actionRoute,
      if (entityType != null) 'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
      if (actionArguments != null) 'actionArguments': actionArguments,
      if (metadata != null) 'metadata': metadata,
      if (targetRole != null) 'targetRole': targetRole,
      if (dedupKey != null) 'dedupKey': dedupKey,
    };
  }

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final readBy = _readReadByMap(map['readBy']);
    final legacyReadAt = map['readAt'] as Timestamp?;

    if (legacyReadAt != null && readBy.isEmpty) {
      readBy['_legacy_'] = legacyReadAt;
    }

    return AppNotification(
      id: id,
      festivalId: map['festivalId'] as String?,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromName(map['type'] as String? ?? ''),
      priority: NotificationPriority.fromName(map['priority'] as String? ?? 'normal'),
      schemaVersion: map['schemaVersion'] as int? ?? 1,
      senderUserId: map['senderUserId'] as String? ?? '',
      senderUserName: map['senderUserName'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
      lastUpdatedAt: map['lastUpdatedAt'] as Timestamp?,
      scheduledAt: map['scheduledAt'] as Timestamp?,
      archivedAt: map['archivedAt'] as Timestamp?,
      readBy: readBy,
      isPinned: map['isPinned'] as bool? ?? false,
      actionRoute: map['actionRoute'] as String?,
      entityType: map['entityType'] as String?,
      entityId: map['entityId'] as String?,
      actionArguments: map['actionArguments'] as Map<String, dynamic>?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      targetRole: map['targetRole'] as String?,
      dedupKey: map['dedupKey'] as String?,
    );
  }

  static Map<String, Timestamp> _readReadByMap(dynamic value) {
    if (value is! Map) return {};
    return value.map((k, v) => MapEntry(
      k.toString(),
      v is Timestamp ? v : Timestamp.now(),
    ));
  }

  AppNotification copyWith({
    String? id,
    String? festivalId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    int? schemaVersion,
    String? senderUserId,
    String? senderUserName,
    Timestamp? createdAt,
    Timestamp? lastUpdatedAt,
    Timestamp? scheduledAt,
    Timestamp? archivedAt,
    Map<String, Timestamp>? readBy,
    bool? isPinned,
    String? actionRoute,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? actionArguments,
    Map<String, dynamic>? metadata,
    String? targetRole,
    String? dedupKey,
    bool clearFestivalId = false,
    bool clearLastUpdatedAt = false,
    bool clearScheduledAt = false,
    bool clearArchivedAt = false,
    bool clearReadBy = false,
    bool clearActionRoute = false,
    bool clearEntityType = false,
    bool clearEntityId = false,
    bool clearActionArguments = false,
    bool clearMetadata = false,
    bool clearTargetRole = false,
  }) {
    return AppNotification(
      id: id ?? this.id,
      festivalId: clearFestivalId ? null : (festivalId ?? this.festivalId),
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      senderUserId: senderUserId ?? this.senderUserId,
      senderUserName: senderUserName ?? this.senderUserName,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: clearLastUpdatedAt ? null : (lastUpdatedAt ?? this.lastUpdatedAt),
      scheduledAt: clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      readBy: clearReadBy ? {} : (readBy ?? this.readBy),
      isPinned: isPinned ?? this.isPinned,
      actionRoute: clearActionRoute ? null : (actionRoute ?? this.actionRoute),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      entityId: clearEntityId ? null : (entityId ?? this.entityId),
      actionArguments:
          clearActionArguments ? null : (actionArguments ?? this.actionArguments),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      targetRole: clearTargetRole ? null : (targetRole ?? this.targetRole),
      dedupKey: dedupKey ?? this.dedupKey,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.priority == priority &&
        other.senderUserId == senderUserId &&
        other.createdAt == createdAt &&
        other.isPinned == isPinned &&
        other.archivedAt == archivedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        body,
        type,
        priority,
        senderUserId,
        createdAt,
        isPinned,
        archivedAt,
      );
}
