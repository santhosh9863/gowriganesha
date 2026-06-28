import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';

class AppBellIcon extends ConsumerStatefulWidget {
  const AppBellIcon({super.key});

  @override
  ConsumerState<AppBellIcon> createState() => _AppBellIconState();
}

class _AppBellIconState extends ConsumerState<AppBellIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation(int unreadCount) {
    if (unreadCount > 0 && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (unreadCount == 0 && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateAnimation(unreadCount);
    });

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outline),
      ),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: unreadCount > 0 ? _scaleAnim.value : 1.0,
          child: child,
        ),
        child: IconButton(
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            smallSize: 18,
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            child: Icon(
              unreadCount > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_outlined,
              size: 22,
              color: unreadCount > 0
                  ? AppColors.primary
                  : AppColors.warmGray500,
            ),
          ),
          onPressed: () => context.push('/notifications'),
          padding: EdgeInsets.zero,
          tooltip: unreadCount > 0
              ? '$unreadCount unread'
              : 'No notifications',
          splashRadius: 24,
        ),
      ),
    );
  }
}
