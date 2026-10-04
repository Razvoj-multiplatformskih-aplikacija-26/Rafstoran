import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/time_slot.dart';
import 'package:mobile/screens/reservation_form_screen.dart';
import 'package:mobile/theme/theme.dart';

void main() {
  Widget buildForm() {
    return MaterialApp(
      theme: RafTheme.light(),
      locale: const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      supportedLocales: const [Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: ReservationFormScreen(
        selection: (slot: TimeSlot(start: DateTime(2026, 10, 9, 20), freeTables: 3), partySize: 2),
      ),
    );
  }

  const tooLongMessage = 'Napomena može imati najviše 200 znakova.';

  testWidgets('shows an error for a note longer than 200 characters', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'đ' * 201);
    await tester.pump();

    expect(find.text(tooLongMessage), findsOneWidget);
    expect(find.text('201/200'), findsOneWidget);
  });

  testWidgets('accepts a note of exactly 200 characters', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'đ' * 200);
    await tester.pump();

    expect(find.text(tooLongMessage), findsNothing);
    expect(find.text('200/200'), findsOneWidget);
  });
}
