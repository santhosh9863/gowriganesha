import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/festival.dart';
import 'package:ganesha_2026/core/providers/dashboard_provider.dart';
import 'package:ganesha_2026/core/providers/activity_provider.dart';
import 'package:ganesha_2026/core/providers/chart_provider.dart';
import 'package:ganesha_2026/core/providers/daily_collection_provider.dart';
import 'package:ganesha_2026/core/providers/expense_provider.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/services/festival_countdown_service.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/app_page_header.dart';
import 'package:ganesha_2026/shared/widgets/app_qr_sheet.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
String _shortFmt(int n) {
  if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

double _roundInterval(double maxVal) {
  if (maxVal <= 0) return 1000;
  final exp = (math.log(maxVal.abs()) / math.ln10 - 1).ceil();
  final order = math.pow(10, exp < 0 ? 0 : exp).toDouble();
  if (order <= 0) return 1000;
  final n = maxVal / order;
  if (n <= 2) return 0.5 * order;
  if (n <= 5) return 1 * order;
  return 2 * order;
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetsAsync = ref.watch(targetsStreamProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);
    final collectionsAsync = ref.watch(dailyCollectionsStreamProvider);

    final festival = ref.watch(festivalProvider).valueOrNull;
    final countdown = festival?.festivalDate != null
        ? FestivalCountdownService().compute(festival!.festivalDate!)
        : null;

    final qrUrl = festival?.qrImageUrl;
    if (qrUrl != null && qrUrl.isNotEmpty) {
      precacheImage(NetworkImage(qrUrl), context);
    }

    final isLoading = targetsAsync.isLoading ||
        expensesAsync.isLoading ||
        collectionsAsync.isLoading;
    final hasError = targetsAsync.hasError ||
        expensesAsync.hasError ||
        collectionsAsync.hasError;

    if (hasError) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Failed to load dashboard',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.charcoal),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Check your connection and try again',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.warmGray500),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(targetsStreamProvider);
                      ref.invalidate(expensesStreamProvider);
                      ref.invalidate(dailyCollectionsStreamProvider);
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(child: const AppSkeletonList()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isWide = w > 900;
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dashboardProvider);
                  ref.invalidate(activitiesStreamProvider);
                  ref.invalidate(activeFollowUpsProvider);
                  ref.invalidate(dailyChartProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isWide ? AppSpacing.xxxl : AppSpacing.lg,
                    AppSpacing.xl,
                    isWide ? AppSpacing.xxxl : AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  child: isWide
                      ? _WideLayout(onSettings: () => context.push('/settings'), countdown: countdown)
                      : _NarrowLayout(onSettings: () => context.push('/settings'), countdown: countdown),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final VoidCallback? onSettings;
  final FestivalCountdownResult? countdown;
  const _WideLayout({this.onSettings, this.countdown});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(onSettings: onSettings),
        if (countdown != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _CompactCountdown(countdown: countdown!),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 5, child: _FestivalMission()),
            const SizedBox(width: AppSpacing.xxl),
            const Expanded(flex: 2, child: _QuickActions()),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 2, child: _KpiGrid()),
            const SizedBox(width: AppSpacing.xxl),
            const Expanded(flex: 3, child: _CollectionTrend()),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _ActivityTimeline(),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final VoidCallback? onSettings;
  final FestivalCountdownResult? countdown;
  const _NarrowLayout({this.onSettings, this.countdown});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(onSettings: onSettings),
        if (countdown != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _CompactCountdown(countdown: countdown!),
        ],
        const SizedBox(height: AppSpacing.md),
        const _FestivalMission(),
        const SizedBox(height: AppSpacing.md),
        const _QuickActions(),
        const SizedBox(height: AppSpacing.md),
        const _KpiGrid(),
        const SizedBox(height: AppSpacing.md),
        const _CollectionTrend(),
        const SizedBox(height: AppSpacing.xl),
        const _ActivityTimeline(),
      ],
    );
  }
}

