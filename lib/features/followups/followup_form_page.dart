import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';

class FollowUpFormPage extends ConsumerStatefulWidget {
  final String? followUpId;

  const FollowUpFormPage({super.key, this.followUpId});

  @override
  ConsumerState<FollowUpFormPage> createState() => _FollowUpFormPageState();
}

class _FollowUpFormPageState extends ConsumerState<FollowUpFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sponsorNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  DateTime? _followUpDate;
  bool _isLoading = true;
  String _sponsorId = '';
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _sponsorNameController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    if (widget.followUpId != null) {
      _loadFollowUp();
    } else {
      _followUpDate = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.followUpId == null) {
      _initialized = true;
      final queryParams = GoRouterState.of(context).uri.queryParameters;
      _sponsorId = queryParams['sponsorId'] ?? '';
      final sponsorName = (queryParams['sponsorName'] ?? queryParams['targetName']) ?? '';
      if (sponsorName.isNotEmpty) {
        _sponsorNameController.text = Uri.decodeComponent(sponsorName);
      }
      _isLoading = false;
    }
  }

  Future<void> _loadFollowUp() async {
    final service = ref.read(firestoreProvider);
    final item = await service.getFollowUp(widget.followUpId!);
    if (item != null && mounted) {
      _sponsorNameController.text = item.sponsorName;
      _amountController.text = item.amount != null ? fmtAmount(item.amount!) : '';
      _noteController.text = item.note;
      _followUpDate = item.followUpDate.toDate();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _sponsorNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select visit date',
    );
    if (picked != null) setState(() => _followUpDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.followUpId != null;
    final dateStr = _followUpDate != null
        ? DateFormat('dd MMM yyyy').format(_followUpDate!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Visit' : 'Add Visit'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_sponsorId.isEmpty)
                      TextFormField(
                        controller: _sponsorNameController,
                        decoration: InputDecoration(
                          labelText: 'Sponsor Name',
                          hintText: 'e.g. Doctor',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Sponsor name is required'
                            : null,
                      ),
                    if (_sponsorId.isEmpty) const SizedBox(height: AppSpacing.lg),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Visit Date',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.calendar_today_rounded,
                            color: colorScheme.primary,
                          ),
                          suffixIcon:
                              const Icon(Icons.arrow_drop_down_rounded),
                        ),
                        child: Text(
                          dateStr ?? 'Select date',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: dateStr != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ),
                    ),
                    if (_followUpDate == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          'Visit date is required',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount (optional)',
                        hintText: 'e.g. 5,000',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: colorScheme.secondary,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: const [IndianAmountInputFormatter()],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        hintText: 'What was discussed?',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: null,
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
                          : Icon(isEditing
                              ? Icons.save_rounded
                              : Icons.add_rounded),
                      label:
                          Text(isEditing ? 'Update Visit' : 'Add Visit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_followUpDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a visit date')),
      );
      return;
    }
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final service = ref.read(firestoreProvider);
    final now = Timestamp.now();
    final amountText = _amountController.text.trim();
    final amount =
        amountText.isNotEmpty ? tryParseAmount(amountText) : null;

    try {
      if (widget.followUpId != null) {
        final item = SponsorFollowup(
          id: widget.followUpId!,
          festivalId: AppConstants.festivalId,
          sponsorName: _sponsorNameController.text.trim(),
          followUpDate: Timestamp.fromDate(_followUpDate!),
          amount: amount,
          note: _noteController.text.trim(),
          createdAt: now,
        );
        await service.updateFollowUp(item);
      } else {
        final item = SponsorFollowup(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          sponsorId: _sponsorId,
          sponsorName: _sponsorNameController.text.trim(),
          followUpDate: Timestamp.fromDate(_followUpDate!),
          amount: amount,
          note: _noteController.text.trim(),
          createdAt: now,
        );
        await service.addFollowUp(item);
        service.addActivity(Activity(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          type: 'followup_added',
          title: 'Visit Added',
          description: 'Visit scheduled for ${item.sponsorName}',
          createdAt: Timestamp.now(),
          recordId: item.id,
          entityType: 'sponsor_followup',
        ));
      }
      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
