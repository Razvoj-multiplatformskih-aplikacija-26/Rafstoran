import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/state_views.dart';

import 'support.dart';

void main() {
  setUpAll(initializeTestEnvironment);

  testWidgets('shows loading, failure, empty and loaded', (tester) async {
    usePhoneSize(tester);
    final lateFridayEvening = DateTime.utc(2026, 10, 9, 21, 30);
    final dependencies = fakeDependencies(now: lateFridayEvening, latency: const Duration(seconds: 1));
    dependencies.fakeRestaurant!.failingRequests = 1;

    await tester.pumpWidget(appWith(dependencies));
    await tester.pump();
    expect(find.byType(SlotSkeleton), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Podaci trenutno nisu dostupni.'), findsOneWidget);

    await tester.ensureVisible(find.text('Pokušaj ponovo'));
    await tester.tap(find.text('Pokušaj ponovo'));
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(find.text('Nema termina za izabrani dan.'), findsOneWidget);

    await tester.tap(find.text('Sutra'));
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(find.textContaining('slobodn'), findsWidgets);
  });

  testWidgets('meets the contrast, tap target and label guidelines', (tester) async {
    usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(appWith(fakeDependencies()));
    await settle(tester);

    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