class _CountUp extends StatelessWidget {
  final int target;
  final TextStyle? style;
  final String Function(int) format;
  const _CountUp({required this.target, this.style, required this.format});

  @override
  Widget build(BuildContext context) {
    return Text(format(target), style: style);
  }
}

class _CompactCountdown extends StatelessWidget {
  final FestivalCountdownResult countdown;
  const _CompactCountdown({required this.countdown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mediumBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(
            countdown.isPast
                ? Icons.check_circle_rounded
                : Icons.schedule_rounded,
            size: 18,
            color: countdown.isPast ? AppColors.warmGray400 : AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            countdown.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            countdown.formattedDate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.warmGray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FestivalMission extends ConsumerWidget {
  const _FestivalMission();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dashboardProvider);
    final pct = (db.progressPercent / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: AppRadius.mediumBorder,
                ),
                child: const Icon(Icons.flag_rounded, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Festival Mission',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.warmGray500,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CountUp(
                      target: db.collectedTotal,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.charcoal,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                      format: (v) => '${AppConstants.currencySymbol}${fmtAmount(v)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Goal: ${AppConstants.currencySymbol}${fmtAmount(db.expectedTotal)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              _HeroRing(progress: pct, size: 64, stroke: 5),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: AppColors.warmGray200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${db.progressPercent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${_shortFmt(db.remainingCollection)} to reach',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warmGray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Metric(label: 'Pending', value: db.pendingSponsorCount),
              _Divider(),
              _Metric(label: 'Expenses', value: AppConstants.currencySymbol + _shortFmt(db.totalExpenses)),
              _Divider(),
              _Metric(label: 'Balance', value: AppConstants.currencySymbol + _shortFmt(db.balance)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final dynamic value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.warmGray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 28, color: AppColors.outline,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _HeroRing extends StatelessWidget {
  final double progress;
  final double size;
  final double stroke;
  const _HeroRing({required this.progress, required this.size, required this.stroke});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _RingPainter(
              progress: 1, stroke: stroke,
              color: AppColors.warmGray200,
              trackColor: const Color(0x00000000),
            ),
            size: Size(size, size),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CustomPaint(
              painter: _RingPainter(
                progress: value, stroke: stroke,
                color: AppColors.primary, trackColor: const Color(0x00000000),
              ),
              size: Size(size, size),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double stroke;
  final Color color;
  final Color trackColor;
  _RingPainter({required this.progress, required this.stroke, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - stroke / 2;
    if (trackColor.a > 0) {
      canvas.drawCircle(c, r, Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round);
    }
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _KpiGrid extends ConsumerWidget {
  const _KpiGrid();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dashboardProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
          children: [
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.today_rounded, label: "Today's Collection",
              value: db.todayCollection, trend: '${db.todayEntryCount} entries',
              color: AppColors.success, fmtCurrency: true,
            )),
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.people_rounded, label: 'Active Sponsors',
              value: db.pendingSponsorCount,
              trend: '${AppConstants.currencySymbol}${_shortFmt(db.pendingRemainingTotal)} still to reach',
              color: AppColors.warning, fmtCurrency: false,
            )),
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.receipt_long_rounded, label: 'Expenses',
              value: db.totalExpenses,
              trend: db.totalExpenses > 0
                  ? '${((db.totalExpenses / (db.collectedTotal > 0 ? db.collectedTotal : 1)) * 100).toStringAsFixed(0)}% of collected'
                  : 'No expenses',
              color: AppColors.error, fmtCurrency: true,
            )),
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.notifications_rounded, label: 'Pending Visits',
              value: db.activeVisitCount, trend: '${db.overdueVisitCount} overdue',
              color: AppColors.primary, fmtCurrency: false,
            )),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final String trend;
  final Color color;
  final bool fmtCurrency;
  const _KpiCard({required this.icon, required this.label, required this.value, required this.trend, required this.color, required this.fmtCurrency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mediumBorder,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _CountUp(
            target: value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.charcoal,
              height: 1.0,
            ),
            format: fmtCurrency
                ? (v) => '${AppConstants.currencySymbol}${_shortFmt(v)}'
                : (v) => '$v',
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.warmGray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final festival = ref.watch(festivalProvider).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.warmGray500,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = (constraints.maxWidth - AppSpacing.sm) / 2;
            return Wrap(
              spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
              children: [
                SizedBox(width: w, child: _ActionTile(icon: Icons.person_add_rounded, label: 'Sponsor', color: AppColors.primary, onTap: () => context.push('/collections/add'))),
                SizedBox(width: w, child: _ActionTile(icon: Icons.account_balance_wallet_rounded, label: 'Collection', color: AppColors.success, onTap: () => context.push('/daily-collections/add'))),
                SizedBox(width: w, child: _ActionTile(icon: Icons.notifications_active_rounded, label: 'Visit', color: AppColors.warning, onTap: () => context.push('/followups/add'))),
                SizedBox(width: w, child: _ActionTile(icon: Icons.receipt_rounded, label: 'Expense', color: AppColors.error, onTap: () => context.push('/expenses/add'))),
              ],
            );
          },
        ),
        if (festival != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _QrStrip(festival: festival),
        ],
      ],
    );
  }
}

