import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';

class AppGreetingSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userName = ref.watch(userNameProvider);
    final displayGreeting = greeting ?? _greetingWithName(userName);
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

  String _greetingWithName(String userName) {
    final h = DateTime.now().hour;
    String base;
    if (h < 12) {
      base = 'Good morning';
    } else if (h < 17) {
      base = 'Good afternoon';
    } else {
      base = 'Good evening';
    }
    if (userName.isNotEmpty) {
      final capitalized = userName[0].toUpperCase() + userName.substring(1);
      return '$base, $capitalized';
    }
    return '$base,';
  }

  static String _todayDate() => DateFormat('d MMMM yyyy').format(DateTime.now());
}
