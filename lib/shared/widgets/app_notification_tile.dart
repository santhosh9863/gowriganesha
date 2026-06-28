import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
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

  const AppNotificationTile({
    super.key,
    required this.notification,
    required this.currentUserId,
    this.onTap,
    this.onMarkAsRead,
  });

  bool get _isUnread => notification.isUnreadBy(currentUserId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _categoryConfig[notification.category] ?? _categoryConfig[NotificationCategory.system]!;

    final tile = InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumBorder,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.mediumBorder,
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: AppSpacing.lg + 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.mediumBorder,
              ),
              child: Icon(config.icon, size: 18, color: config.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.charcoal,
                            fontWeight:
                                _isUnread ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.warmGray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warmGray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!_isUnread || onMarkAsRead == null) return tile;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        onMarkAsRead?.call();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: AppRadius.mediumBorder,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.xl),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
      ),
      child: tile,
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
    return DateFormat('d MMM').format(dt);
  }
}
