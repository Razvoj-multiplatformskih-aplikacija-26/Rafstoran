import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/reservation_form_screen.dart';

import 'support.dart';

void main() {
  setUpAll(initializeTestEnvironment);

  testWidgets('shows slots without a login and asks for one only to reserve', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(appWith(fakeDependencies(signedIn: false)));
    await settle(tester);
    expect(find.text('Rezervišite sto'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp(r'^\d\d:\d\d, \d+ slobod')).first);
    await settle(tester);
    await tester.tap(find.text('Rezerviši'));
    await settle(tester);
    expect(find.widgetWithText(FilledButton, 'Prijavi se'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'guest1');
    await tester.enterText(find.byType(TextField).at(1), 'lozinka');
    await tester.tap(find.widgetWithText(FilledButton, 'Prijavi se'));
    await settle(tester);
    expect(find.byType(ReservationFormScreen), findsOneWidget);
  });

  testWidgets('an expired login opens the login over the form, and back returns to the form', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(appWith(fakeDependencies()));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^\d\d:\d\d, \d+ slobod')).first);
    await settle(tester);
    await tester.tap(find.text('Rezerviši'));
    await settle(tester);

    tester.element(find.byType(ReservationFormScreen)).read<SessionBloc>().add(const SessionExpired());
    await settle(tester);
    expect(find.text('Prijava je istekla. Prijavite se ponovo.'), findsOneWidget);

    await tester.tap(find.byTooltip('Nazad'));
    await settle(tester);
    expect(find.text('Potvrdi rezervaciju'), findsOneWidget);
  });
}
