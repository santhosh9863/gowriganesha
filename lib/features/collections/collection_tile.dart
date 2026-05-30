import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  const _StatusData(this.label, this.icon, this.color);
}

_StatusData _statusData(_CollectionStatus s, ColorScheme cs) => switch (s) {
      _CollectionStatus.notStarted => _StatusData(
          'Not Started',
          Icons.circle_outlined,
          cs.outline,
        ),
      _CollectionStatus.pending => _StatusData(
          'Pending',
          Icons.schedule_rounded,
          Colors.orange.shade700,
        ),
      _CollectionStatus.complete => _StatusData(
          'Complete',
          Icons.check_circle_rounded,
          Colors.green.shade700,
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
    final sd = _statusData(status, colorScheme);
    final hasLocation = target.building.isNotEmpty || target.area.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/collections/${target.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(sd.icon, size: 16, color: sd.color),
                  const SizedBox(width: 6),
                  Text(
                    sd.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: sd.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      target.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
              if (hasLocation) ...[
                const SizedBox(height: 2),
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
              const SizedBox(height: 10),
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
                  const SizedBox(width: 16),
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
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit_rounded,
                            size: 16,
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
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
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
