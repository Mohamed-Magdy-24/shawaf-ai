import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shawaf_ai_mobile/models/models.dart';
import 'package:shawaf_ai_mobile/widgets/site_banner.dart';
import 'package:shawaf_ai_mobile/theme/app_theme.dart';

void main() {
  testWidgets('SiteBanner renders active site and triggers switch callback', (WidgetTester tester) async {
    final sites = [
      Site(id: 'site-1', code: 'BNF', name: 'Beni Suef', timezone: 'Africa/Cairo', isActive: true),
      Site(id: 'site-2', code: 'RNF', name: 'Ramliya Steel', timezone: 'Africa/Cairo', isActive: true),
    ];

    Site? selectedSite;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SiteBanner(
            currentSite: sites[0],
            availableSites: sites,
            onSiteSelected: (s) {
              selectedSite = s;
            },
          ),
        ),
      ),
    );

    // Verify initial site display
    expect(find.text('BNF'), findsOneWidget);
    expect(find.text('Beni Suef'), findsOneWidget);

    // Tap switch button
    await tester.tap(find.text('SWITCH'));
    await tester.pumpAndSettle();

    // Verify bottom sheet modal opened with available sites
    expect(find.text('SWITCH ACTIVE INDUSTRIAL SITE'), findsOneWidget);
    expect(find.text('Ramliya Steel'), findsWidgets);

    // Tap on RNF
    await tester.tap(find.text('Ramliya Steel'));
    await tester.pumpAndSettle();

    expect(selectedSite?.code, 'RNF');
  });
}
