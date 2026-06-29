import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/models/notification_type.dart';

final _categoryConfig = <NotificationCategory, _CategoryConfig>{
  NotificationCategory.sponsor: const _CategoryConfig(
    Icons.handshake_rounded,
    AppColors.primary,
  ),
  NotificationCategory.collection: const _CategoryConfig(
    Icons.account_balance_wallet_rounded,
    AppColors.success,
  ),
  NotificationCategory.expense: const _CategoryConfig(
    Icons.receipt_long_rounded,
    AppColors.error,
  ),
  NotificationCategory.festival: const _CategoryConfig(
    Icons.celebration_rounded,
    AppColors.accent,
  ),
  NotificationCategory.system: const _CategoryConfig(
    Icons.settings_rounded,
    AppColors.warmGray500,
  ),
  NotificationCategory.reminder: const _CategoryConfig(
    Icons.notifications_active_rounded,
    AppColors.warning,
  ),
};

class _CategoryConfig {
  final IconData icon;
  final Color color;
  const _CategoryConfig(this.icon, this.color);
}

class AppNotificationTile extends StatelessWidget {
  final AppNotification notification;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onArchive;

  const AppNotificationTile({
    super.key,
    required this.notification,
    required this.currentUserId,
    this.onTap,
    this.onMarkAsRead,
    this.onArchive,
  });

  bool get _isUnread => notification.isUnreadBy(currentUserId);
  bool get _hasActions => onMarkAsRead != null || onArchive != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _categoryConfig[notification.category] ??
        _categoryConfig[NotificationCategory.system]!;

    final tile = Semantics(
      label: 'Notification: ${notification.title}',
      hint: _isUnread ? 'Unread notification' : 'Read notification',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outline),
              boxShadow: AppShadows.subtle,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 76,
                  decoration: BoxDecoration(
                    color: config.color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                if (_isUnread)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 30),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: AppSpacing.sm - 2),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(config.icon, size: 16, color: config.color),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.charcoal,
                              fontWeight:
                                  _isUnread ? FontWeight.w600 : FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.warmGray400,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGray600,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ),
      ),
    );

    if (!_hasActions) return tile;

    return Semantics(
      label: 'Swipe right to mark as read, swipe left to archive',
      child: Dismissible(
        key: ValueKey('${notification.id}_dismiss'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onMarkAsRead?.call();
          } else {
            onArchive?.call();
          }
          return false;
        },
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: AppSpacing.xl),
          child: Semantics(
            label: 'Mark as read',
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.warmGray500,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          child: Semantics(
            label: 'Archive',
            child: const Icon(
              Icons.archive_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        child: tile,
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}w';
    return DateFormat('d MMM').format(dt);
  }
}
