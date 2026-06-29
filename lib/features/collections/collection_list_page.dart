import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/financial_metrics_provider.dart';
import 'package:ganesha_2026/features/collections/collection_tile.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_metric_card.dart';
import 'package:ganesha_2026/shared/widgets/app_page_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/app_stagger.dart';
import 'package:ganesha_2026/shared/widgets/confirm_dialog.dart';

class CollectionListPage extends ConsumerStatefulWidget {
  const CollectionListPage({super.key});

  @override
  ConsumerState<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends ConsumerState<CollectionListPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'all';
  bool _initialized = false;
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    debugPrint('[LIFECYCLE] CollectionListPage.initState');
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[LIFECYCLE] CollectionListPage.postFrameCallback (stagger forward)');
      _staggerCtrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('[LIFECYCLE] CollectionListPage.didChangeDependencies');
    if (!_initialized) {
      _initialized = true;
      final filter = GoRouterState.of(context).uri.queryParameters['filter'];
      if (filter == 'pending') _filter = 'pending';
    }
  }

  @override
  void dispose() {
    debugPrint('[LIFECYCLE] CollectionListPage.dispose');
    _staggerCtrl.stop();
    _staggerCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BUILD] CollectionListPage.build');
    final targetsAsync = ref.watch(targetsStreamProvider);
    final theme = Theme.of(context);

    return AppPageScaffold(
      festivalName: 'Sponsors',
      onSettings: () => context.push('/settings'),
      onAdd: () => context.push('/collections/add'),
      showAdd: true,
      bottomNavHeight: 56,
      child: targetsAsync.when(
        data: (targets) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(targetsStreamProvider);
          },
          child: _buildList(context, ref, targets, theme),
        ),
        loading: () => const AppSkeletonList(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<Target> _filterTargets(List<Target> targets) {
    var result = targets;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.name.toLowerCase().contains(q) ||
            t.building.toLowerCase().contains(q) ||
            t.area.toLowerCase().contains(q);
      }).toList();
    }
    if (_filter == 'pending') {
      result = result.where((t) => t.givenAmount < t.expectedAmount).toList();
    } else if (_filter == 'collected') {
      result = result.where((t) => t.givenAmount >= t.expectedAmount).toList();
    }
    return result;
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Target> targets,
    ThemeData theme,
  ) {
    final totalSponsors = targets.length;
    final collectedSponsors = targets.where((t) => t.givenAmount >= t.expectedAmount).length;
    final pendingSponsors = targets.where((t) => t.givenAmount < t.expectedAmount).length;
    final metrics = ref.watch(financialMetricsProvider);

    final filtered = _filterTargets(targets);

    return ListView(
      padding: const EdgeInsets.only(bottom: 72),
      children: [
        // Summary metrics 2x2
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = (constraints.maxWidth - AppSpacing.sm) / 2;
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Total Sponsors',
                      value: '$totalSponsors',
                      icon: Icons.people_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Achieved',
                      value: '$collectedSponsors',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      iconBgColor: AppColors.successBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Active',
                      value: '$pendingSponsors',
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningBg,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: AppMetricCard(
                      label: 'Sponsor Remaining',
                      value: '${AppConstants.currencySymbol}${_fmt(metrics.sponsorRemaining)}',
                      icon: Icons.trending_down_rounded,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.errorBg,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search sponsors...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.warmGray50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide(color: AppColors.outline),
              ),
            ),
          ),
        ),
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter == 'all',
                onTap: () => setState(() => _filter = 'all'),
                color: AppColors.warmGray500,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Active',
                selected: _filter == 'pending',
                onTap: () => setState(() => _filter = 'pending'),
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Completed',
                selected: _filter == 'collected',
                onTap: () => setState(() => _filter = 'collected'),
                color: AppColors.success,
              ),
            ],
          ),
        ),
        // List or empty state
        if (filtered.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: AppEmptyState(
                icon: targets.isEmpty
                    ? Icons.people_outline_rounded
                    : Icons.search_off_rounded,
                title: targets.isEmpty
                    ? 'No sponsors yet'
                    : 'No sponsors match "$_searchQuery"',
                subtitle: targets.isEmpty
                    ? 'Tap + to add your first sponsor'
                    : null,
                action: targets.isEmpty
                    ? FilledButton.icon(
                        onPressed: () => context.push('/collections/add'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Sponsor'),
                      )
                    : null,
              ),
            ),
          )
        else
          ...List.generate(filtered.length, (index) {
            final target = filtered[index];
            return AppStagger(
              index: index,
              controller: _staggerCtrl,
              child: SponsorCard(
                target: target,
                onDelete: () => _handleDelete(context, ref, target),
                onQuickUpdate: () =>
                    _handleQuickUpdate(context, ref, target),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _handleQuickUpdate(
      BuildContext context, WidgetRef ref, Target target) async {
    await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _RecordCollectionDialog(target: target, ref: ref),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  Future<void> _handleDelete(
      BuildContext context, WidgetRef ref, Target target) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Sponsor',
      message: 'Delete "${target.name}"? This cannot be undone.',
    );
    if (!confirm) return;
    try {
      final service = ref.read(firestoreProvider);
      await service.deleteTarget(target.id);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete sponsor. Please try again.')),
        );
      }
    }
  }

  String _fmt(int n) {
    return fmtAmount(n);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
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
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.3) : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected ? color : AppColors.warmGray500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RecordCollectionDialog extends StatefulWidget {
  final Target target;
  final WidgetRef ref;

  const _RecordCollectionDialog({
    required this.target,
    required this.ref,
  });

  @override
  State<_RecordCollectionDialog> createState() =>
      _RecordCollectionDialogState();
}

class _RecordCollectionDialogState extends State<_RecordCollectionDialog>
    with SingleTickerProviderStateMixin {
  bool _isFull = true;
  final _amountCtrl = TextEditingController();
  bool _loading = false;
  bool _success = false;
  late AnimationController _successCtrl;
  int _collectedAmount = 0;

  Target get _t => widget.target;
  int get _rem => _t.expectedAmount - _t.givenAmount;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  int? get _amount =>
      _isFull ? _rem : tryParseAmount(_amountCtrl.text.trim());

  bool get _isValid {
    if (_loading) return false;
    final a = _amount;
    if (a == null || a <= 0) return false;
    if (a > _rem) return false;
    return true;
  }

  bool get _hasAmountError {
    final a = _amount;
    return a != null && a > _rem;
  }

  String _initials(String n) {
    final p = n.trim().split(RegExp(r'\s+'));
    if (p.length >= 2) {
      return '${p.first[0]}${p.last[0]}'.toUpperCase();
    }
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  Future<void> _submit() async {
    final a = _amount;
    if (a == null || a <= 0 || a > _rem) return;
    setState(() => _loading = true);
    try {
      final note = _isFull ? 'Full collection' : '';
      await widget.ref.read(firestoreProvider).recordContribution(
            targetId: _t.id,
            amount: a,
            note: note,
          );
      widget.ref.read(activityServiceProvider).recordContributionRecorded(
            _t,
            a,
            userId: widget.ref.read(userIdProvider),
            userName: widget.ref.read(userNameProvider),
          );
      _collectedAmount = a;
      setState(() => _success = true);
      _successCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.of(context).pop();
    } on Exception {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width * 0.91;
    final t = Theme.of(context);

    return Center(
      child: SizedBox(
        width: w,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _success
                ? _buildSuccessView(t)
                : _buildFormView(t, w, mq),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData t) {
    return Container(
      key: const ValueKey('success'),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.elevated,
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _successCtrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _successCtrl.value,
                  child: Transform.scale(
                    scale: 0.2 + (0.8 * _successCtrl.value),
                    child: child,
                  ),
                );
              },
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Collection Recorded',
              style: t.textTheme.headlineSmall?.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _t.name,
              style: t.textTheme.bodyMedium?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '₹${fmtAmount(_collectedAmount)}',
              style: t.textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData t, double w, MediaQueryData mq) {
    final amt = _amount ?? 0;
    final safe = amt.clamp(0, _rem);
    final afterCollected = _t.givenAmount + safe;
    final afterRemaining = _t.expectedAmount - afterCollected;
    final progress = _t.expectedAmount > 0
        ? afterCollected / _t.expectedAmount
        : 0.0;

    return Container(
      key: const ValueKey('form'),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.elevated,
      ),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.85),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(t),
            const SizedBox(height: 24),
            _buildSummary(t),
            const SizedBox(height: 24),
            _buildModeSelector(t),
            const SizedBox(height: 24),
            _buildAmountSection(t),
            const SizedBox(height: 24),
            _buildPreview(t, afterCollected, afterRemaining, progress),
            if (_hasAmountError) ...[
              const SizedBox(height: 8),
              _buildErrorCard(t),
            ],
            const SizedBox(height: 20),
            _buildFooter(t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData t) {
    final name = _t.name;
    final initials = _initials(name);
    final isCompleted = _rem <= 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryBg,
          child: Text(
            initials,
            style: t.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (isCompleted)
                _StatusChip(
                  label: 'Completed',
                  color: AppColors.warmGray500,
                  icon: Icons.check_rounded,
                )
              else
                _StatusChip(
                  label: 'Ready',
                  color: AppColors.success,
                  icon: Icons.check_rounded,
                ),
            ],
          ),
        ),
        if (!_loading)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.warmGray50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.warmGray400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummary(ThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.warmGray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryColumn(
              t,
              Icons.handshake_rounded,
              AppColors.primary,
              'Commitment',
              '₹${fmtAmount(_t.expectedAmount)}',
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryColumn(
              t,
              Icons.account_balance_wallet_rounded,
              AppColors.info,
              'Collected',
              '₹${fmtAmount(_t.givenAmount)}',
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryColumn(
              t,
              Icons.trending_up_rounded,
              _rem > 0 ? AppColors.warning : AppColors.success,
              'Remaining',
              '₹${fmtAmount(_rem)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.outline,
    );
  }

  Widget _buildSummaryColumn(
    ThemeData t,
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: t.textTheme.labelMedium?.copyWith(
            color: AppColors.warmGray500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector(ThemeData t) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.warmGray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              t,
              'Full Collection',
              _isFull,
              () => setState(() => _isFull = true),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSegment(
              t,
              'Partial',
              !_isFull,
              () => setState(() => _isFull = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(ThemeData t, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: t.textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : AppColors.warmGray600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection(ThemeData t) {
    if (_isFull) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Collecting',
                  style: t.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${fmtAmount(_rem)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: const [IndianAmountInputFormatter()],
            decoration: InputDecoration(
              labelText: 'Enter amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasAmountError ? AppColors.error : AppColors.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasAmountError ? AppColors.error : AppColors.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasAmountError ? AppColors.error : AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [0.25, 0.50, 0.75, 1.0].map((fraction) {
              final chipAmount = (_rem * fraction).round();
              final isActive = _amountCtrl.text == fmtAmount(chipAmount);
              return GestureDetector(
                onTap: () => _amountCtrl.text = fmtAmount(chipAmount),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryBg
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.outline,
                    ),
                  ),
                  child: Text(
                    '${(fraction * 100).toInt()}%',
                    style: t.textTheme.labelLarge?.copyWith(
                      color:
                          isActive ? AppColors.primary : AppColors.warmGray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining: ₹${fmtAmount(_rem)}',
            style: t.textTheme.bodySmall?.copyWith(
              color: AppColors.warmGray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
    ThemeData t,
    int afterCollected,
    int afterRemaining,
    double progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'After this collection',
              style: t.textTheme.labelMedium?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
            Text(
              '₹${fmtAmount(afterCollected)} / ₹${fmtAmount(_t.expectedAmount)}',
              style: t.textTheme.bodySmall?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.primaryBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).toInt()}%',
            style: t.textTheme.labelSmall?.copyWith(
              color: progress >= 1.0 ? AppColors.success : AppColors.warmGray500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(ThemeData t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Entered amount exceeds remaining balance.',
              style: t.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData t) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed:
                  _loading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.outline),
              ),
              child: Text(
                'Cancel',
                style: t.textTheme.titleSmall?.copyWith(
                  color: AppColors.warmGray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isValid ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.warmGray200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.card,
                      ),
                    )
                  : Text(
                      'Record Collection',
                      style: t.textTheme.titleSmall?.copyWith(
                        color: AppColors.card,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: t.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


