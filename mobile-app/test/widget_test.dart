import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shawaf_ai_mobile/models/models.dart';
import 'package:shawaf_ai_mobile/core/theme/app_theme.dart';
import 'package:shawaf_ai_mobile/features/alerts/presentation/widgets/alert_card_widget.dart';
import 'package:shawaf_ai_mobile/core/widgets/degraded_banner.dart';
import 'package:shawaf_ai_mobile/core/widgets/severity_badge.dart';
import 'package:shawaf_ai_mobile/core/widgets/site_switcher_banner.dart';

void main() {
  group('Widget Tests (BNF & RNF Strict Naming)', () {
    testWidgets('SiteSwitcherBanner renders BNF and RNF chips and triggers selection', (WidgetTester tester) async {
      const sites = [
        Site(id: 'site-1', code: 'BNF', name: 'BNF', timezone: 'Africa/Cairo', isActive: true),
        Site(id: 'site-2', code: 'RNF', name: 'RNF', timezone: 'Africa/Cairo', isActive: true),
      ];

      Site? selectedSite;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SiteSwitcherBanner(
              currentSite: sites[0],
              availableSites: sites,
              onSiteSelected: (s) {
                selectedSite = s;
              },
            ),
          ),
        ),
      );

      // Verify active site code and name (strictly BNF)
      expect(find.text('BNF'), findsWidgets);
      expect(find.text('RNF'), findsOneWidget);

      // Tap on RNF chip
      await tester.tap(find.text('RNF'));
      await tester.pumpAndSettle();

      expect(selectedSite?.code, 'RNF');
      expect(selectedSite?.name, 'RNF');
    });

    testWidgets('SeverityBadge renders SEV1 badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeverityBadge(severity: 'SEV1'),
          ),
        ),
      );

      expect(find.text('SEV1'), findsOneWidget);
    });

    testWidgets('DegradedBanner displays error message and handles retry', (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DegradedBanner(
              message: 'OFFLINE (ADR-016): Connection dropped',
              isOffline: true,
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('OFFLINE (ADR-016): Connection dropped'), findsOneWidget);
      await tester.tap(find.text('RETRY'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('AlertCardWidget displays alert information and triggers tap callback', (WidgetTester tester) async {
      bool tapped = false;
      final alert = SurveillanceEvent(
        id: 'evt-001',
        siteId: 'site-1',
        cameraId: 'bnf_cam_01',
        zoneId: 'bnf_zone_01',
        eventType: 'ZONE_INTRUSION',
        severity: 'SEV1',
        state: 'NEW',
        confidence: 0.96,
        trackId: 104,
        occurredAt: DateTime.parse('2026-11-16T12:00:00Z'),
        metadata: const {'zone_name': 'Danger Perimeter'},
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AlertCardWidget(
              alert: alert,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('ZONE INTRUSION'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('bnf_cam_01'), findsOneWidget);

      await tester.tap(find.byType(AlertCardWidget));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
