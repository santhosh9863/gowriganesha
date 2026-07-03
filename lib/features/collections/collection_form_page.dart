import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';
import 'package:ganesha_2026/shared/widgets/adjust_collection_sheet.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';

class CollectionFormPage extends ConsumerStatefulWidget {
  final String? targetId;

  const CollectionFormPage({super.key, this.targetId});

  @override
  ConsumerState<CollectionFormPage> createState() => _CollectionFormPageState();
}

class _CollectionFormPageState extends ConsumerState<CollectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _expectedController;
  late final TextEditingController _givenController;
  late final TextEditingController _notesController;
  Target? _loadedTarget;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _submittedOnce = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _expectedController = TextEditingController();
    _givenController = TextEditingController();
    _notesController = TextEditingController();
    if (widget.targetId != null) {
      _loadTarget();
    } else {
      _isLoading = false;
    }
  }

  String _fmt(int n) {
    return fmtAmount(n);
  }

  Future<void> _loadTarget() async {
    final service = ref.read(firestoreProvider);
    final target = await service.getTarget(widget.targetId!);

    if (target != null && mounted) {
      _loadedTarget = target;
      _nameController.text = target.name;
      _expectedController.text = fmtAmount(target.expectedAmount);
      _givenController.text = fmtAmount(target.givenAmount);
      _notesController.text = target.notes ?? '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expectedController.dispose();
    _givenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.targetId != null;
    final role = ref.watch(roleProvider);

    if (isEditing && role != UserRole.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/collections');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sponsor' : 'Add Sponsor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                autovalidateMode: _submittedOnce
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Gowri Pooje Collection',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _expectedController,
                      decoration: InputDecoration(
                        labelText: 'Commitment Amount',
                        hintText: 'e.g. 1,00,000',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: const [IndianAmountInputFormatter()],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Commitment amount is required';
                        }
                        final n = tryParseAmount(v.trim());
                        if (n == null || n < 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    if (isEditing && _loadedTarget != null)
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: AppRadius.mediumBorder,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Collected',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                    Text(
                                        '${AppConstants.currencySymbol}${_fmt(_loadedTarget!.givenAmount)}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: () {
                              debugPrint('[ADJUST] STEP 1: Adjust Collection button pressed');
                              debugPrint('[ADJUST] context.mounted=${context.mounted} ref=$ref');
                              showAdjustCollectionSheet(context, ref, _loadedTarget!);
                            },
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            label: const Text('Adjust Collection'),
                          ),
                        ],
                      )
                    else
                      TextFormField(
                        controller: _givenController,
                        decoration: InputDecoration(
                          labelText: 'Amount Collected',
                          hintText: 'e.g. 50,000',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.currency_rupee_rounded,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: const [IndianAmountInputFormatter()],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Amount raised is required';
                          }
                          final n = tryParseAmount(v.trim());
                          if (n == null || n < 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Any additional details',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                      label: Text(isEditing ? 'Update Sponsor' : 'Add Sponsor'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSave() async {
    debugPrint('[HANDLE_SAVE_STEP-1] Starting');
    _submittedOnce = true;
    if (!_formKey.currentState!.validate()) {
      debugPrint('[HANDLE_SAVE_STEP-1a] Validation failed, returning');
      setState(() {});
      return;
    }
    if (_isSaving) {
      debugPrint('[HANDLE_SAVE_STEP-1b] Already saving, returning');
      return;
    }
    if (!mounted) {
      debugPrint('[HANDLE_SAVE_STEP-1c] Not mounted, returning');
      return;
    }
    if (widget.targetId != null && ref.read(roleProvider) != UserRole.admin) {
      context.showWarning('Access Denied');
      return;
    }
    setState(() => _isSaving = true);
    debugPrint('[HANDLE_SAVE_STEP-2] isSaving=true set');

    final service = ref.read(firestoreProvider);
    final now = Timestamp.now();
    Target? createdTarget;

    try {
      if (widget.targetId != null) {
        debugPrint('[HANDLE_SAVE_STEP-3] Update path');
        final givenAmount = _loadedTarget?.givenAmount ?? 0;
        final target = Target(
          id: widget.targetId!,
          festivalId: AppConstants.festivalId,
          name: _nameController.text.trim(),
          expectedAmount: parseAmount(_expectedController.text.trim()),
          givenAmount: givenAmount,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        debugPrint('[HANDLE_SAVE_STEP-4] About service.updateTarget');
        await service.updateTarget(target);
        debugPrint('[HANDLE_SAVE_STEP-5] updateTarget complete');
        debugPrint('[HANDLE_SAVE_STEP-6] About addActivity for update');
        await service.addActivity(Activity(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          type: 'sponsor_updated',
          title: 'Sponsor Updated',
          description: '${target.name} updated — commitment of ${AppConstants.currencySymbol}${fmtAmount(target.expectedAmount)}',
          createdAt: Timestamp.now(),
          recordId: target.id,
          entityType: 'target',
        ));
        debugPrint('[HANDLE_SAVE_STEP-7] addActivity for update complete');
      } else {
        debugPrint('[HANDLE_SAVE_STEP-3] Create path');
        createdTarget = Target(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          name: _nameController.text.trim(),
          expectedAmount: parseAmount(_expectedController.text.trim()),
          givenAmount: parseAmount(_givenController.text.trim()),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        debugPrint('[HANDLE_SAVE_STEP-4] About service.addTarget id=${createdTarget.id}');
        await service.addTarget(createdTarget);
        debugPrint('[HANDLE_SAVE_STEP-5] addTarget complete');
      }
    } on Exception catch (e) {
      debugPrint('[HANDLE_SAVE_CATCH] Exception: $e');
      if (mounted) {
        context.showError(e.toString());
      }
      return;
    } finally {
      debugPrint('[HANDLE_SAVE_FINALLY] Entered, mounted=$mounted');
      if (mounted) {
        setState(() => _isSaving = false);
      }
      debugPrint('[HANDLE_SAVE_FINALLY] Done');
    }

    debugPrint('[HANDLE_SAVE_STEP-8] After try/catch, createdTarget=$createdTarget, mounted=$mounted');

    if (createdTarget != null && mounted) {
      try {
        final activityService = ref.read(activityServiceProvider);
        final userId = ref.read(userIdProvider);
        final userName = ref.read(userNameProvider);
        debugPrint('[HANDLE_SAVE_STEP-9] About recordSponsorAdded userId=$userId userName=$userName');
        await activityService.recordSponsorAdded(
          createdTarget,
          userId: userId,
          userName: userName,
        );
        debugPrint('[HANDLE_SAVE_STEP-10] recordSponsorAdded complete');
      } catch (e) {
        debugPrint('[HANDLE_SAVE_STEP-ERR] recordSponsorAdded threw: $e');
      }
    }

    debugPrint('[HANDLE_SAVE_STEP-11] About context.pop()');
    if (mounted) context.pop();
    debugPrint('[HANDLE_SAVE_STEP-12] context.pop() returned');
  }
}
