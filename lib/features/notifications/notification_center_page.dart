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
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';

class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() =>
      _NotificationCenterPageState();
}

class _NotificationCenterPageState
    extends ConsumerState<NotificationCenterPage>
    with SingleTickerProviderStateMixin {
  bool _loadingAction = false;
  NotificationCategory? _categoryFilter;
  bool _showArchived = false;
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.stop();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final userId = ref.watch(userIdProvider);

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
          if (unreadCount > 0 && !_loadingAction)
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
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: notificationsAsync.when(
          loading: () => const AppSkeletonList(itemCount: 6),
          error: (e, _) => _buildErrorState(),
          data: (notifications) {
            final filtered = _applyFilters(notifications);
            if (filtered.isEmpty) {
              return _buildEmptyState();
            }
            return _buildContent(filtered, userId);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              'Failed to load notifications',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmGray500,
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

  Widget _buildEmptyState() {
    final hasActiveFilter = _categoryFilter != null || _showArchived;
    final message = hasActiveFilter
        ? 'No notifications match your filters'
        : "You're all caught up!";
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: AppEmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications yet',
            subtitle: message,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    List<AppNotification> notifications,
    String userId,
  ) {
    return Column(
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

  List<AppNotification> _applyFilters(List<AppNotification> notifications) {
    var filtered = notifications;

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
