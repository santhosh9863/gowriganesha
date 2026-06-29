import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_2026/core/services/firestore_service.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/models/target.dart';
import 'package:ganesha_2026/core/models/expense.dart';
import 'package:ganesha_2026/core/models/daily_collection.dart';
import 'package:ganesha_2026/core/models/sponsor_followup.dart';
import 'package:ganesha_2026/core/models/activity.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';

String _csvEscape(String s) {
  if (s.contains(',') || s.contains('"') || s.contains('\n')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

String _tsStr(Timestamp ts) {
  return DateFormat('dd MMM yyyy HH:mm').format(ts.toDate());
}

String _dateStr(Timestamp ts) {
  return DateFormat('dd MMM yyyy').format(ts.toDate());
}

String _buildSponsorsCsv(List<Target> items) {
  final buf = StringBuffer('Name,Commitment,Collected,Remaining,Status,Created Date\n');
  for (final t in items) {
    final remaining = t.expectedAmount - t.givenAmount;
    final status = t.givenAmount >= t.expectedAmount ? 'Achieved' : 'Active';
    buf.writeln(
        '${_csvEscape(t.name)},${t.expectedAmount},${t.givenAmount},$remaining,$status,${_dateStr(t.createdAt)}');
  }
  return buf.toString();
}

String _buildCollectionsCsv(List<CollectionEntry> items) {
  final buf = StringBuffer('Amount,Sponsor,Created Date\n');
  for (final c in items) {
    buf.writeln('${c.amount},${_csvEscape(c.sponsorName)},${_dateStr(c.createdAt)}');
  }
  return buf.toString();
}

String _buildDailyCollectionsCsv(List<DailyCollection> items) {
  final buf = StringBuffer('Amount,Source,Created Date\n');
  for (final dc in items) {
    final note = dc.note.isNotEmpty ? dc.note : '-';
    buf.writeln('${dc.amount},${_csvEscape(note)},${_dateStr(dc.createdAt)}');
  }
  return buf.toString();
}

String _buildExpensesCsv(List<Expense> items) {
  final buf = StringBuffer('Amount,Purpose,Created Date\n');
  for (final e in items) {
    final note = e.note.isNotEmpty ? e.note : '-';
    buf.writeln('${e.amount},${_csvEscape(note)},${_dateStr(e.createdAt)}');
  }
  return buf.toString();
}

String _buildVisitsCsv(List<SponsorFollowup> items) {
  final buf = StringBuffer('Sponsor,Visit Date,Status,Amount,Created Date\n');
  for (final v in items) {
    final amount = v.amount != null ? '${v.amount}' : '-';
    buf.writeln(
        '${_csvEscape(v.sponsorName)},${_dateStr(v.followUpDate)},${v.status},$amount,${_dateStr(v.createdAt)}');
  }
  return buf.toString();
}

String _buildActivityCsv(List<Activity> items) {
  final buf = StringBuffer('Event Type,Description,Timestamp\n');
  for (final a in items) {
    final desc = a.description.isNotEmpty ? a.description : a.title;
    buf.writeln(
        '${_csvEscape(a.type)},${_csvEscape(desc)},${_tsStr(a.createdAt)}');
  }
  return buf.toString();
}

class CollectionEntry {
  final int amount;
  final String sponsorName;
  final Timestamp createdAt;
  const CollectionEntry({required this.amount, required this.sponsorName, required this.createdAt});
}

Future<void> exportAllData(BuildContext context, FirestoreService service) async {
  if (kIsWeb) {
    if (!context.mounted) return;
    context.showWarning('Export is not available on web. Please use the mobile app.');
    return;
  }

  final festivalId = AppConstants.festivalId;
  final warnings = <String>[];

  Future<T?> tryLoad<T>(String label, Future<T> Function() loader) async {
    try {
      final data = await loader();
      debugPrint('[EXPORT] Loaded ${data is List ? data.length : '?'} records from $label');
      return data;
    } on Exception catch (e) {
      debugPrint('[EXPORT] Failed to load $label: $e');
      warnings.add('$label could not be loaded');
      return null;
    }
  }

  try {
    final targets = await tryLoad<List<Target>>('targets', () => service.getAllTargets(festivalId));
    final expenses = await tryLoad<List<Expense>>('expenses', () => service.getAllExpenses(festivalId));
    final dailyCollections = await tryLoad<List<DailyCollection>>('daily_collections', () => service.getAllDailyCollections(festivalId));
    final followUps = await tryLoad<List<SponsorFollowup>>('followups', () => service.getAllFollowUps(festivalId));
    final activities = await tryLoad<List<Activity>>('activities', () => service.getAllActivities(festivalId));

    final tmpDir = await getTemporaryDirectory();
    final exportDir = Directory('${tmpDir.path}/ganesha_export');
    if (await exportDir.exists()) {
      await exportDir.delete(recursive: true);
    }
    await exportDir.create();

    final files = <XFile>[];

    if (targets != null) {
      files.add(await _writeFile(exportDir, 'sponsors.csv', _buildSponsorsCsv(targets)));

      final collectionEntries = <CollectionEntry>[];
      for (final t in targets) {
        if (t.givenAmount > 0) {
          collectionEntries.add(CollectionEntry(
            amount: t.givenAmount,
            sponsorName: t.name,
            createdAt: t.updatedAt,
          ));
        }
      }
      files.add(await _writeFile(exportDir, 'collections.csv', _buildCollectionsCsv(collectionEntries)));
    }

    if (expenses != null) {
      files.add(await _writeFile(exportDir, 'expenses.csv', _buildExpensesCsv(expenses)));
    }

    if (dailyCollections != null) {
      files.add(await _writeFile(exportDir, 'daily_collections.csv', _buildDailyCollectionsCsv(dailyCollections)));
    }

    if (followUps != null) {
      files.add(await _writeFile(exportDir, 'visits.csv', _buildVisitsCsv(followUps)));
    }

    if (activities != null) {
      files.add(await _writeFile(exportDir, 'activity.csv', _buildActivityCsv(activities)));
    }

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      context.showWarning('No data to export');
      return;
    }

    await Share.shareXFiles(files, text: 'Ganesha Festival Data Export');

    final msg = warnings.isEmpty
        ? 'Export completed'
        : 'Export completed. ${warnings.join('; ')}.';
    ScaffoldMessenger.of(context).clearSnackBars();
    context.showInfo(msg);
  } on Exception catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    context.showError('Export failed: $e');
  }
}

Future<XFile> _writeFile(Directory dir, String name, String content) async {
  final file = File('${dir.path}/$name');
  await file.writeAsString(content);
  return XFile(file.path);
}
