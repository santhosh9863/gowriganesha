import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';

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
  bool _isLoading = true;

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

  Future<void> _loadTarget() async {
    final service = ref.read(firestoreProvider);
    final target = await service.getTarget(widget.targetId!);

    if (target != null && mounted) {
      _nameController.text = target.name;
      _expectedController.text = target.expectedAmount.toString();
      _givenController.text = target.givenAmount.toString();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sponsor' : 'Add Sponsor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _expectedController,
                      decoration: InputDecoration(
                        labelText: 'Expected Sponsorship',
                        hintText: 'e.g. 100000',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Expected sponsorship is required';
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _givenController,
                      decoration: InputDecoration(
                        labelText: 'Received Amount',
                        hintText: 'e.g. 50000',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.currency_rupee_rounded,
                          color: colorScheme.tertiary,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Received amount is required';
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                      label: Text(isEditing ? 'Update Sponsor' : 'Add Sponsor'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final service = ref.read(firestoreProvider);
    final now = Timestamp.now();

    try {
      if (widget.targetId != null) {
        final target = Target(
          id: widget.targetId!,
          festivalId: AppConstants.festivalId,
          name: _nameController.text.trim(),
          expectedAmount: int.parse(_expectedController.text.trim()),
          givenAmount: int.parse(_givenController.text.trim()),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await service.updateTarget(target);
      } else {
        final target = Target(
          id: service.generateId(),
          festivalId: AppConstants.festivalId,
          name: _nameController.text.trim(),
          expectedAmount: int.parse(_expectedController.text.trim()),
          givenAmount: int.parse(_givenController.text.trim()),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await service.addTarget(target);
      }

      if (mounted) context.pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
