import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/screens/my_reservations_screen.dart';
import 'package:mobile/theme/theme.dart';

void main() {
  testWidgets('home screen is readable with a screen reader', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const RafstoranApp());
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Rezervišite sto')),
      matchesSemantics(label: 'Rezervišite sto', isHeader: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Broj osoba')),
      matchesSemantics(
        label: 'Broj osoba',
        value: '2 osobe',
        increasedValue: '3 osobe',
        decreasedValue: '1 osoba',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    final slotButtons = find.bySemanticsLabel(RegExp(r'^\d\d:\d\d, \d+ slobod'));
    expect(slotButtons, findsWidgets);
    expect(
      tester.getSemantics(slotButtons.first),
      matchesSemantics(
        label: tester.getSemantics(slotButtons.first).label,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('cancel buttons say which reservation they cancel', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: RafTheme.light(),
        locale: RafstoranApp.locale,
        supportedLocales: const [RafstoranApp.locale],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const MyReservationsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final cancelButtons = find.bySemanticsLabel(RegExp(r'^Otkaži rezervaciju, .+ u \d\d:\d\d$'));
    expect(cancelButtons, findsWidgets);
    expect(
      tester.getSemantics(cancelButtons.first),
      matchesSemantics(label: tester.getSemantics(cancelButtons.first).label, isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });
}
