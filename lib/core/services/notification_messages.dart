class NotificationMessages {
  NotificationMessages._();

  // Expense
  static const String expenseRecordedTitle = 'Expense Recorded';
  static const String expenseRecordedBody = '{userName} • {note} • ₹{amount}';
  static const String largeExpenseTitle = 'Large Expense';
  static const String largeExpenseBody = '{userName} spent ₹{amount}';

  // Collection
  static const String collectionRecordedTitle = 'Collection Recorded';
  static const String collectionRecordedBody = '{userName} collected ₹{amount} from {sponsor}';

  // Daily Collection
  static const String dailyCollectionRecordedTitle = 'Daily Collection';
  static const String dailyCollectionRecordedBody = '{userName} recorded ₹{amount} today';

  // Follow-up
  static const String followUpAddedTitle = 'Follow-up Scheduled';
  static const String followUpAddedBody = '{userName} scheduled a visit for {sponsor}';
  static const String followUpCompletedTitle = 'Follow-up Completed';
  static const String followUpCompletedBody = "{userName} completed {sponsor}'s visit";
  static const String followUpDueTitle = 'Follow-up Due';
  static const String followUpDueBody = '{userName} • Follow-up with {sponsor} is due';
  static const String followUpOverdueTitle = 'Follow-up Overdue';
  static const String followUpOverdueBody = '{userName} • {sponsor} follow-up is overdue';

  // Sponsor
  static const String sponsorAddedTitle = 'Sponsor Added';
  static const String sponsorAddedBody = '{userName} • {sponsor} • ₹{amount} commitment';

  // Festival
  static const String festivalCountdownTitle = 'Festival Countdown';
  static const String festivalCountdownBody = '{days} days until {festival}';

  // Settings
  static const String settingsUpdatedTitle = 'Settings Updated';
  static const String settingsUpdatedBody = '{userName} updated festival settings';

  // System
  static const String newVolunteerTitle = 'New Volunteer Joined';
  static const String newVolunteerBody = '{name} joined the festival team.';
  static const String appUpdateTitle = 'App Update Available';
  static const String appUpdateBody = 'A new version of Sankalpa is available';
  static const String maintenanceTitle = 'Scheduled Maintenance';
  static const String maintenanceBody = '{message}';

  // Announcement
  static const String announcementTitle = 'Announcement';
  static const String announcementBody = 'New announcement from {userName}';
}
