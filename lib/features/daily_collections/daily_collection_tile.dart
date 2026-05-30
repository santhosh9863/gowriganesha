import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';

class DailyCollectionTile extends StatelessWidget {
  final DailyCollection dailyCollection;
  final VoidCallback onDelete;

  const DailyCollectionTile({
    super.key,
    required this.dailyCollection,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    if (entryDate == today) {
      return DateFormat('hh:mm a').format(date);
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = _formatDate(dailyCollection.date.toDate());
    final isToday = DateTime(
          dailyCollection.date.toDate().year,
          dailyCollection.date.toDate().month,
          dailyCollection.date.toDate().day,
        ) ==
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push('/daily-collections/${dailyCollection.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isToday
                      ? colorScheme.secondaryContainer.withAlpha(80)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isToday
                      ? Icons.access_time_rounded
                      : Icons.account_balance_wallet_rounded,
                  color: isToday ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmountText(
                      amount: dailyCollection.amount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dailyCollection.note,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isToday
                              ? Icons.access_time_rounded
                              : Icons.calendar_today_rounded,
                          size: 14,
                          color: colorScheme.onSurface.withAlpha(128),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isToday
                                ? colorScheme.secondary
                                : colorScheme.onSurface.withAlpha(128),
                            fontWeight:
                                isToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context
                        .push('/daily-collections/${dailyCollection.id}/edit');
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
        ),
      ),
    );
  }
}
