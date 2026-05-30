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
    final ratio = target.expectedAmount > 0
        ? (target.givenAmount / target.expectedAmount).clamp(0.0, 1.0)
        : 0.0;

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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: sd.color.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(sd.icon, size: 12, color: sd.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    sd.label,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: sd.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          target.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 6,
                                      backgroundColor:
                                          colorScheme.primaryContainer
                                              .withAlpha(120),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      AmountText(
                                        amount: target.givenAmount,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.tertiary,
                                        ),
                                      ),
                                      Text(
                                        ' of ',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      AmountText(
                                        amount: target.expectedAmount,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            GestureDetector(
                              onTap: onQuickUpdate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        colorScheme.tertiary.withAlpha(60),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Update',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.tertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 12,
                                      color: colorScheme.tertiary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