class _QrStrip extends StatelessWidget {
  final Festival festival;
  const _QrStrip({required this.festival});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.card,
      borderRadius: AppRadius.largeBorder,
      child: InkWell(
        onTap: () => showPaymentQrSheet(context, festival),
        borderRadius: AppRadius.largeBorder,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: AppRadius.largeBorder,
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.large),
                    bottomLeft: Radius.circular(AppRadius.large),
                  ),
                ),
                child: const Icon(Icons.qr_code_rounded, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Show Payment QR',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.warmGray400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.largeBorder,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.mediumBorder,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionTrend extends ConsumerWidget {
  const _CollectionTrend();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chartData = ref.watch(dailyChartProvider);
    final total = chartData.fold<int>(0, (v, p) => v + p.amount);
    final spots = chartData.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.amount.toDouble())).toList();
    final hasData = spots.isNotEmpty && spots.any((s) => s.y > 0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Trend',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.warmGray500,
                ),
              ),
              Text(
                '14 days',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.warmGray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: hasData
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _roundInterval(
                          chartData.map((e) => e.amount).reduce((a, b) => a > b ? a : b).toDouble(),
                        ),
                        getDrawingHorizontalLine: (v) => FlLine(color: AppColors.outline, strokeWidth: 1),
                      ),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          preventCurveOverShooting: true,
                          color: AppColors.primary,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.12),
                                AppColors.primary.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final idx = spot.spotIndex;
                              final label = idx < chartData.length ? chartData[idx].label : '';
                              return LineTooltipItem(
                                '$label\n${AppConstants.currencySymbol}${_shortFmt(spot.y.toInt())}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  )
                : const _ChartSkeleton(),
          ),
          if (hasData) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '${AppConstants.currencySymbol}${fmtAmount(total)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'total in 14 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGray400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChartSkeleton extends StatefulWidget {
  const _ChartSkeleton();
  @override
  State<_ChartSkeleton> createState() => _ChartSkeletonState();
}

