import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/providers/festival_provider.dart';
import 'package:ganesha_2026/shared/utils/amount_format.dart';

class SponsorDiagnosticsResult {
  final List<Target> targets;
  final int budget;
  final List<DailyCollection> dailyCollections;
  final int sponsorCount;
  final int expectedTotal;
  final int sponsorCollected;
  final int sponsorRemaining;
  final int dailyCollected;
  final int difference;

  final List<String> warnings;

  SponsorDiagnosticsResult({
    required this.targets,
    required this.budget,
    required this.dailyCollections,
    required this.sponsorCount,
    required this.expectedTotal,
    required this.sponsorCollected,
    required this.sponsorRemaining,
    required this.dailyCollected,
    required this.difference,
    required this.warnings,
  });
}

Future<SponsorDiagnosticsResult> runSponsorDiagnostics(
    WidgetRef ref) async {
  final service = ref.read(firestoreProvider);
  final targets = await service.getAllTargets(AppConstants.festivalId);
  final budget = await service.getBudget(AppConstants.festivalId);
  final dailyCollections =
      await service.getAllDailyCollections(AppConstants.festivalId);

  final warnings = <String>[];
  final seenIds = <String>{};
  final seenNames = <String>{};

  for (final t in targets) {
    if (t.id.isEmpty || !seenIds.add(t.id)) {
      warnings.add('Duplicate or empty document ID: "${t.id}" for "${t.name}"');
    }
    if (t.name.isEmpty || !seenNames.add(t.name.toLowerCase().trim())) {
      warnings.add('Duplicate or empty name: "${t.name}"');
    }
    if (t.expectedAmount < 0) {
      warnings.add('Negative expectedAmount (${t.expectedAmount}) for "${t.name}"');
    }
    if (t.givenAmount < 0) {
      warnings.add('Negative givenAmount (${t.givenAmount}) for "${t.name}"');
    }
    if (t.festivalId != AppConstants.festivalId) {
      warnings.add(
          'Wrong festivalId "${t.festivalId}" for "${t.name}" (expected "${AppConstants.festivalId}")');
    }
  }

  final sponsorCount = targets.length;
  final expectedTotal =
      targets.fold<int>(0, (v, t) => v + t.expectedAmount);
  final sponsorCollected =
      targets.fold<int>(0, (v, t) => v + t.givenAmount);
  final sponsorRemaining = expectedTotal - sponsorCollected;
  final dailyCollected =
      dailyCollections.fold<int>(0, (v, dc) => v + dc.amount);
  final difference = budget - expectedTotal;

  return SponsorDiagnosticsResult(
    targets: targets,
    budget: budget,
    dailyCollections: dailyCollections,
    sponsorCount: sponsorCount,
    expectedTotal: expectedTotal,
    sponsorCollected: sponsorCollected,
    sponsorRemaining: sponsorRemaining,
    dailyCollected: dailyCollected,
    difference: difference,
    warnings: warnings,
  );
}

String _padRight(String s, int w) {
  if (s.length >= w) return s.substring(0, w);
  return s + ' ' * (w - s.length);
}

String _fmt(int n) => n.toString().padLeft(7);

String buildDiagnosticReport(SponsorDiagnosticsResult r) {
  final buf = StringBuffer();
  buf.writeln('=== Sponsor Diagnostics ===');
  buf.writeln();
  buf.writeln('Festival ID: ${AppConstants.festivalId}');
  buf.writeln('Festival Budget: ${AppConstants.currencySymbol}${fmtAmount(r.budget)}');
  buf.writeln();

  for (var i = 0; i < r.targets.length; i++) {
    final t = r.targets[i];
    final num = '${i + 1}.'.padLeft(3);
    buf.writeln(
        '$num ${_padRight(t.name, 26)} expected: ${_fmt(t.expectedAmount)}  given: ${_fmt(t.givenAmount)}  id: ${t.id}');
  }

  buf.writeln();
  buf.writeln('─' * 54);
  buf.writeln('Sponsor Count        : ${r.sponsorCount}');
  buf.writeln('Expected Total       : ${AppConstants.currencySymbol}${fmtAmount(r.expectedTotal)}');
  buf.writeln('Sponsor Collected    : ${AppConstants.currencySymbol}${fmtAmount(r.sponsorCollected)}');
  buf.writeln('Sponsor Remaining    : ${AppConstants.currencySymbol}${fmtAmount(r.sponsorRemaining)}');
  buf.writeln('Daily Collections    : ${AppConstants.currencySymbol}${fmtAmount(r.dailyCollected)}');
  buf.writeln('Festival Budget      : ${AppConstants.currencySymbol}${fmtAmount(r.budget)}');
  buf.writeln('Difference (Budget - Sponsor Total): ${AppConstants.currencySymbol}${fmtAmount(r.difference)}');
  buf.writeln('─' * 54);

  buf.writeln();
  buf.writeln('Dashboard Comparison:');
  buf.writeln(
      '  Dashboard collectedTotal (daily only): ${AppConstants.currencySymbol}${fmtAmount(r.dailyCollected)}');
  final expectedCollected = r.sponsorCollected + r.dailyCollected;
  buf.writeln(
      '  Expected collectedTotal (sponsor + daily): ${AppConstants.currencySymbol}${fmtAmount(expectedCollected)}');
  final expectedRemaining = r.budget - expectedCollected;
  buf.writeln(
      '  Expected remainingCollection: ${AppConstants.currencySymbol}${fmtAmount(expectedRemaining)}');
  if (r.difference != 0) {
    buf.writeln(
        '  ⚠ Budget (${AppConstants.currencySymbol}${fmtAmount(r.budget)}) differs from sponsor total (${AppConstants.currencySymbol}${fmtAmount(r.expectedTotal)}) by ${AppConstants.currencySymbol}${fmtAmount(r.difference)}');
  }
  if (r.sponsorCollected > 0 && r.dailyCollected == 0) {
    buf.writeln(
        '  ⚠ Sponsor collections exist (${AppConstants.currencySymbol}${fmtAmount(r.sponsorCollected)}) but dashboard collectedTotal = 0 (daily only)');
  }
  buf.writeln('─' * 54);

  buf.writeln();
  buf.writeln('Data Quality:');
  buf.writeln('  Duplicate IDs       : ${r.warnings.where((w) => w.contains('document ID')).length}');
  buf.writeln('  Duplicate names     : ${r.warnings.where((w) => w.contains('Duplicate name') || w.contains('empty name')).length}');
  buf.writeln('  Null/negative amounts: ${r.warnings.where((w) => w.contains('negative') || w.contains('Negative')).length}');
  buf.writeln('  Wrong festivalId    : ${r.warnings.where((w) => w.contains('festivalId')).length}');
  if (r.warnings.isNotEmpty) {
    buf.writeln();
    buf.writeln('Warnings:');
    for (final w in r.warnings) {
      buf.writeln('  ⚠ $w');
    }
  } else {
    buf.writeln('  All data quality checks passed ✅');
  }
  buf.writeln('=' * 54);

  return buf.toString();
}

Future<void> showDiagnosticsDialog(
    BuildContext context, SponsorDiagnosticsResult result) async {
  final report = buildDiagnosticReport(result);
  debugPrint(report);

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.bug_report_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          const Text('Sponsor Diagnostics'),
        ],
      ),
      content: SingleChildScrollView(
        child: SelectableText(
          report,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
