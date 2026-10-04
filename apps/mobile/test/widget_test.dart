import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  setUpAll(initializeTestEnvironment);

  testWidgets('shows free slots on the home screen', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(appWith(fakeDependencies()));
    await settle(tester);

    expect(find.text('Rezervišite sto'), findsOneWidget);
    expect(find.text('Danas'), findsOneWidget);
    expect(find.textContaining('slobodn'), findsWidgets);
  });
}
