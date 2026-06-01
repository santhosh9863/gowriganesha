import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
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
import 'package:ganesha_2026/shared/widgets/app_countdown_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_header.dart';
import 'package:ganesha_2026/shared/widgets/app_qr_sheet.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';

final _fmt = NumberFormat('#,##,###', 'en_IN');

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
          const SizedBox(height: AppSpacing.lg),
          AppCountdownCard(countdown: countdown),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 5, child: _HeroCard()),
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
          SizedBox(height: AppSpacing.lg),
          AppCountdownCard(countdown: countdown),
        ],
        SizedBox(height: AppSpacing.xl),
        _HeroCard(),
        SizedBox(height: AppSpacing.lg),
        _KpiGrid(),
        SizedBox(height: AppSpacing.lg),
        _QuickActions(),
        SizedBox(height: AppSpacing.lg),
        _CollectionTrend(),
        SizedBox(height: AppSpacing.xxl),
        _ActivityTimeline(),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, value, _) => Text(format(value.round()), style: style),
    );
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dashboardProvider);
    final pct = (db.progressPercent / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
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
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: AppRadius.mediumBorder,
                ),
                child: const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Festival Mission',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.warmGray400,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    '${db.progressPercent.toStringAsFixed(1)}% complete',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raised',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.warmGray500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _CountUp(
                      target: db.collectedTotal,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.charcoal,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                      format: (v) => '${AppConstants.currencySymbol}${_fmt.format(v)}',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Goal: ${AppConstants.currencySymbol}${_fmt.format(db.expectedTotal)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: AppColors.warmGray200,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${AppConstants.currencySymbol}${_shortFmt(db.remainingCollection)} to reach',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxl),
              _HeroRing(progress: pct, size: 96, stroke: 7),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _Metric(label: 'Sponsors', value: db.pendingSponsorCount),
              _Divider(),
              _Metric(label: 'Raised', value: AppConstants.currencySymbol + _shortFmt(db.collectedTotal)),
              _Divider(),
              _Metric(label: 'Active', value: db.pendingSponsorCount),
              _Divider(),
              _Metric(label: 'Goal Left', value: AppConstants.currencySymbol + _shortFmt(db.remainingCollection)),
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
        final w = (constraints.maxWidth - AppSpacing.lg) / 2;
        return Wrap(
          spacing: AppSpacing.lg, runSpacing: AppSpacing.lg,
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
              icon: Icons.notifications_rounded, label: 'Next Visits',
              value: db.pendingSponsorCount, trend: 'Needs visit',
              color: AppColors.primary, fmtCurrency: false,
            )),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final int value;
  final String trend;
  final Color color;
  final bool fmtCurrency;
  const _KpiCard({required this.icon, required this.label, required this.value, required this.trend, required this.color, required this.fmtCurrency});

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(
            color: _hover
                ? widget.color.withValues(alpha: 0.3)
                : AppColors.outline,
          ),
          boxShadow: _hover ? AppShadows.elevated : AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: Icon(widget.icon, size: 16, color: widget.color),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _CountUp(
              target: widget.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.charcoal,
                height: 1.0,
              ),
              format: widget.fmtCurrency
                  ? (v) => '${AppConstants.currencySymbol}${_shortFmt(v)}'
                  : (v) => '$v',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.trend,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.warmGray400,
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.warmGray500,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = (constraints.maxWidth - AppSpacing.md) / 2;
            return Wrap(
              spacing: AppSpacing.md, runSpacing: AppSpacing.md,
              children: [
                SizedBox(width: w, child: _ActionTile(icon: Icons.person_add_rounded, label: 'Sponsor', color: AppColors.primary, route: '/collections/add')),
                SizedBox(width: w, child: _ActionTile(icon: Icons.account_balance_wallet_rounded, label: 'Collection', color: AppColors.success, route: '/daily-collections/add')),
                SizedBox(width: w, child: _ActionTile(icon: Icons.notifications_active_rounded, label: 'Visit', color: AppColors.warning, route: '/followups/add')),
                SizedBox(width: w, child: _ActionTile(icon: Icons.receipt_rounded, label: 'Expense', color: AppColors.error, route: '/expenses/add')),
              ],
            );
          },
        ),
        if (festival != null) ...[
          const SizedBox(height: AppSpacing.md),
          _QrAction(festival: festival),
        ],
      ],
    );
  }
}

class _QrAction extends StatefulWidget {
  final Festival festival;
  const _QrAction({required this.festival});

  @override
  State<_QrAction> createState() => _QrActionState();
}

class _QrActionState extends State<_QrAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(
            color: _hover
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.outline,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppShadows.subtle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showPaymentQrSheet(context, widget.festival),
            borderRadius: AppRadius.largeBorder,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.qr_code_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Show QR',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.warmGray400),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.route});

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(
            color: _hover
                ? widget.color.withValues(alpha: 0.25)
                : AppColors.outline,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppShadows.subtle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(widget.route),
            borderRadius: AppRadius.largeBorder,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mediumBorder,
                  ),
                  child: Icon(widget.icon, size: 20, color: widget.color),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
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
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 160,
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
                  '${AppConstants.currencySymbol}${_fmt.format(total)}',
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
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final o = 0.04 + _ctrl.value * 0.06;
        return SizedBox(
          height: 160,
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
      },
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
    case 'expense_added': return AppColors.error;
    case 'followup_added': return AppColors.warning;
    case 'followup_completed': return AppColors.success;
    case 'sponsor_added': return AppColors.primary;
    default: return AppColors.warmGray400;
  }
}

IconData _actIcon(String type) {
  switch (type) {
    case 'collection_recorded': return Icons.account_balance_wallet_rounded;
    case 'expense_added': return Icons.receipt_rounded;
    case 'followup_added': return Icons.notifications_active_rounded;
    case 'followup_completed': return Icons.check_circle_rounded;
    case 'sponsor_added': return Icons.person_add_rounded;
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
      padding: const EdgeInsets.all(AppSpacing.xl),
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
              Text('Activity Feed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warmGray500)),
              Spacer(),
              Text('Timeline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.warmGray400)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            const SizedBox(
              height: 80,
              child: Center(
                child: Text('No activity yet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.warmGray500)),
              ),
            )
          else
            _buildList(items, theme),
        ],
      ),
    );
  }

  Widget _buildList(List<Activity> items, ThemeData theme) {
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
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
                  a.title,
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
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
