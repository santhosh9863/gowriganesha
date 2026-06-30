enum NotificationPriority {
  low,
  normal,
  high,
  critical;

  String get value => name;

  static NotificationPriority fromName(String name) {
    return NotificationPriority.values.firstWhere(
      (p) => p.name == name,
      orElse: () => NotificationPriority.normal,
    );
  }
}

enum NotificationCategory {
  sponsor,
  collection,
  expense,
  festival,
  system,
  reminder;

  String get value => name;

  String get label {
    return switch (this) {
      NotificationCategory.sponsor => 'Sponsor',
      NotificationCategory.collection => 'Collection',
      NotificationCategory.expense => 'Expense',
      NotificationCategory.festival => 'Festival',
      NotificationCategory.system => 'System',
      NotificationCategory.reminder => 'Reminder',
    };
  }

  static NotificationCategory fromName(String name) {
    return NotificationCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => NotificationCategory.system,
    );
  }
}

enum NotificationType {
  sponsorAdded(NotificationCategory.sponsor),
  sponsorFollowUpDue(NotificationCategory.sponsor),
  sponsorOverdue(NotificationCategory.sponsor),
  collectionCompleted(NotificationCategory.sponsor),
  dailyCollectionReminder(NotificationCategory.reminder),
  dailyCollectionRecorded(NotificationCategory.collection),
  expenseRecorded(NotificationCategory.expense),
  largeExpenseWarning(NotificationCategory.expense),
  festivalStartsSoon(NotificationCategory.festival),
  festivalCountdownMilestone(NotificationCategory.festival),
  newVolunteerLogin(NotificationCategory.system),
  settingsUpdated(NotificationCategory.system),
  appUpdate(NotificationCategory.system),
  maintenance(NotificationCategory.system),
  generalAnnouncement(NotificationCategory.system);

  final NotificationCategory category;
  const NotificationType(this.category);

  String get value => name;

  static NotificationType fromName(String name) {
    return NotificationType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => NotificationType.generalAnnouncement,
    );
  }
}

enum NotificationStatus {
  unread,
  read,
  archived;
}
