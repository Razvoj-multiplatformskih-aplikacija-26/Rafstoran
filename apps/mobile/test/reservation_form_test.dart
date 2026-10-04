import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/reservation_form_screen.dart';

import 'support.dart';

void main() {
  setUpAll(initializeTestEnvironment);

  Widget buildForm() {
    final dependencies = fakeDependencies();
    final availability = SlotAvailability(slot: TimeSlot.existing(DateTime.utc(2026, 10, 9, 18)), freeTables: 3);
    final partySize = PartySize.parse(2).valueOrNull!;
    return localized(
      BlocProvider(
        create: (_) => ReservationFormBloc(
          createReservation: dependencies.createReservation,
          guest: dependencies.user,
          slot: availability.slot,
          partySize: partySize,
        ),
        child: ReservationFormScreen(selection: (availability: availability, partySize: partySize)),
      ),
    );
  }

  const tooLongMessage = 'Napomena može imati najviše 200 znakova.';

  testWidgets('shows an error for a note longer than 200 characters', (tester) async {
    await tester.pumpWidget(buildForm());
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'đ' * 201);
    await settle(tester);

    expect(find.text(tooLongMessage), findsOneWidget);
    expect(find.text('201/200'), findsOneWidget);
  });

  testWidgets('accepts a note of exactly 200 characters', (tester) async {
    await tester.pumpWidget(buildForm());
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'đ' * 200);
    await settle(tester);

    expect(find.text(tooLongMessage), findsNothing);
    expect(find.text('200/200'), findsOneWidget);
  });
}
