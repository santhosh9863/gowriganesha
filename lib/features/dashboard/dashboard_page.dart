import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/providers/dashboard_provider.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          final isDesktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _HeroSection(
                  fade: _heroFade,
                  target: dashboard.expectedTotal,
                  theme: theme,
                  colorScheme: colorScheme,
                  fmt: _fmt,
                ),
                const SizedBox(height: 24),
                _ProgressSection(
                  controller: _ctrl,
                  collected: dashboard.collectedTotal,
                  progress: progress,
                  theme: theme,
                  colorScheme: colorScheme,
                  fmt: _fmt,
                ),
                const SizedBox(height: 24),
                _PrimaryCards(
                  controller: _ctrl,
                  expected: dashboard.expectedTotal,
                  collected: dashboard.collectedTotal,
                  remaining: dashboard.remainingCollection,
                  isWide: isWide,
                  theme: theme,
                  colorScheme: colorScheme,
                  fmt: _fmt,
                ),
                const SizedBox(height: 24),
                _SecondaryCards(
                  controller: _ctrl,
                  expenses: dashboard.totalExpenses,
                  balance: dashboard.balance,
                  efficiency: dashboard.progressPercent,
                  isWide: isWide,
                  isDesktop: isDesktop,
                  theme: theme,
                  colorScheme: colorScheme,
                  fmt: _fmt,
                ),
                const SizedBox(height: 24),
                _PendingSponsors(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: 24),
                _TodayCollection(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: 24),
                _PendingVisits(theme: theme, colorScheme: colorScheme),
                const SizedBox(height: 24),
                _RecentActivity(theme: theme, colorScheme: colorScheme),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Animation<double> fade;
  final int target;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _HeroSection({
    required this.fade,
    required this.target,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Expected Sponsorship',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppConstants.currencySymbol}${fmt(target)}',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: -0.5,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'festival goal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final Animation<double> controller;
  final int collected;
  final double progress;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _ProgressSection({
    required this.controller,
    required this.collected,
    required this.progress,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            final displayCollected = (collected * t).round();
            final displayProgress = progress * t;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 20,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Collected',
                      style: theme.textTheme.titleSmall?.copyWith(
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
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.currencySymbol}${fmt(displayCollected)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
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

class _PrimaryCards extends StatelessWidget {
  final Animation<double> controller;
  final int expected;
  final int collected;
  final int remaining;
  final bool isWide;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _PrimaryCards({
    required this.controller,
    required this.expected,
    required this.collected,
    required this.remaining,
    required this.isWide,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _buildCard('Sponsor', expected, colorScheme.primary, Icons.flag_rounded),
      _buildCard(
          'Collected', collected, colorScheme.tertiary, Icons.check_circle_rounded),
      _buildCard(
          'Remaining',
          remaining,
          remaining > 0 ? colorScheme.error : Colors.green.shade700,
          Icons.more_horiz_rounded),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: c,
            )))
            .toList(),
      );
    }

    return Column(children: cards
        .map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: c,
        ))
        .toList());
  }

  Widget _buildCard(String label, int value, Color color, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final display = (value * controller.value).round();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.currencySymbol}${fmt(display)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
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

class _SecondaryCards extends StatelessWidget {
  final Animation<double> controller;
  final int expenses;
  final int balance;
  final double efficiency;
  final bool isWide;
  final bool isDesktop;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _SecondaryCards({
    required this.controller,
    required this.expenses,
    required this.balance,
    required this.efficiency,
    required this.isWide,
    required this.isDesktop,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SecondaryCard(
        controller: controller,
        icon: Icons.receipt_long_rounded,
        label: 'Total Expenses',
        value: expenses,
        color: colorScheme.error,
        suffix: null,
        theme: theme,
        colorScheme: colorScheme,
        fmt: fmt,
      ),
      _SecondaryCard(
        controller: controller,
        icon: Icons.balance_rounded,
        label: 'Current Balance',
        value: balance,
        color: balance >= 0 ? colorScheme.tertiary : colorScheme.error,
        suffix: null,
        theme: theme,
        colorScheme: colorScheme,
        fmt: fmt,
      ),
      _SecondaryCard(
        controller: controller,
        icon: Icons.trending_up_rounded,
        label: 'Collection Efficiency',
        value: efficiency.round(),
        color: colorScheme.primary,
        suffix: '%',
        theme: theme,
        colorScheme: colorScheme,
        fmt: fmt,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((c) => Expanded(
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c)))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: c,
              ))
          .toList(),
    );
  }
}

class _SecondaryCard extends StatelessWidget {
  final Animation<double> controller;
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final String? suffix;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(int) fmt;

  const _SecondaryCard({
    required this.controller,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.suffix,
    required this.theme,
    required this.colorScheme,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final display = (value * controller.value).round();
            final displayStr = suffix != null
                ? '$display$suffix'
                : '${AppConstants.currencySymbol}${fmt(display)}';
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayStr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
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

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/collections?filter=pending'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                  const SizedBox(width: 8),
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
              const SizedBox(height: 12),
              Text(
                '${dashboard.pendingSponsorCount} Sponsors',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${NumberFormat('#,##,###', 'en_IN').format(dashboard.pendingRemainingTotal)} Remaining',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (dashboard.pendingSponsorCount == 0) ...[
                const SizedBox(height: 4),
                Text(
                  'All sponsorships collected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
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

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/daily-collections'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                  const SizedBox(width: 8),
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
              const SizedBox(height: 12),
              Text(
                '${AppConstants.currencySymbol}${NumberFormat('#,##,###', 'en_IN').format(dashboard.todayCollection)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dashboard.todayEntryCount} Entries Today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push('/followups'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
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
                      const SizedBox(width: 4),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No pending follow-ups',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'All sponsor visits are completed.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              ...visits.map((fu) => _VisitRow(
                    followup: fu,
                    theme: theme,
                    colorScheme: colorScheme,
                  )),
          ],
        ),
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

class _RecentActivity extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _RecentActivity({
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 40,
                    color: colorScheme.onSurface.withAlpha(50),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No recent activity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(100),
                    ),
                  ),
                  Text(
                    'Activity will appear here once you start recording',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(60),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
