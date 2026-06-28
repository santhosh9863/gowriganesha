import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';
import 'package:ganesha_2026/core/services/notification_factory.dart';
import 'package:ganesha_2026/core/services/notification_repository.dart';
import 'package:ganesha_2026/core/services/notification_service.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';

class ActivityService {
  final FirestoreService _firestore;
  final NotificationService _notificationService;
  final NotificationRepository _notificationRepository;

  ActivityService({
    required FirestoreService firestore,
    required NotificationService notificationService,
    required NotificationRepository notificationRepository,
  })  : _firestore = firestore,
        _notificationService = notificationService,
        _notificationRepository = notificationRepository;

  Future<void> recordExpenseAdded(
    Expense expense, {
    required String userId,
    required String userName,
  }) async {
    final activityId = _firestore.generateId();
    await _firestore.addActivity(Activity(
      id: activityId,
      festivalId: AppConstants.festivalId,
      type: 'expense_added',
      title: 'Expense Recorded',
      description:
          '${AppConstants.currencySymbol}${fmtAmount(expense.amount)} — ${expense.note}',
      createdAt: Timestamp.now(),
      recordId: expense.id,
      entityType: 'expense',
    ));

    final threshold = 50000;
    if (expense.amount > threshold) {
      final notification = NotificationFactory.largeExpenseWarning(
        notificationId: _notificationRepository.createNotificationId(),
        amount: expense.amount,
        note: expense.note,
        expenseId: expense.id,
        senderUserId: userId,
        senderUserName: userName,
      );
      await _notificationService.createNotification(notification);
    } else {
      final notification = NotificationFactory.expenseRecorded(
        notificationId: _notificationRepository.createNotificationId(),
        amount: expense.amount,
        note: expense.note,
        expenseId: expense.id,
        senderUserId: userId,
        senderUserName: userName,
      );
      await _notificationService.createNotification(notification);
    }
  }

  Future<void> recordContributionRecorded(
    Target target,
    int amount, {
    required String userId,
    required String userName,
  }) async {
    final activityId = _firestore.generateId();
    await _firestore.addActivity(Activity(
      id: activityId,
      festivalId: AppConstants.festivalId,
      type: 'collection_recorded',
      title: 'Collection Recorded',
      description:
          '${AppConstants.currencySymbol}${fmtAmount(amount)} from ${target.name}',
      createdAt: Timestamp.now(),
      recordId: target.id,
      entityType: 'target',
    ));

    final notification = NotificationFactory.collectionRecorded(
      notificationId: _notificationRepository.createNotificationId(),
      amount: amount,
      sponsorName: target.name,
      sponsorId: target.id,
      senderUserId: userId,
      senderUserName: userName,
    );
    await _notificationService.createNotification(notification);
  }

  Future<void> recordDailyCollectionRecorded(
    DailyCollection dc, {
    required String userId,
    required String userName,
  }) async {
    final activityId = _firestore.generateId();
    await _firestore.addActivity(Activity(
      id: activityId,
      festivalId: AppConstants.festivalId,
      type: 'collection_recorded',
      title: 'Daily Collection Recorded',
      description:
          '${AppConstants.currencySymbol}${fmtAmount(dc.amount)} on ${_formatDate(dc.date.toDate())}',
      createdAt: Timestamp.now(),
      entityType: 'daily_collection',
    ));

    final notification = NotificationFactory.dailyCollectionRecorded(
      notificationId: _notificationRepository.createNotificationId(),
      amount: dc.amount,
      dateLabel: _formatDate(dc.date.toDate()),
      senderUserId: userId,
      senderUserName: userName,
    );
    await _notificationService.createNotification(notification);
  }

  Future<void> recordSponsorAdded(
    Target target, {
    required String userId,
    required String userName,
  }) async {
    final activityId = _firestore.generateId();
    await _firestore.addActivity(Activity(
      id: activityId,
      festivalId: AppConstants.festivalId,
      type: 'sponsor_added',
      title: 'Sponsor Added',
      description:
          '${target.name} — ${AppConstants.currencySymbol}${fmtAmount(target.expectedAmount)}',
      createdAt: Timestamp.now(),
      recordId: target.id,
      entityType: 'target',
    ));

    final notification = NotificationFactory.sponsorAdded(
      notificationId: _notificationRepository.createNotificationId(),
      sponsorName: target.name,
      amount: target.expectedAmount,
      sponsorId: target.id,
      senderUserId: userId,
      senderUserName: userName,
    );
    await _notificationService.createNotification(notification);
  }

  Future<void> recordFollowUpAdded(
    SponsorFollowup followup, {
    required String userId,
    required String userName,
  }) async {
    final activityId = _firestore.generateId();
    await _firestore.addActivity(Activity(
      id: activityId,
      festivalId: AppConstants.festivalId,
      type: 'followup_added',
      title: 'Follow-up Scheduled',
      description:
          '${followup.sponsorName} on ${_formatDate(followup.followUpDate.toDate())}',
      createdAt: Timestamp.now(),
      recordId: followup.id,
      entityType: 'sponsor_followup',
    ));

    final notification = NotificationFactory.followUpAdded(
      notificationId: _notificationRepository.createNotificationId(),
      sponsorName: followup.sponsorName,
      dateLabel: _formatDate(followup.followUpDate.toDate()),
      followUpId: followup.id,
      senderUserId: userId,
      senderUserName: userName,
    );
    await _notificationService.createNotification(notification);
  }

  Future<void> recordFollowUpCompleted(
    SponsorFollowup followup, {
    required String userId,
    required String userName,
  }) async {
    final activityId = _firestore.generateId();
    await _firestore.addActivity(Activity(
      id: activityId,
      festivalId: AppConstants.festivalId,
      type: 'followup_completed',
      title: 'Follow-up Completed',
      description: followup.sponsorName,
      createdAt: Timestamp.now(),
      recordId: followup.id,
      entityType: 'sponsor_followup',
    ));

    final notification = NotificationFactory.followUpCompleted(
      notificationId: _notificationRepository.createNotificationId(),
      sponsorName: followup.sponsorName,
      followUpId: followup.id,
      senderUserId: userId,
      senderUserName: userName,
    );
    await _notificationService.createNotification(notification);
  }

  Future<void> recordSettingsUpdated({
    required String userId,
    required String userName,
  }) async {
    await _firestore.addActivity(Activity(
      id: _firestore.generateId(),
      festivalId: AppConstants.festivalId,
      type: 'festival_updated',
      title: 'Settings Updated',
      description: 'Festival settings were changed',
      createdAt: Timestamp.now(),
      entityType: 'settings',
    ));

    final notification = NotificationFactory.settingsUpdated(
      notificationId: _notificationRepository.createNotificationId(),
      senderUserId: userId,
      senderUserName: userName,
    );
    await _notificationService.createNotification(notification);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }
}
