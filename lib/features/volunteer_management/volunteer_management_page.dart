import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/user.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/user_provider.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_metric_card.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/app_status_chip.dart';

class VolunteerManagementPage extends ConsumerStatefulWidget {
  const VolunteerManagementPage({super.key});

  @override
  ConsumerState<VolunteerManagementPage> createState() =>
      _VolunteerManagementPageState();
}

class _VolunteerManagementPageState
    extends ConsumerState<VolunteerManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = ref.watch(usersStatsProvider);
    final usersAsync = ref.watch(allUsersStreamProvider);
    final sort = ref.watch(usersSortProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            Expanded(
              child: usersAsync.when(
                data: (_) => _buildBody(theme, stats, sort),
                loading: () => const AppSkeletonList(itemCount: 5),
                error: (e, _) => AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  iconColor: AppColors.error,
                  title: 'Failed to load volunteers',
                  subtitle: e.toString(),
                  action: TextButton(
                    onPressed: () => ref.invalidate(allUsersStreamProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.card,
                side: BorderSide(color: AppColors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              iconSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              'Volunteer Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, UsersStats stats, UsersSort sort) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildMetricGrid(stats)),
        SliverToBoxAdapter(child: _buildControls(theme, sort)),
        _buildUserList(theme),
      ],
    );
  }

  Widget _buildMetricGrid(UsersStats stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          SizedBox(
            width: _cardWidth(),
            child: AppMetricCard(
              label: 'Total Volunteers',
              value: stats.total.toString(),
              icon: Icons.people_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryBg,
            ),
          ),
          SizedBox(
            width: _cardWidth(),
            child: AppMetricCard(
              label: 'Online Now',
              value: stats.online.toString(),
              icon: Icons.wifi_rounded,
              iconColor: AppColors.success,
              iconBgColor: AppColors.successBg,
            ),
          ),
          SizedBox(
            width: _cardWidth(),
            child: AppMetricCard(
              label: 'Joined Today',
              value: stats.joinedToday.toString(),
              icon: Icons.today_rounded,
              iconColor: AppColors.info,
              iconBgColor: AppColors.infoBg,
            ),
          ),
          SizedBox(
            width: _cardWidth(),
            child: AppMetricCard(
              label: 'Volunteers',
              value: stats.volunteers.toString(),
              icon: Icons.person_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryBg,
            ),
          ),
          SizedBox(
            width: _cardWidth(),
            child: AppMetricCard(
              label: 'Admins',
              value: stats.admins.toString(),
              icon: Icons.shield_rounded,
              iconColor: AppColors.accent,
              iconBgColor: AppColors.accentBg,
            ),
          ),
        ],
      ),
    );
  }

  double _cardWidth() {
    final w = MediaQuery.of(context).size.width;
    final horizontalPad = w > 900 ? AppSpacing.xxxl : AppSpacing.lg;
    final available = w - horizontalPad * 2 - AppSpacing.sm;
    return (available / 2).floorToDouble();
  }

  Widget _buildControls(ThemeData theme, UsersSort sort) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(usersSearchProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search volunteers...',
              hintStyle: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.warmGray400,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.warmGray400,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(usersSearchProvider.notifier).state = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildSortButton(theme, sort),
              const Spacer(),
              Text(
                '${ref.watch(filteredSortedUsersProvider).length} users',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.warmGray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(ThemeData theme, UsersSort currentSort) {
    final labels = {
      UsersSort.newest: 'Newest',
      UsersSort.oldest: 'Oldest',
      UsersSort.nameAZ: 'Name A-Z',
      UsersSort.onlineFirst: 'Online First',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: () => _showSortMenu(labels, currentSort),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 16,
              color: AppColors.warmGray600,
            ),
            const SizedBox(width: 4),
            Text(
              labels[currentSort] ?? 'Newest',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.warmGray600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: AppColors.warmGray400,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(
      Map<UsersSort, String> labels, UsersSort currentSort) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warmGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Sort by',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: AppColors.charcoal,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...labels.entries.map((entry) {
                final isSelected = entry.key == currentSort;
                return ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected ? AppColors.primary : AppColors.warmGray400,
                    size: 20,
                  ),
                  title: Text(
                    entry.value,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: AppColors.charcoal,
                        ),
                  ),
                  onTap: () {
                    ref.read(usersSortProvider.notifier).state = entry.key;
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(ThemeData theme) {
    final users = ref.watch(filteredSortedUsersProvider);

    if (users.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyState(
          icon: Icons.group_off_rounded,
          title: 'No volunteers found',
          subtitle: _searchController.text.isNotEmpty
              ? 'Try a different search term'
              : 'No volunteers have registered yet',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final user = users[index];
          return _UserCard(user: user);
        },
        childCount: users.length,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = user.isOnline;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppShadows.subtle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.success : AppColors.warmGray300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _deviceIcon(),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildRoleChip(),
                  const Spacer(),
                  if (user.loginCount > 1)
                    Text(
                      '${user.loginCount} logins',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppColors.warmGray400),
                  const SizedBox(width: 4),
                  Text(
                    'Registered',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.warmGray400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(user.registeredAt.toDate()),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: AppColors.warmGray400),
                  const SizedBox(width: 4),
                  Text(
                    'Last Active',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.warmGray400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeTime(user.lastActive.toDate()),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.warmGray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceIcon() {
    final icon = switch (user.device) {
      'android' => Icons.android_rounded,
      'ios' => Icons.phone_iphone_rounded,
      'windows' => Icons.laptop_windows_rounded,
      'macos' => Icons.laptop_mac_rounded,
      'web' => Icons.language_rounded,
      'linux' => Icons.terminal_rounded,
      _ => Icons.device_unknown_rounded,
    };
    return Icon(icon, size: 16, color: AppColors.warmGray400);
  }

  Widget _buildRoleChip() {
    final isAdmin = user.role == UserRole.admin;
    return AppStatusChip(
      label: isAdmin ? 'Admin' : 'Volunteer',
      variant: isAdmin ? AppChipVariant.accent : AppChipVariant.info,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • h:mm a').format(date);
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24 && date.day == now.day) {
      return 'Today • ${DateFormat('h:mm a').format(date)}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Yesterday • ${DateFormat('h:mm a').format(date)}';
    }
    if (date.year == now.year) {
      return DateFormat('dd MMM • h:mm a').format(date);
    }
    return DateFormat('dd MMM yyyy • h:mm a').format(date);
  }
}
