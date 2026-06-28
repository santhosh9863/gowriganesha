import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/shared/widgets/sankalpa_glass.dart';

class AppBellIcon extends ConsumerStatefulWidget {
  const AppBellIcon({super.key});

  @override
  ConsumerState<AppBellIcon> createState() => _AppBellIconState();
}

class _AppBellIconState extends ConsumerState<AppBellIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  int _lastUnread = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onUnreadChanged(int unreadCount) {
    if (unreadCount == _lastUnread) return;
    if (unreadCount > 0 && _lastUnread == 0) {
      _pulseCtrl.repeat(reverse: true);
    } else if (unreadCount == 0 && _lastUnread > 0) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 0;
    }
    _lastUnread = unreadCount;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onUnreadChanged(unreadCount);
    });

    return SankalpaGlass(
      sigma: 8,
      opacity: 0.92,
      borderRadius: AppRadius.mediumBorder,
      borderColor: AppColors.outline,
      padding: EdgeInsets.zero,
      tintColor: AppColors.card,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) => Transform.scale(
          scale: unreadCount > 0 ? _pulseAnim.value : 1.0,
          child: child,
        ),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  unreadCount > 0
                      ? Icons.notifications_rounded
                      : Icons.notifications_outlined,
                  size: 22,
                  color: unreadCount > 0
                      ? AppColors.primary
                      : AppColors.warmGray500,
                ),
                onPressed: () => context.push('/notifications'),
                padding: EdgeInsets.zero,
                tooltip: unreadCount > 0
                    ? '$unreadCount unread'
                    : 'No notifications',
                splashRadius: 24,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: SankalpaGlass(
                    sigma: 6,
                    opacity: 0.95,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    tintColor: AppColors.error,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
