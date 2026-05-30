import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/models/festival.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/core/providers/dashboard_provider.dart';
import 'package:ganesha_2026/core/providers/target_provider.dart';
import 'package:ganesha_2026/shared/widgets/amount_text.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final festivalAsync = ref.watch(festivalProvider);
    final dashboard = ref.watch(dashboardProvider);
    final targetsAsync = ref.watch(targetsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: 'Festival Information', icon: Icons.info_rounded),
            const SizedBox(height: 8),
            festivalAsync.when(
              data: (festival) => _FestivalCard(festival: festival, ref: ref),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error loading festival: $e'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Data Summary', icon: Icons.bar_chart_rounded),
            const SizedBox(height: 8),
            _DataSummaryCard(
              dashboard: dashboard,
              targetCount: (targetsAsync.valueOrNull ?? []).length,
              theme: theme,
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'About', icon: Icons.info_outline_rounded),
            const SizedBox(height: 8),
            _AboutCard(theme: theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FestivalCard extends ConsumerStatefulWidget {
  final Festival festival;
  final WidgetRef ref;

  const _FestivalCard({required this.festival, required this.ref});

  @override
  ConsumerState<_FestivalCard> createState() => _FestivalCardState();
}

class _FestivalCardState extends ConsumerState<_FestivalCard> {
  late TextEditingController _nameController;
  late TextEditingController _yearController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.festival.name);
    _yearController = TextEditingController(text: widget.festival.year.toString());
    _locationController = TextEditingController(text: widget.festival.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final yearStr = _yearController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || yearStr.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    final year = int.tryParse(yearStr);
    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid year')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = ref.read(firestoreProvider);
      final updated = widget.festival.copyWith(
        name: name,
        year: year,
        location: location,
      );
      await service.setFestival(updated);
      ref.invalidate(festivalProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Festival information updated')),
      );
    } on Exception catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Festival Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataSummaryCard extends StatelessWidget {
  final DashboardData dashboard;
  final int targetCount;
  final ThemeData theme;

  const _DataSummaryCard({
    required this.dashboard,
    required this.targetCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Sponsor Count',
              value: targetCount.toString(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Expected Sponsorship',
              valueWidget: AmountText(
                amount: dashboard.expectedTotal,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Collected Amount',
              valueWidget: AmountText(
                amount: dashboard.collectedTotal,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Total Expenses',
              valueWidget: AmountText(
                amount: dashboard.totalExpenses,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final ThemeData theme;

  const _SummaryRow({
    required this.label,
    this.value = '',
    this.valueWidget,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        valueWidget ??
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  final ThemeData theme;

  const _AboutCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sri Gowri Ganesha Geleyara Balaga',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Flutter Web + Firebase',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
