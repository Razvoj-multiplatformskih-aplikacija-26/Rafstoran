import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  setUpAll(initializeTestEnvironment);

  testWidgets('shows progress while a cancellation runs and reports the result', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(appWith(fakeDependencies(latency: const Duration(seconds: 2))));
    await tester.pump(const Duration(seconds: 3));
    await openMyReservations(tester);
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);

    await tester.tap(find.text('Otkaži').first);
    await settle(tester);
    expect(find.text('Otkazati rezervaciju?'), findsOneWidget);

    await tester.tap(find.text('Otkaži rezervaciju'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Otkazivanje…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await settle(tester);
    expect(find.text('Rezervacija je otkazana.'), findsOneWidget);
    expect(find.text('Otkazivanje…'), findsNothing);
    expect(find.text('Otkazana'), findsAtLeastNWidgets(1));
  });

  testWidgets('pull to refresh finishes when nothing has changed', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(appWith(fakeDependencies()));
    await tester.pump(const Duration(seconds: 1));
    await openMyReservations(tester);

    await tester.fling(find.byType(Scrollable).last, const Offset(0, 400), 1000);
    await tester.pump();
    await settle(tester);

    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });
}
