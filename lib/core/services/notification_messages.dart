class NotificationMessages {
  NotificationMessages._();

  // Expense
  static const String expenseRecordedTitle = 'Expense Recorded';
  static const String expenseRecordedBody = '₹{amount} — {note}';
  static const String largeExpenseTitle = 'Large Expense Warning';
  static const String largeExpenseBody = '₹{amount} — exceeds threshold';

  // Collection
  static const String collectionRecordedTitle = 'Collection Recorded';
  static const String collectionRecordedBody = '₹{amount} collected from {sponsor}';

  // Daily Collection
  static const String dailyCollectionRecordedTitle = 'Daily Collection Recorded';
  static const String dailyCollectionRecordedBody = '₹{amount} collected on {date}';

  // Follow-up
  static const String followUpAddedTitle = 'Follow-up Scheduled';
  static const String followUpAddedBody = 'Follow-up with {sponsor} on {date}';
  static const String followUpCompletedTitle = 'Follow-up Completed';
  static const String followUpCompletedBody = 'Follow-up with {sponsor} completed';
  static const String followUpDueTitle = 'Follow-up Due';
  static const String followUpDueBody = 'Follow-up with {sponsor} is due today';
  static const String followUpOverdueTitle = 'Follow-up Overdue';
  static const String followUpOverdueBody = 'Follow-up with {sponsor} is overdue';

  // Sponsor
  static const String sponsorAddedTitle = 'Sponsor Added';
  static const String sponsorAddedBody = '{sponsor} — ₹{amount}';

  // Festival
  static const String festivalCountdownTitle = 'Festival Countdown';
  static const String festivalCountdownBody = '{days} days until {festival}';

  // Settings
  static const String settingsUpdatedTitle = 'Settings Updated';
  static const String settingsUpdatedBody = 'Festival settings were changed';

  // System
  static const String newVolunteerTitle = 'New Volunteer Login';
  static const String newVolunteerBody = '{name} logged in as volunteer';
  static const String appUpdateTitle = 'App Update Available';
  static const String appUpdateBody = 'A new version of Sankalpa is available';
  static const String maintenanceTitle = 'Scheduled Maintenance';
  static const String maintenanceBody = '{message}';

  // Announcement
  static const String announcementTitle = 'Announcement';
}
