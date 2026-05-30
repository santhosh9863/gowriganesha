import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';

class AppGreetingSection extends StatelessWidget {
  final String? greeting;
  final String festivalName;
  final String? date;

  const AppGreetingSection({
    super.key,
    this.greeting,
    this.festivalName = 'Sri Gowri Ganesha Festival',
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayGreeting = greeting ?? _defaultGreeting();
    final displayDate = date ?? _todayDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayGreeting,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.warmGray500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          festivalName,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          displayDate,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.warmGray400,
          ),
        ),
      ],
    );
  }

  static String _defaultGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  static String _todayDate() => DateFormat('d MMMM yyyy').format(DateTime.now());
}
