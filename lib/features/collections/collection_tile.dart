import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';

enum _CollectionStatus { notStarted, pending, complete }

_CollectionStatus _status(Target t) {
  if (t.givenAmount >= t.expectedAmount) return _CollectionStatus.complete;
  if (t.givenAmount > 0) return _CollectionStatus.pending;
  return _CollectionStatus.notStarted;
}

class _StatusData {
  final String label;
  final IconData icon;
  final Color color;
  final Color border;
  const _StatusData(this.label, this.icon, this.color, this.border);
}

_StatusData _statusData(_CollectionStatus s) => switch (s) {
      _CollectionStatus.notStarted => _StatusData(
          'Not Started',
          Icons.circle_outlined,
          const Color(0xFF9CA3AF),
          const Color(0xFF9CA3AF),
        ),
      _CollectionStatus.pending => _StatusData(
          'Pending',
          Icons.schedule_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B),
        ),
      _CollectionStatus.complete => _StatusData(
          'Complete',
          Icons.check_circle_rounded,
          const Color(0xFF22C55E),
          const Color(0xFF22C55E),
        ),
    };

String _relativeTime(DateTime updated) {
  final now = DateTime.now();
  final diff = now.difference(updated);
  if (diff.inMinutes < 1) return 'Updated just now';
  if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
  if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Updated Yesterday';
  return 'Updated ${diff.inDays} days ago';
}

class CollectionTile extends StatelessWidget {
  final Target target;
  final VoidCallback onDelete;
  final VoidCallback onQuickUpdate;

  const CollectionTile({
    super.key,
    required this.target,
    required this.onDelete,
    required this.onQuickUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = _status(target);
    final sd = _statusData(status);
    final hasLocation = target.building.isNotEmpty || target.area.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        onTap: () => context.push('/collections/${target.id}'),
        borderRadius: AppRadius.cardBorder,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: AppColors.outline),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: sd.border,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.card),
                      bottomLeft: Radius.circular(AppRadius.card),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(sd.icon, size: 14, color: sd.color),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              sd.label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: sd.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  context.push(
                                      '/collections/${target.id}/edit');
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
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          target.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasLocation) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            [
                              if (target.building.isNotEmpty) target.building,
                              if (target.area.isNotEmpty) target.area,
                            ].join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _AmountLabel(
                                label: 'Expected',
                                amount: target.expectedAmount,
                                color: colorScheme.primary,
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: GestureDetector(
                                onTap: onQuickUpdate,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _AmountLabel(
                                        label: 'Received',
                                        amount: target.givenAmount,
                                        color: colorScheme.tertiary,
                                        theme: theme,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: colorScheme.tertiary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _relativeTime(target.updatedAt.toDate()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha(100),
                          ),
                        ),
                      ],
                    ),
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

class _AmountLabel extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final ThemeData theme;

  const _AmountLabel({
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AmountText(
          amount: amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
