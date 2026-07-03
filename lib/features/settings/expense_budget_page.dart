import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/expense_budget.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/expense_budget_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';
import 'package:ganesha_2026/shared/widgets/app_empty_state.dart';
import 'package:ganesha_2026/shared/widgets/app_skeleton.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';

class ExpenseBudgetPage extends ConsumerStatefulWidget {
  const ExpenseBudgetPage({super.key});

  @override
  ConsumerState<ExpenseBudgetPage> createState() => _ExpenseBudgetPageState();
}

class _ExpenseBudgetPageState extends ConsumerState<ExpenseBudgetPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(expenseBudgetServiceProvider).seedIfEmpty();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = ref.watch(roleProvider);
    final isAdmin = role == UserRole.admin;
    final itemsAsync = ref.watch(expenseBudgetStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Expense Budget'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSheet(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Category'),
            )
          : null,
      body: itemsAsync.when(
        loading: () => const AppSkeletonList(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.md),
                Text('Error loading budget: $e',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.error)),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.account_balance_rounded,
              title: 'No budget categories',
              subtitle: 'Add planned expense categories to get started',
            );
          }
          return _buildContent(items, isAdmin, theme);
        },
      ),
    );
  }

  Widget _buildContent(
      List<ExpenseBudget> items, bool isAdmin, ThemeData theme) {
    final total = items.fold<int>(0, (s, e) => s + e.plannedAmount);

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
      itemCount: items.length + 1,
      onReorder: (oldIndex, newIndex) {
        if (isAdmin) {
          _handleReorder(items, oldIndex, newIndex);
        }
      },
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Material(
          elevation: 4,
          borderRadius: AppRadius.largeBorder,
          child: child,
        ),
        child: child,
      ),
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTotalHeader(total, theme, key: const ValueKey('total'));
        }
        final item = items[index - 1];
        return _buildBudgetTile(item, index - 1, items.length, isAdmin, theme,
            key: ValueKey(item.id));
      },
    );
  }

  Widget _buildTotalHeader(int total, ThemeData theme, {required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: AppRadius.largeBorder,
          border: Border.all(color: AppColors.primary),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Planned Budget',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AmountText(
              amount: total,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTile(ExpenseBudget item, int itemIndex, int totalItems,
      bool isAdmin, ThemeData theme,
      {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.largeBorder,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: AppRadius.mediumBorder,
          ),
          child: Center(
            child: Text(
              '${itemIndex + 1}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountText(
              amount: item.plannedAmount,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: Icon(Icons.edit_rounded,
                    size: 18, color: AppColors.warmGray400),
                onPressed: () => _showEditSheet(context, item),
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon:
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                onPressed: () => _confirmDelete(context, item),
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleReorder(List<ExpenseBudget> items, int oldIndex, int newIndex) {
    if (oldIndex == 0 || newIndex == 0) return;
    final adjustedOld = oldIndex - 1;
    final adjustedNew = newIndex - 1;
    final reordered = List<ExpenseBudget>.from(items);
    final moved = reordered.removeAt(adjustedOld);
    reordered.insert(
        adjustedNew < reordered.length ? adjustedNew : reordered.length, moved);
    final orderedIds = reordered.map((e) => e.id).toList();
    ref.read(expenseBudgetServiceProvider).reorder(orderedIds);
  }

  void _showAddSheet(BuildContext context) {
    _showFormSheet(context, null);
  }

  void _showEditSheet(BuildContext context, ExpenseBudget item) {
    _showFormSheet(context, item);
  }

  void _showFormSheet(BuildContext context, ExpenseBudget? existing) {
    final theme = Theme.of(context);
    final isEditing = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final amountCtrl =
        TextEditingController(
            text: existing != null ? fmtAmount(existing.plannedAmount) : '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool submittedOnce = false;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              autovalidateMode: submittedOnce
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Category' : 'Add Category',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Decorations',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Category name is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountCtrl,
                    decoration: InputDecoration(
                      labelText: 'Planned Amount',
                      hintText: 'e.g. 50,000',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        Icons.currency_rupee_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: const [IndianAmountInputFormatter()],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final n = tryParseAmount(v.trim());
                      if (n == null || n <= 0) {
                        return 'Enter a valid positive amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      submittedOnce = true;
                      setSheetState(() {});
                      if (!formKey.currentState!.validate()) return;
                      final name = nameCtrl.text.trim();
                      final amount =
                          tryParseAmount(amountCtrl.text.trim()) ?? 0;
                      final service =
                          ref.read(expenseBudgetServiceProvider);
                      try {
                        if (isEditing) {
                          await service.update(existing.copyWith(
                            name: name,
                            plannedAmount: amount,
                          ));
                        } else {
                          final repo =
                              ref.read(expenseBudgetRepositoryProvider);
                          final all =
                              await repo.watchAll().first;
                          final maxOrder = all.fold<int>(
                              0, (s, e) => e.displayOrder > s ? e.displayOrder : s);
                          await service.create(ExpenseBudget(
                            id: repo.generateId(),
                            name: name,
                            plannedAmount: amount,
                            displayOrder: maxOrder + 1,
                            createdAt: Timestamp.now(),
                          ));
                        }
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (this.context.mounted) {
                          this.context.showSuccess(
                              isEditing
                                  ? 'Category updated'
                                  : 'Category added');
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx)
                            ..clearSnackBars()
                            ..showSnackBar(SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.error,
                            ));
                        }
                      }
                    },
                    child: Text(isEditing ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ExpenseBudget item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Delete "${item.name}" (${AppConstants.currencySymbol}${fmtAmount(item.plannedAmount)})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(expenseBudgetServiceProvider)
                    .delete(item.id);
                if (this.context.mounted) {
                  this.context.showSuccess('Category deleted');
                }
              } catch (e) {
                if (this.context.mounted) {
                  this.context.showError(e.toString());
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
