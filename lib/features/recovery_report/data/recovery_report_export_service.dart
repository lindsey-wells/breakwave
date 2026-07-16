// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: recovery_report_export_service.dart
// Purpose: Create and share sanitized recovery-report files.
// Notes: BW-87B6B2 exports only an already-previewed snapshot.
// Notes: Files use neutral names and temporary app storage.
// ------------------------------------------------------------

import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/recovery_report_formatter.dart';
import '../domain/recovery_report_selection.dart';
import '../domain/recovery_report_snapshot.dart';

class RecoveryReportExportFiles {
  const RecoveryReportExportFiles({
    required this.textFile,
    required this.jsonFile,
  });

  final File textFile;
  final File jsonFile;
}

class RecoveryReportExportService {
  const RecoveryReportExportService._();

  static String timestampToken(
    DateTime value,
  ) {
    String two(int number) =>
        number.toString().padLeft(2, '0');

    return '${value.year}'
        '${two(value.month)}'
        '${two(value.day)}_'
        '${two(value.hour)}'
        '${two(value.minute)}'
        '${two(value.second)}';
  }

  static String fileStemFor({
    required RecoveryReportRange range,
    required DateTime generatedAt,
  }) {
    return 'breakwave_recovery_report_'
        '${range.days}d_'
        '${timestampToken(generatedAt)}';
  }

  static Future<RecoveryReportExportFiles>
      createFiles(
    RecoveryReportSnapshot snapshot,
  ) async {
    final Directory directory =
        await getTemporaryDirectory();

    final DateTime generatedAt =
        DateTime.tryParse(
          snapshot.generatedAtIso,
        )?.toLocal() ??
            DateTime.now();

    final String stem = fileStemFor(
      range: snapshot.range,
      generatedAt: generatedAt,
    );

    final File textFile = File(
      '${directory.path}/$stem.txt',
    );

    final File jsonFile = File(
      '${directory.path}/$stem.json',
    );

    await textFile.writeAsString(
      RecoveryReportFormatter.buildText(
        snapshot,
      ),
      flush: true,
    );

    await jsonFile.writeAsString(
      RecoveryReportFormatter.buildJson(
        snapshot,
      ),
      flush: true,
    );

    return RecoveryReportExportFiles(
      textFile: textFile,
      jsonFile: jsonFile,
    );
  }

  static Future<ShareResult> shareSnapshot(
    RecoveryReportSnapshot snapshot,
  ) async {
    final RecoveryReportExportFiles files =
        await createFiles(snapshot);

    return SharePlus.instance.share(
      ShareParams(
        title: 'BreakWave recovery report',
        subject: 'BreakWave recovery report',
        text:
            'BreakWave recovery report for '
            '${snapshot.range.label}. '
            'The attached files contain only the '
            'sections selected and previewed in BreakWave.',
        files: <XFile>[
          XFile(files.textFile.path),
          XFile(files.jsonFile.path),
        ],
      ),
    );
  }
}
