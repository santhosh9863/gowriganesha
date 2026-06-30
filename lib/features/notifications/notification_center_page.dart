import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/app_notification.dart';
import 'package:ganesha_2026/core/models/notification_type.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/shared/widgets/app_notification_tile.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState
    extends ConsumerState<NotificationCenterPage> {
  bool _loadingAction = false;
  NotificationCategory? _categoryFilter;
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final userId = ref.watch(userIdProvider);
    final role = ref.watch(roleProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.card,
            side: BorderSide(color: AppColors.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          iconSize: 18,
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          if (notificationsAsync.hasValue && unreadCount > 0 && !_loadingAction)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'Mark all as read',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_loadingAction)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.97, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        child: notificationsAsync.when(
          loading: () => _buildShimmerList(),
          error: (e, _) => _buildErrorState(e),
          data: (notifications) {
            final filtered = _applyFilters(notifications, role);
            if (filtered.isEmpty) {
              final hasActiveFilter = _categoryFilter != null || _showArchived;
              if (hasActiveFilter) {
                return _buildFilterEmptyState(theme);
              }
              return _buildEmptyState(theme);
            }
            return _buildContent(filtered, userId);
          },
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      key: const ValueKey('loading'),
      itemCount: 6,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                const AppSkeleton(
                  width: 4,
                  height: 76,
                  borderRadius: 20,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                const SizedBox(width: AppSpacing.sm + 8),
                const AppSkeleton(
                  width: 32,
                  height: 32,
                  borderRadius: 16,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: AppSkeleton(
                              height: 12,
                              borderRadius: 4,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const AppSkeleton(
                            width: 36,
                            height: 10,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const AppSkeleton(
                        height: 10,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    debugPrint('[NOTIFICATIONS] Error loading: $error');
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Error loading notifications',
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.warmGray300,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Couldn't load notifications",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please try again.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray400,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              label: 'Retry loading notifications',
              child: FilledButton.tonalIcon(
                onPressed: () => ref.invalidate(notificationsStreamProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterEmptyState(ThemeData theme) {
    return Column(
      key: const ValueKey('filter_empty'),
      children: [
        _buildFilterBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: AppColors.warmGray300,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No notifications match',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.warmGray600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try changing your filters',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warmGray400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(flex: 2),
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primaryBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              "You're all caught up!",
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Text(
                'No notifications yet. We\'ll notify you about collections, expenses, sponsor visits, reminders and important festival updates.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.warmGray500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton.tonal(
              onPressed: () => context.pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBg,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: const Text('Back to Dashboard'),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    List<AppNotification> notifications,
    String userId,
  ) {
    return Column(
      key: const ValueKey('content'),
      children: [
        _buildFilterBar(),
        Expanded(child: _buildGroupedList(notifications, userId)),
      ],
    );
  }

  Widget _buildFilterBar() {
    final categories = NotificationCategory.values;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
      ),
      child: Semantics(
        label: 'Notification filters',
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _categoryFilter == null,
                onTap: () => setState(() => _categoryFilter = null),
              ),
              const SizedBox(width: AppSpacing.sm),
              for (final category in categories) ...[
                _FilterChip(
                  label: category.label,
                  selected: _categoryFilter == category,
                  onTap: () => setState(
                    () => _categoryFilter =
                        _categoryFilter == category ? null : category,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              _FilterChip(
                label: _showArchived ? 'Hide archived' : 'Archived',
                selected: _showArchived,
                icon: Icons.archive_rounded,
                onTap: () => setState(() => _showArchived = !_showArchived),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AppNotification> _applyFilters(
    List<AppNotification> notifications,
    UserRole role,
  ) {
    var filtered = notifications;

    final targetRole =
        role == UserRole.none || role == UserRole.admin ? null : role.name;
    if (targetRole != null) {
      filtered = filtered
          .where((n) => n.targetRole == null || n.targetRole == targetRole)
          .toList();
    }

    if (_categoryFilter != null) {
      filtered =
          filtered.where((n) => n.category == _categoryFilter).toList();
    }

    if (!_showArchived) {
      filtered = filtered.where((n) => n.archivedAt == null).toList();
    }

    return filtered;
  }

  Widget _buildGroupedList(
    List<AppNotification> notifications,
    String userId,
  ) {
    final theme = Theme.of(context);
    final grouped = _groupNotifications(notifications);
    final sectionOrder = ['Today', 'Yesterday', 'This Week', 'Earlier'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        for (final section in sectionOrder)
          if (grouped.containsKey(section)) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                section,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.warmGray400,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final notification in grouped[section]!)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppNotificationTile(
                  notification: notification,
                  currentUserId: userId,
                  onTap: () => _onTapNotification(notification),
                  onMarkAsRead: notification.isUnreadBy(userId)
                      ? () => _markAsRead(notification.id)
                      : null,
                  onArchive: notification.archivedAt == null
                      ? () => _archiveNotification(notification.id)
                      : null,
                ),
              ),
          ],
      ],
    );
  }

  Map<String, List<AppNotification>> _groupNotifications(
    List<AppNotification> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));

    final grouped = <String, List<AppNotification>>{};
    for (final n in notifications) {
      final date = n.createdAt.toDate();
      final day = DateTime(date.year, date.month, date.day);
      final key = switch (day) {
        _ when day == today => 'Today',
        _ when day == yesterday => 'Yesterday',
        _ when day.isAfter(thisWeek) || day == thisWeek => 'This Week',
        _ => 'Earlier',
      };
      grouped.putIfAbsent(key, () => []).add(n);
    }
    return grouped;
  }

  void _onTapNotification(AppNotification notification) {
    final navigator = ref.read(notificationNavigatorProvider);
    final route = navigator.resolveRoute(notification);
    if (route != null) {
      if (notification.isUnreadBy(ref.read(userIdProvider))) {
        _markAsRead(notification.id);
      }
      context.push(route);
    }
  }

  void _markAsRead(String notificationId) {
    final service = ref.read(notificationServiceProvider);
    final userId = ref.read(userIdProvider);
    service.markAsRead(notificationId, userId);
  }

  void _archiveNotification(String notificationId) {
    final service = ref.read(notificationServiceProvider);
    service.archiveNotification(notificationId);
  }

  Future<void> _markAllAsRead() async {
    setState(() => _loadingAction = true);
    try {
      final service = ref.read(notificationServiceProvider);
      final userId = ref.read(userIdProvider);
      final role = ref.read(roleProvider);
      final targetRole =
          role == UserRole.none || role == UserRole.admin ? null : role.name;
      await service.markAllAsRead(userId, targetRole: targetRole);
    } finally {
      if (mounted) setState(() => _loadingAction = false);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.warmGray500,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : AppColors.warmGray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
