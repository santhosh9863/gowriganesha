import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/shared/widgets/app_status_chip.dart';

enum _SponsorStatus { notStarted, pending, complete }

_SponsorStatus _status(Target t) {
  if (t.givenAmount >= t.expectedAmount) return _SponsorStatus.complete;
  if (t.givenAmount > 0) return _SponsorStatus.pending;
  return _SponsorStatus.notStarted;
}

AppChipVariant _chipVariant(_SponsorStatus s) => switch (s) {
      _SponsorStatus.notStarted => AppChipVariant.neutral,
      _SponsorStatus.pending => AppChipVariant.warning,
      _SponsorStatus.complete => AppChipVariant.success,
    };

String _statusLabel(_SponsorStatus s) => switch (s) {
      _SponsorStatus.notStarted => 'Not Started',
      _SponsorStatus.pending => 'Pending',
      _SponsorStatus.complete => 'Collected',
    };

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}';
  }
  return name.isNotEmpty ? name[0] : '?';
}

String _relTime(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays == 1) return 'yesterday';
  if (d.inDays < 30) return '${d.inDays}d ago';
  return DateFormat('d MMM').format(dt);
}

final _fmt = NumberFormat('#,##,###', 'en_IN');

class SponsorCard extends StatelessWidget {
  final Target target;
  final VoidCallback onDelete;
  final VoidCallback onQuickUpdate;

  const SponsorCard({
    super.key,
    required this.target,
    required this.onDelete,
    required this.onQuickUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _status(target);
    final ratio = target.expectedAmount > 0
        ? (target.givenAmount / target.expectedAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = target.expectedAmount - target.givenAmount;
    final location =
        '${target.building}${target.building.isNotEmpty && target.area.isNotEmpty ? ', ' : ''}${target.area}';
    final subtitle = location.isNotEmpty && location != ', '
        ? location
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.largeBorder,
          onTap: () => context.push('/collections/${target.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar, Name, Status, Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with initials
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: AppRadius.mediumBorder,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials(target.name),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Name + location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.warmGray400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Status chip
                    AppStatusChip(
                      label: _statusLabel(status),
                      variant: _chipVariant(status),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push('/collections/${target.id}/edit');
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: AppColors.warmGray200,
                    color: status == _SponsorStatus.complete
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Amounts row
                Row(
                  children: [
                    _AmountBlock(
                      label: 'Expected',
                      amount: target.expectedAmount,
                      color: AppColors.warmGray500,
                      theme: theme,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _AmountBlock(
                      label: 'Received',
                      amount: target.givenAmount,
                      color: status == _SponsorStatus.complete
                          ? AppColors.success
                          : AppColors.primary,
                      theme: theme,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _AmountBlock(
                      label: 'Remaining',
                      amount: remaining < 0 ? 0 : remaining,
                      color: remaining > 0 ? AppColors.warning : AppColors.warmGray400,
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Bottom row: Last updated + Quick actions
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.warmGray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _relTime(target.updatedAt.toDate()),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.warmGray400,
                      ),
                    ),
                    const Spacer(),
                    _QuickAction(
                      label: 'Collect',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      onTap: onQuickUpdate,
                      theme: theme,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickAction(
                      label: 'Follow Up',
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.warning,
                      onTap: () => context.push(
                        '/followups/add?targetName=$_name',
                      ),
                      theme: theme,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickAction(
                      label: 'View',
                      icon: Icons.visibility_rounded,
                      color: AppColors.warmGray500,
                      onTap: () =>
                          context.push('/collections/${target.id}'),
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _name => Uri.encodeComponent(target.name);
}

class _AmountBlock extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final ThemeData theme;

  const _AmountBlock({
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppConstants.currencySymbol}${_fmt.format(amount)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.warmGray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.mediumBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
