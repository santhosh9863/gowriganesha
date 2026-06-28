import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/models/notification_type.dart';
import 'package:ganesha_2026/core/services/notification_messages.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';

class NotificationFactory {
  NotificationFactory._();

  static AppNotification expenseRecorded({
    required String notificationId,
    required int amount,
    required String note,
    required String expenseId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.expenseRecordedTitle,
      body: NotificationMessages.expenseRecordedBody
          .replaceAll('{amount}', fmtAmount(amount))
          .replaceAll('{note}', note),
      type: NotificationType.expenseRecorded,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'expense',
      entityId: expenseId,
      actionRoute: '/expenses/$expenseId',
    );
  }

  static AppNotification largeExpenseWarning({
    required String notificationId,
    required int amount,
    required String note,
    required String expenseId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.largeExpenseTitle,
      body: NotificationMessages.largeExpenseBody
          .replaceAll('{amount}', fmtAmount(amount)),
      type: NotificationType.largeExpenseWarning,
      priority: NotificationPriority.high,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'expense',
      entityId: expenseId,
      actionRoute: '/expenses/$expenseId',
    );
  }

  static AppNotification collectionRecorded({
    required String notificationId,
    required int amount,
    required String sponsorName,
    required String sponsorId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.collectionRecordedTitle,
      body: NotificationMessages.collectionRecordedBody
          .replaceAll('{amount}', fmtAmount(amount))
          .replaceAll('{sponsor}', sponsorName),
      type: NotificationType.collectionCompleted,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'target',
      entityId: sponsorId,
      actionRoute: '/collections/$sponsorId',
    );
  }

  static AppNotification dailyCollectionRecorded({
    required String notificationId,
    required int amount,
    required String dateLabel,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.dailyCollectionRecordedTitle,
      body: NotificationMessages.dailyCollectionRecordedBody
          .replaceAll('{amount}', fmtAmount(amount))
          .replaceAll('{date}', dateLabel),
      type: NotificationType.dailyCollectionRecorded,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'daily_collection',
      actionRoute: '/daily-collections',
    );
  }

  static AppNotification followUpAdded({
    required String notificationId,
    required String sponsorName,
    required String dateLabel,
    required String followUpId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.followUpAddedTitle,
      body: NotificationMessages.followUpAddedBody
          .replaceAll('{sponsor}', sponsorName)
          .replaceAll('{date}', dateLabel),
      type: NotificationType.sponsorFollowUpDue,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'followup',
      entityId: followUpId,
      actionRoute: '/followups/$followUpId',
    );
  }

  static AppNotification followUpCompleted({
    required String notificationId,
    required String sponsorName,
    required String followUpId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.followUpCompletedTitle,
      body: NotificationMessages.followUpCompletedBody
          .replaceAll('{sponsor}', sponsorName),
      type: NotificationType.sponsorFollowUpDue,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'followup',
      entityId: followUpId,
      actionRoute: '/followups/$followUpId',
    );
  }

  static AppNotification sponsorAdded({
    required String notificationId,
    required String sponsorName,
    required int amount,
    required String sponsorId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.sponsorAddedTitle,
      body: NotificationMessages.sponsorAddedBody
          .replaceAll('{sponsor}', sponsorName)
          .replaceAll('{amount}', fmtAmount(amount)),
      type: NotificationType.collectionCompleted,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'target',
      entityId: sponsorId,
      actionRoute: '/collections/$sponsorId',
    );
  }

  static AppNotification settingsUpdated({
    required String notificationId,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.settingsUpdatedTitle,
      body: NotificationMessages.settingsUpdatedBody,
      type: NotificationType.settingsUpdated,
      priority: NotificationPriority.low,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      entityType: 'settings',
      actionRoute: '/settings',
    );
  }

  static AppNotification festivalCountdown({
    required String notificationId,
    required int daysRemaining,
    required String festivalName,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.festivalCountdownTitle,
      body: NotificationMessages.festivalCountdownBody
          .replaceAll('{days}', daysRemaining.toString())
          .replaceAll('{festival}', festivalName),
      type: NotificationType.festivalCountdownMilestone,
      priority: NotificationPriority.low,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
    );
  }

  static AppNotification newVolunteerLogin({
    required String notificationId,
    required String volunteerName,
    required String senderUserId,
    required String senderUserName,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.newVolunteerTitle,
      body: NotificationMessages.newVolunteerBody
          .replaceAll('{name}', volunteerName),
      type: NotificationType.newVolunteerLogin,
      priority: NotificationPriority.low,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
    );
  }

  static AppNotification announcement({
    required String notificationId,
    required String body,
    required String senderUserId,
    required String senderUserName,
    String? actionRoute,
  }) {
    return AppNotification(
      id: notificationId,
      title: NotificationMessages.announcementTitle,
      body: body,
      type: NotificationType.generalAnnouncement,
      priority: NotificationPriority.normal,
      senderUserId: senderUserId,
      senderUserName: senderUserName,
      createdAt: Timestamp.now(),
      actionRoute: actionRoute,
    );
  }
}
