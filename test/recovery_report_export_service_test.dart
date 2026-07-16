import 'package:flutter_test/flutter_test.dart';

import 'package:breakwave/features/recovery_report/data/recovery_report_export_service.dart';
import 'package:breakwave/features/recovery_report/domain/recovery_report_selection.dart';

void main() {
  test(
    'timestamp token is stable and zero padded',
    () {
      expect(
        RecoveryReportExportService.timestampToken(
          DateTime(2026, 7, 5, 8, 3, 9),
        ),
        '20260705_080309',
      );
    },
  );

  test(
    'file stem is neutral and contains no personal data',
    () {
      final String stem =
          RecoveryReportExportService.fileStemFor(
        range: RecoveryReportRange.last90Days,
        generatedAt:
            DateTime(2026, 7, 15, 20, 39, 7),
      );

      expect(
        stem,
        'breakwave_recovery_report_90d_'
        '20260715_203907',
      );

      expect(
        stem,
        isNot(contains('email')),
      );

      expect(
        stem,
        isNot(contains('phone')),
      );

      expect(
        stem,
        isNot(contains('support')),
      );
    },
  );
}
