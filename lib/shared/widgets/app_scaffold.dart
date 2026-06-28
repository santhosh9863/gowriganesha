import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/models/notification_type.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/shared/widgets/animated_bottom_nav.dart';
import 'package:ganesha_2026/shared/widgets/app_notification_banner.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    ref.listen(notificationsStreamProvider, (previous, next) {
      final prevData = previous?.valueOrNull;
      final nextData = next.valueOrNull;
      if (prevData == null || nextData == null) return;
      if (nextData.length <= prevData.length) return;

      final prevIds = prevData.map((n) => n.id).toSet();
      final newNotifs = nextData.where((n) => !prevIds.contains(n.id)).toList();
      if (newNotifs.isEmpty) return;

      final userId = ref.read(userIdProvider);
      final notif = newNotifs.first;
      final bannerNotifier = ref.read(inAppBannerProvider.notifier);
      final navigator = ref.read(notificationNavigatorProvider);

      bannerNotifier.show(InAppBannerData(
        title: notif.title,
        body: notif.body,
        accentColor: _categoryColor(notif.category),
        icon: _categoryIcon(notif.category),
        onTap: () {
          bannerNotifier.dismiss();
          if (notif.isUnreadBy(userId)) {
            ref.read(notificationServiceProvider).markAsRead(notif.id, userId);
          }
          final route = navigator.resolveRoute(notif);
          if (route != null && context.mounted) {
            context.push(route);
          }
        },
      ));
    });

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppNotificationBanner(),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }

  Color _categoryColor(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.sponsor => AppColors.primary,
      NotificationCategory.collection => AppColors.success,
      NotificationCategory.expense => AppColors.error,
      NotificationCategory.festival => AppColors.accent,
      NotificationCategory.system => AppColors.warmGray500,
      NotificationCategory.reminder => AppColors.warning,
    };
  }

  IconData _categoryIcon(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.sponsor => Icons.handshake_rounded,
      NotificationCategory.collection => Icons.account_balance_wallet_rounded,
      NotificationCategory.expense => Icons.receipt_long_rounded,
      NotificationCategory.festival => Icons.celebration_rounded,
      NotificationCategory.system => Icons.settings_rounded,
      NotificationCategory.reminder => Icons.notifications_active_rounded,
    };
  }
}
