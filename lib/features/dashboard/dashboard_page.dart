import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/dashboard_provider.dart';
import 'package:ganesha_2026/core/providers/activity_provider.dart';
import 'package:ganesha_2026/core/providers/chart_provider.dart';
import 'package:ganesha_2026/core/providers/followup_provider.dart';
import 'package:ganesha_2026/shared/widgets/app_page_header.dart';

const _s8 = 8.0;
const _s12 = 12.0;
const _s16 = 16.0;
const _s20 = 20.0;
const _s24 = 24.0;
const _s32 = 32.0;

const _green = Color(0xFF0F6B3C);
const _greenLight = Color(0xFFE8F5E9);
const _success = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);
const _surface = Color(0xFFF4F6F8);
const _card = Color(0xFFFFFFFF);
const _textPri = Color(0xFF1A1A2E);
const _textSec = Color(0xFF6B7280);
const _textTer = Color(0xFF9CA3AF);
const _border = Color(0xFFE2E4E9);
const _shadow = Color(0x0A000000);

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
    return Scaffold(
      backgroundColor: _surface,
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
                    isWide ? _s32 : _s16, _s20, isWide ? _s32 : _s16, _s32,
                  ),
                  child: isWide
                      ? _WideLayout(onSettings: () => context.push('/settings'))
                      : _NarrowLayout(onSettings: () => context.push('/settings')),
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
  const _WideLayout({this.onSettings});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(onSettings: onSettings),
        const SizedBox(height: _s24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 5, child: _HeroCard()),
            const SizedBox(width: _s24),
            const Expanded(flex: 2, child: _QuickActions()),
          ],
        ),
        const SizedBox(height: _s24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 2, child: _KpiGrid()),
            const SizedBox(width: _s24),
            const Expanded(flex: 3, child: _CollectionTrend()),
          ],
        ),
        const SizedBox(height: _s24),
        const _ActivityTimeline(),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final VoidCallback? onSettings;
  const _NarrowLayout({this.onSettings});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPageHeader(onSettings: onSettings),
        SizedBox(height: _s20),
        _HeroCard(),
        SizedBox(height: _s16),
        _KpiGrid(),
        SizedBox(height: _s16),
        _QuickActions(),
        SizedBox(height: _s16),
        _CollectionTrend(),
        SizedBox(height: _s24),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_s24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: _greenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up_rounded, size: 18, color: _green),
              ),
              const SizedBox(width: _s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Festival Goal',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textTer, letterSpacing: 0.3),
                  ),
                  Consumer(builder: (context, ref, _) {
                    final db = ref.watch(dashboardProvider);
                    return Text(
                      '${db.progressPercent.toStringAsFixed(1)}% complete',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _success),
                    );
                  }),
                ],
              ),
              const Spacer(),
              const Icon(Icons.trending_up_rounded, size: 16, color: _textTer),
            ],
          ),
          const SizedBox(height: _s24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collected',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textSec),
                    ),
                    const SizedBox(height: 4),
                    Consumer(builder: (context, ref, _) {
                      final db = ref.watch(dashboardProvider);
                      return _CountUp(
                        target: db.collectedTotal,
                        style: const TextStyle(
                          fontSize: 38, fontWeight: FontWeight.w700, color: _textPri,
                          letterSpacing: -1.5, height: 1.0,
                        ),
                        format: (v) => '${AppConstants.currencySymbol}${_fmt.format(v)}',
                      );
                    }),
                    const SizedBox(height: 4),
                    Consumer(builder: (context, ref, _) {
                      final db = ref.watch(dashboardProvider);
                      return Text(
                        'Target: ${AppConstants.currencySymbol}${_fmt.format(db.expectedTotal)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textTer),
                      );
                    }),
                    const SizedBox(height: _s20),
                    Consumer(builder: (context, ref, _) {
                      final db = ref.watch(dashboardProvider);
                      final pct = db.progressPercent / 100;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOut,
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          const SizedBox(height: _s8),
                          Row(
                            children: [
                              Text(
                                '${AppConstants.currencySymbol}${_shortFmt(db.remainingCollection)} remaining',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textTer),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: _s24),
              Consumer(builder: (context, ref, _) {
                final db = ref.watch(dashboardProvider);
                return _HeroRing(
                  progress: (db.progressPercent / 100).clamp(0.0, 1.0),
                  size: 96,
                  stroke: 7,
                );
              }),
            ],
          ),
          const SizedBox(height: _s20),
          Consumer(builder: (context, ref, _) {
            final db = ref.watch(dashboardProvider);
            final sponsorCount = db.pendingSponsorCount +
                (db.collectedTotal > 0 ? 1 : 0);
            return Row(
              children: [
                _Metric(label: 'Sponsors', value: sponsorCount),
                _Divider(),
                _Metric(label: 'Collections', value: '${AppConstants.currencySymbol}${_shortFmt(db.collectedTotal)}'),
                _Divider(),
                _Metric(label: 'Pending', value: db.pendingSponsorCount),
                _Divider(),
                _Metric(label: 'Visits', value: db.pendingSponsorCount),
              ],
            );
          }),
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
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPri),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _textTer),
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
      width: 1, height: 28, color: _border,
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
              color: const Color(0xFFE5E7EB),
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
                color: _green, trackColor: const Color(0x00000000),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _green),
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
        final w = (constraints.maxWidth - _s16) / 2;
        return Wrap(
          spacing: _s16, runSpacing: _s16,
          children: [
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.today_rounded, label: "Today's Collection",
              value: db.todayCollection, trend: '${db.todayEntryCount} entries',
              color: _success, fmtCurrency: true,
            )),
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.people_rounded, label: 'Pending Sponsors',
              value: db.pendingSponsorCount,
              trend: '${AppConstants.currencySymbol}${_shortFmt(db.pendingRemainingTotal)} remaining',
              color: _amber, fmtCurrency: false,
            )),
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.notifications_rounded, label: 'Pending Visits',
              value: db.pendingSponsorCount, trend: 'Requires action',
              color: _green, fmtCurrency: false,
            )),
            SizedBox(width: w, child: _KpiCard(
              icon: Icons.receipt_long_rounded, label: 'Expenses',
              value: db.totalExpenses,
              trend: db.totalExpenses > 0
                  ? '${((db.totalExpenses / (db.collectedTotal > 0 ? db.collectedTotal : 1)) * 100).toStringAsFixed(0)}% of collected'
                  : 'No expenses',
              color: _red, fmtCurrency: true,
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(_s16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _shadow,
              blurRadius: _hover ? 8 : 4,
              offset: Offset(0, _hover ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, size: 16, color: widget.color),
                ),
              ],
            ),
            const SizedBox(height: _s12),
            _CountUp(
              target: widget.value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _textPri, height: 1.0),
              format: widget.fmtCurrency
                  ? (v) => '${AppConstants.currencySymbol}${_shortFmt(v)}'
                  : (v) => '$v',
            ),
            const SizedBox(height: 4),
            Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textSec)),
            const SizedBox(height: 4),
            Text(widget.trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _textTer)),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: _s12),
          child: Text('Quick Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSec)),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = (constraints.maxWidth - _s12) / 2;
            return Wrap(
              spacing: _s12, runSpacing: _s12,
              children: [
                SizedBox(width: w, child: _ActionTile(icon: Icons.person_add_rounded, label: 'Sponsor', color: _green, route: '/collections/add')),
                SizedBox(width: w, child: _ActionTile(icon: Icons.account_balance_wallet_rounded, label: 'Collection', color: _success, route: '/daily-collections/add')),
                SizedBox(width: w, child: _ActionTile(icon: Icons.notifications_active_rounded, label: 'Follow Up', color: _amber, route: '/followups/add')),
                SizedBox(width: w, child: _ActionTile(icon: Icons.receipt_rounded, label: 'Expense', color: _red, route: '/expenses/add')),
              ],
            );
          },
        ),
      ],
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 100,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.color.withValues(alpha: _hover ? 0.2 : 0.08)),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(_shadow, widget.color.withValues(alpha: 0.06), _hover ? 1 : 0)!,
              blurRadius: _hover ? 8 : 4,
              offset: Offset(0, _hover ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(widget.route),
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 20, color: widget.color),
                ),
                const SizedBox(height: _s8),
                Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
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
    final chartData = ref.watch(dailyChartProvider);
    final total = chartData.fold<int>(0, (v, p) => v + p.amount);
    final spots = chartData.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.amount.toDouble())).toList();
    final hasData = spots.isNotEmpty && spots.any((s) => s.y > 0);

    return Container(
      padding: const EdgeInsets.all(_s20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Collection Trend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSec)),
              Text('14 days', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _textTer)),
            ],
          ),
          const SizedBox(height: _s20),
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
                        getDrawingHorizontalLine: (v) => FlLine(color: _border, strokeWidth: 1),
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
                          color: _green,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                _green.withValues(alpha: 0.12),
                                _green.withValues(alpha: 0.0),
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
            const SizedBox(height: _s12),
            Row(
              children: [
                Text(
                  '${AppConstants.currencySymbol}${_fmt.format(total)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPri),
                ),
                const SizedBox(width: 6),
                const Text('total in 14 days', style: TextStyle(fontSize: 12, color: _textTer)),
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
                      color: _textPri.withValues(alpha: o),
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
    case 'collection_recorded': return _success;
    case 'expense_added': return _red;
    case 'followup_added': return _amber;
    case 'followup_completed': return _success;
    default: return _textTer;
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
    final items = ref.watch(activitiesStreamProvider).valueOrNull ?? [];
    return Container(
      padding: const EdgeInsets.all(_s20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Recent Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSec)),
              Spacer(),
              Text('Timeline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _textTer)),
            ],
          ),
          const SizedBox(height: _s16),
          if (items.isEmpty)
            const SizedBox(
              height: 80,
              child: Center(
                child: Text('No activity yet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textSec)),
              ),
            )
          else
            _buildList(items),
        ],
      ),
    );
  }

  Widget _buildList(List<Activity> items) {
    final groups = _groupActivities(items);
    final widgets = <Widget>[];
    var count = 0;
    for (final g in groups) {
      if (count >= 5) break;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: _s8),
        child: Text(g.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textTer, letterSpacing: 0.5)),
      ));
      for (final a in g.activities) {
        if (count >= 5) break;
        count++;
        final c = _actColor(a.type);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textPri),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text(_relTime(a.createdAt.toDate()), style: const TextStyle(fontSize: 11, color: _textTer)),
            ],
          ),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