class _ChartSkeletonState extends State<_ChartSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true)
      ..addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = 0.04 + _ctrl.value * 0.06;
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(10, (i) {
          final h = 0.2 + (i.isEven ? 0.3 : 0.5) + (i % 3 == 0 ? 0.2 : 0.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                height: 140 * h,
                decoration: BoxDecoration(
                  color: AppColors.warmGray400.withValues(alpha: o),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

String _relTime(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  if (d.inDays == 1) return 'yesterday';
  if (d.inDays < 30) return '${d.inDays}d';
  return DateFormat('d MMM').format(dt);
}

Color _actColor(String type) {
  switch (type) {
    case 'collection_recorded': return AppColors.success;
    case 'collection_corrected': return AppColors.warning;
    case 'expense_added': return AppColors.error;
    case 'followup_added': return AppColors.warning;
    case 'followup_completed': return AppColors.success;
    case 'followup_undo': return AppColors.warmGray500;
    case 'sponsor_added': return AppColors.primary;
    case 'sponsor_updated': return AppColors.info;
    case 'festival_updated': return AppColors.warmGray500;
    case 'qr_updated': return AppColors.info;
    default: return AppColors.warmGray400;
  }
}

IconData _actIcon(String type) {
  switch (type) {
    case 'collection_recorded': return Icons.account_balance_wallet_rounded;
    case 'collection_corrected': return Icons.edit_note_rounded;
    case 'expense_added': return Icons.receipt_rounded;
    case 'followup_added': return Icons.notifications_active_rounded;
    case 'followup_completed': return Icons.check_circle_rounded;
    case 'followup_undo': return Icons.undo_rounded;
    case 'sponsor_added': return Icons.person_add_rounded;
    case 'sponsor_updated': return Icons.edit_rounded;
    case 'festival_updated': return Icons.settings_rounded;
    case 'qr_updated': return Icons.qr_code_rounded;
    default: return Icons.circle_rounded;
  }
}

class _ActivityGroup {
  final String label;
  final List<Activity> activities;
  _ActivityGroup({required this.label, required this.activities});
}

List<_ActivityGroup> _groupActivities(List<Activity> activities) {
  final sorted = List<Activity>.from(activities)
    ..sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final groups = <_ActivityGroup>[];
  _ActivityGroup? current;
  for (final a in sorted) {
    final date = a.createdAt.toDate();
    final day = DateTime(date.year, date.month, date.day);
    final label = day == today
        ? 'Today'
        : day == yesterday
            ? 'Yesterday'
            : DateFormat('d MMM').format(date);
    if (current == null || current.label != label) {
      current = _ActivityGroup(label: label, activities: []);
      groups.add(current);
    }
    current.activities.add(a);
  }
  return groups;
}

class _ActivityTimeline extends ConsumerWidget {
  const _ActivityTimeline();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(activitiesStreamProvider).valueOrNull ?? [];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Activity Feed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warmGray500)),
              Spacer(),
              Text('Timeline', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.warmGray400)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            const SizedBox(
              height: 80,
              child: Center(
                child: Text('No activity yet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.warmGray500)),
              ),
            )
          else
            _buildList(context, items, theme),
        ],
      ),
    );
  }

  void _navigateToActivity(BuildContext context, Activity a) {
    if (a.recordId == null || a.entityType == null) return;
    switch (a.entityType) {
      case 'target':
        context.push('/collections/${a.recordId}');
      case 'expense':
        context.push('/expenses/${a.recordId}/edit');
      case 'sponsor_followup':
        context.push('/followups/${a.recordId}/edit');
      default:
        break;
    }
  }

  Widget _buildList(BuildContext context, List<Activity> items, ThemeData theme) {
    final groups = _groupActivities(items);
    final widgets = <Widget>[];
    var count = 0;
    for (final g in groups) {
      if (count >= 5) break;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          g.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.warmGray400,
            letterSpacing: 0.5,
          ),
        ),
      ));
      for (final a in g.activities) {
        if (count >= 5) break;
        count++;
        final c = _actColor(a.type);
        final icon = _actIcon(a.type);
        final canNavigate = a.recordId != null && a.entityType != null;
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: canNavigate ? () => _navigateToActivity(context, a) : null,
            borderRadius: AppRadius.mediumBorder,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: Icon(icon, size: 14, color: c),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    a.description.isNotEmpty ? a.description : a.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _relTime(a.createdAt.toDate()),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.warmGray400,
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
