import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/models.dart';
import 'package:mobile_app/widgets/site_banner.dart';
import 'package:mobile_app/theme/app_theme.dart';

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
    expect(find.text('SELECT ACTIVE FACILITY'), findsOneWidget);
    expect(find.text('RNF (Ramliya Steel)'), findsOneWidget);

    // Tap on RNF
    await tester.tap(find.text('RNF (Ramliya Steel)'));
    await tester.pumpAndSettle();

    expect(selectedSite?.code, 'RNF');
  });
}
