import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surveillance_client/features/reports/domain/daily_report.dart';
import 'package:surveillance_client/features/reports/presentation/widgets/daily_report_card.dart';

void main() {
  group('DailyReport Domain & Presentation Tests (DEC-07)', () {
    test('DailyReport calculates compliance correctly', () {
      const compliantReport = DailyReport(
        siteId: 'BNF',
        reportDate: '2026-11-18',
        timezone: 'Africa/Cairo',
        totalIncidents: 10,
        criticalIncidents: 1,
        warningIncidents: 2,
        resolvedIncidents: 9,
        dismissedIncidents: 1,
        avgAckSeconds: 42.0,
        safetyCompliancePercent: 88.5,
      );

      expect(compliantReport.isCompliant, isTrue);

      const nonCompliantReport = DailyReport(
        siteId: 'BNF',
        reportDate: '2026-11-18',
        timezone: 'Africa/Cairo',
        totalIncidents: 25,
        criticalIncidents: 5,
        warningIncidents: 8,
        resolvedIncidents: 15,
        dismissedIncidents: 2,
        avgAckSeconds: 120.0,
        safetyCompliancePercent: 72.0,
      );

      expect(nonCompliantReport.isCompliant, isFalse);
    });

    testWidgets('DailyReportCard renders Cairo timezone badge, metrics and compliance', (tester) async {
      const report = DailyReport(
        siteId: 'BNF',
        reportDate: '2026-11-18',
        timezone: 'Africa/Cairo',
        totalIncidents: 8,
        criticalIncidents: 0,
        warningIncidents: 2,
        resolvedIncidents: 8,
        dismissedIncidents: 0,
        avgAckSeconds: 35.0,
        safetyCompliancePercent: 94.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DailyReportCard(report: report),
          ),
        ),
      );

      expect(find.text('DAILY SAFETY SHIFT REPORT'), findsOneWidget);
      expect(find.text('Africa/Cairo (23:59:59)'), findsOneWidget);
      expect(find.text('94.0%'), findsOneWidget);
      expect(find.text('COMPLIANT (Target >= 85%)'), findsOneWidget);
      expect(find.text('35s'), findsOneWidget);
    });
  });
}
