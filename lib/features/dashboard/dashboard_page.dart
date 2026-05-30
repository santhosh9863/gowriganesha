import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/providers/dashboard_provider.dart';
import 'package:ganesha_2026/core/providers/activity_provider.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/shared/widgets/app_card.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _heroFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(int n) {
    return NumberFormat('#,##,###', 'en_IN').format(n);
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = dashboard.progressPercent / 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          ref.invalidate(activitiesStreamProvider);
          ref.invalidate(activeFollowUpsProvider);
        },
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(
                  fade: _heroFade,
                  controller: _ctrl,
                  target: dashboard.expectedTotal,
                  collected: dashboard.collectedTotal,
                  progress: progress,
                  theme: theme,
                  colorScheme: colorScheme,
                  fmt: _fmt,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _PendingVisits(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: AppSpacing.lg),
                _PendingSponsors(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: AppSpacing.lg),
                _TodayCollection(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: AppSpacing.lg),
                _BalanceSection(
                  controller: _ctrl,
                  balance: dashboard.balance,
                  expenses: dashboard.totalExpenses,
                  theme: theme,
                  colorScheme: colorScheme,
                  fmt: _fmt,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _RecentActivity(theme: theme, colorScheme: colorScheme),
              ],
            ),
          ),
        ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Animation<double> fade;
  final Animation<double> controller;
  final int target;
  final int collected;
  final double progress;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _HeroSection({
    required this.fade,
    required this.controller,
    required this.target,
    required this.collected,
    required this.progress,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            final displayTarget = (target * t).round();
            final displayCollected = (collected * t).round();
            final displayProgress = progress * t;

            return Column(
              children: [
                Text(
                  'Expected Sponsorship',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${AppConstants.currencySymbol}${fmt(displayTarget)}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'festival goal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(100),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 20,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Collected',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(displayProgress * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${AppConstants.currencySymbol}${fmt(displayCollected)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: AppRadius.cardBorder,
                  child: LinearProgressIndicator(
                    value: displayProgress,
                    minHeight: 10,
                    backgroundColor: colorScheme.primaryContainer.withAlpha(80),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  final Animation<double> controller;
  final int balance;
  final int expenses;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _BalanceSection({
    required this.controller,
    required this.balance,
    required this.expenses,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'Balance',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final displayBalance = (balance * controller.value).round();
              final displayExpenses = (expenses * controller.value).round();
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: displayBalance >= 0
                                    ? colorScheme.tertiary.withAlpha(30)
                                    : colorScheme.error.withAlpha(30),
                                borderRadius: AppRadius.cardBorder,
                              ),
                              child: Icon(
                                Icons.balance_rounded,
                                size: 20,
                                color: displayBalance >= 0
                                    ? colorScheme.tertiary
                                    : colorScheme.error,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Current Balance',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${AppConstants.currencySymbol}${fmt(displayBalance)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: displayBalance >= 0
                                ? colorScheme.tertiary
                                : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expenses',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${AppConstants.currencySymbol}${fmt(displayExpenses)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PendingSponsors extends ConsumerWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _PendingSponsors({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      onTap: () => context.push('/collections?filter=pending'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Pending Sponsors',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurface.withAlpha(80),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${dashboard.pendingSponsorCount} Sponsors',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '₹${NumberFormat('#,##,###', 'en_IN').format(dashboard.pendingRemainingTotal)} Remaining',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (dashboard.pendingSponsorCount == 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'All sponsorships collected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayCollection extends ConsumerWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _TodayCollection({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      onTap: () => context.push('/daily-collections'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today_rounded,
                size: 20,
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Today's Collection",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurface.withAlpha(80),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${AppConstants.currencySymbol}${NumberFormat('#,##,###', 'en_IN').format(dashboard.todayCollection)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${dashboard.todayEntryCount} Entries Today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingVisits extends ConsumerWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _PendingVisits({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allActive = ref.watch(activeFollowUpsProvider);
    final count = allActive.length;
    final visits = allActive.take(5).toList();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/followups'),
            borderRadius: AppRadius.cardBorder,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Pending Visits ($count)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (count > 0)
                    Text(
                      'View All',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  if (count > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (count == 0)
            AppEmptyState(
              icon: Icons.check_circle_rounded,
              title: 'No pending follow-ups',
              subtitle: 'All sponsor visits are completed.',
            )
          else
            ...visits.map((fu) => _VisitRow(
                  followup: fu,
                  theme: theme,
                  colorScheme: colorScheme,
                )),
        ],
      ),
    );
  }
}

class _VisitRow extends StatelessWidget {
  final SponsorFollowup followup;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _VisitRow({
    required this.followup,
    required this.theme,
    required this.colorScheme,
  });

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Today';
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final diff = date.difference(today).inDays;
    if (diff > 0 && diff <= 7) return dayNames[date.weekday - 1];
    return DateFormat('d MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        followup.followUpDate.toDate().isBefore(DateTime.now());
    return InkWell(
      onTap: () => context.push('/followups/${followup.id}/edit'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOverdue
                    ? colorScheme.errorContainer.withAlpha(80)
                    : colorScheme.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOverdue ? Icons.warning_amber_rounded : Icons.person_rounded,
                size: 20,
                color: isOverdue ? colorScheme.error : colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    followup.sponsorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: isOverdue ? colorScheme.error : colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(followup.followUpDate.toDate()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isOverdue ? colorScheme.error : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (followup.amount != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withAlpha(120),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '₹${NumberFormat('#,##,###', 'en_IN').format(followup.amount)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                  if (followup.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      followup.note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurface.withAlpha(80),
            ),
          ],
        ),
      ),
    );
  }
}

String _activityRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return DateFormat('d MMM').format(dt);
}

IconData _activityIcon(String type) {
  switch (type) {
    case 'collection_recorded':
      return Icons.account_balance_wallet_rounded;
    case 'expense_added':
      return Icons.receipt_long_rounded;
    case 'followup_added':
      return Icons.notifications_rounded;
    case 'followup_completed':
      return Icons.check_circle_rounded;
    default:
      return Icons.circle_rounded;
  }
}

Color _activityColor(String type, ColorScheme cs) {
  switch (type) {
    case 'collection_recorded':
      return const Color(0xFF22C55E);
    case 'expense_added':
      return const Color(0xFFEF4444);
    case 'followup_added':
      return const Color(0xFF3B82F6);
    case 'followup_completed':
      return const Color(0xFF22C55E);
    default:
      return cs.onSurface;
  }
}

class _RecentActivity extends ConsumerWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _RecentActivity({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);
    final items = activitiesAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'Recent Activity',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: items.isEmpty
              ? const EdgeInsets.all(AppSpacing.xxl)
              : const EdgeInsets.all(AppSpacing.lg),
          child: items.isEmpty
              ? AppEmptyState(
                  icon: Icons.inbox_rounded,
                  title: 'No recent activity',
                  subtitle:
                      'Activity will appear here once you start recording',
                )
              : Column(
                  children: items.take(20).map((a) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: _activityColor(a.type, colorScheme)
                                    .withAlpha(30),
                                borderRadius: AppRadius.cardBorder,
                              ),
                              child: Icon(
                                _activityIcon(a.type),
                                size: 18,
                                color: _activityColor(a.type, colorScheme),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    a.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _activityRelativeTime(a.createdAt.toDate()),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ),
        ),
      ],
    );
  }
}
