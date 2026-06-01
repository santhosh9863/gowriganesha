import 'package:intl/intl.dart';

enum FestivalCountdownStatus {
  planningSeason,
  buildingMomentum,
  preparationUnderway,
  approaching,
  finalWeek,
  almostTime,
  tomorrow,
  festivalDay,
  completed,
}

class FestivalCountdownResult {
  final int daysRemaining;
  final String title;
  final String message;
  final FestivalCountdownStatus status;
  final String formattedDate;
  final bool isPast;

  const FestivalCountdownResult({
    required this.daysRemaining,
    required this.title,
    required this.message,
    required this.status,
    required this.formattedDate,
    required this.isPast,
  });
}

class FestivalCountdownService {
  FestivalCountdownResult compute(DateTime festivalDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final festivalDay = DateTime(festivalDate.year, festivalDate.month, festivalDate.day);
    final diff = festivalDay.difference(today).inDays;
    final daysRemaining = diff < 0 ? 0 : diff;
    final isPast = diff < 0;
    final formattedDate = DateFormat('d MMMM yyyy').format(festivalDate);

    String title;
    String message;
    FestivalCountdownStatus status;

    if (isPast) {
      title = 'Festival Completed';
      message = 'Thank you for making it happen.';
      status = FestivalCountdownStatus.completed;
    } else if (daysRemaining == 0) {
      title = 'Festival Day';
      message = 'The celebration begins today.';
      status = FestivalCountdownStatus.festivalDay;
    } else if (daysRemaining == 1) {
      title = '1 Day Left';
      message = 'Tomorrow is the big day.';
      status = FestivalCountdownStatus.tomorrow;
    } else if (daysRemaining <= 6) {
      title = '$daysRemaining Days Left';
      message = 'Final preparations are underway.';
      status = FestivalCountdownStatus.almostTime;
    } else if (daysRemaining <= 13) {
      title = '$daysRemaining Days Left';
      message = 'Every visit matters now.';
      status = FestivalCountdownStatus.finalWeek;
    } else if (daysRemaining <= 29) {
      title = '$daysRemaining Days Left';
      message = 'Festival season is approaching.';
      status = FestivalCountdownStatus.approaching;
    } else if (daysRemaining <= 59) {
      title = '$daysRemaining Days Left';
      message = 'Building something meaningful.';
      status = FestivalCountdownStatus.preparationUnderway;
    } else if (daysRemaining <= 89) {
      title = '$daysRemaining Days Left';
      message = 'Building momentum.';
      status = FestivalCountdownStatus.buildingMomentum;
    } else {
      title = '$daysRemaining Days Left';
      message = 'The journey begins now.';
      status = FestivalCountdownStatus.planningSeason;
    }

    return FestivalCountdownResult(
      daysRemaining: daysRemaining,
      title: title,
      message: message,
      status: status,
      formattedDate: formattedDate,
      isPast: isPast,
    );
  }
}
