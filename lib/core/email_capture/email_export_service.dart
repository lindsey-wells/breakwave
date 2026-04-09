// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: email_export_service.dart
// Purpose: BW-43 manual export service.
// Notes: Builds CSV/JSON export files and opens the system share sheet.
// ------------------------------------------------------------

import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'email_capture_settings.dart';
import 'email_capture_store.dart';

class EmailExportService {
  static String _timestampToken(DateTime now) {
    final String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  static bool hasExportableData(EmailCaptureSettings settings) {
    return settings.emailAddress.trim().isNotEmpty ||
        settings.marketingOptIn ||
        settings.researchOptIn;
  }

  static String buildCsv(EmailCaptureSettings settings, DateTime now) {
    final String safeEmail =
        settings.emailAddress.replaceAll('"', '""').trim();
    final String iso = now.toIso8601String();

    return [
      'email_address,marketing_opt_in,research_opt_in,exported_at_iso',
      '"$safeEmail",${settings.marketingOptIn},${settings.researchOptIn},"$iso"',
    ].join('\n');
  }

  static String buildJson(EmailCaptureSettings settings, DateTime now) {
    return const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'emailAddress': settings.emailAddress.trim(),
      'marketingOptIn': settings.marketingOptIn,
      'researchOptIn': settings.researchOptIn,
      'exportedAtIso': now.toIso8601String(),
    });
  }

  static Future<File> exportCsvFile() async {
    final EmailCaptureSettings settings = await EmailCaptureStore.load();
    final DateTime now = DateTime.now();

    final Directory dir = await getTemporaryDirectory();
    final String token = _timestampToken(now);
    final File file = File('${dir.path}/breakwave_email_export_$token.csv');

    await file.writeAsString(
      buildCsv(settings, now),
      flush: true,
    );

    return file;
  }

  static Future<File> exportJsonFile() async {
    final EmailCaptureSettings settings = await EmailCaptureStore.load();
    final DateTime now = DateTime.now();

    final Directory dir = await getTemporaryDirectory();
    final String token = _timestampToken(now);
    final File file = File('${dir.path}/breakwave_email_export_$token.json');

    await file.writeAsString(
      buildJson(settings, now),
      flush: true,
    );

    return file;
  }

  static Future<ShareResult> shareExportBundle() async {
    final File csvFile = await exportCsvFile();
    final File jsonFile = await exportJsonFile();

    return SharePlus.instance.share(
      ShareParams(
        title: 'BreakWave email export',
        subject: 'BreakWave email export',
        text: 'Manual export of BreakWave email-consent data.',
        files: <XFile>[
          XFile(csvFile.path),
          XFile(jsonFile.path),
        ],
      ),
    );
  }
}
