import 'package:backoffice/widgets/schedule_grid.dart';
import 'package:backoffice/widgets/schedule_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  setUpAll(initializeTestEnvironment);

  testWidgets('the C shortcut confirms the selected reservation', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    await pumpBackoffice(tester);
    expect(find.byType(ScheduleGrid), findsOneWidget);

    await tester.tap(visible(tester, find.bySemanticsLabel(RegExp(r'Na čekanju$'))));
    await settle(tester);
    expect(find.text('Potvrdi'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await settle(tester);

    expect(find.text('Rezervacija je potvrđena.'), findsOneWidget);
    expect(find.text('Potvrdi'), findsNothing);
  });

  testWidgets('the X shortcut cancels the selected reservation with a reason', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    await pumpBackoffice(tester);

    await tester.tap(visible(tester, find.bySemanticsLabel(RegExp(r'Na čekanju$'))));
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
    await settle(tester);
    expect(find.text('Otkazati rezervaciju?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Gost se nije javio.');
    await tester.tap(find.text('Otkaži rezervaciju'));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Rezervacija je otkazana.'), findsOneWidget);
    expect(find.textContaining('Gost se nije javio.'), findsOneWidget);
  });

  testWidgets('a window narrower than 840 pixels shows a list and keeps the selection', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    await pumpBackoffice(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);

    useWindow(tester, width: 600, height: 900);
    await settle(tester);
    expect(find.byType(ScheduleList), findsOneWidget);
    expect(find.byType(ScheduleGrid), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp(r'^Jelena Nikolić, .*sto S2'))),
      isSemantics(isSelected: true),
    );

    useWindow(tester, width: 1440, height: 900);
    await settle(tester);
    expect(find.text('Bez glutena.'), findsOneWidget);
  });

  testWidgets('the schedule works from the keyboard alone, from launch to a confirmation', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    await pumpBackoffice(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
    expect(find.text('Bez glutena.'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await settle(tester);
    expect(find.text('Rezervacija je potvrđena.'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    for (var i = 0; i < 15; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await settle(tester);
    expect(visible(tester, find.text('22:00')), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await settle(tester);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'schedule grid');
  });

  testWidgets('a link to a reservation opens it once the day has loaded', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/schedule/2026-10-09?reservation=s-111';
    addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
    await pumpBackoffice(tester);

    expect(find.text('Bez glutena.'), findsOneWidget);
  });

  testWidgets('staff enter a phone reservation for a guest without an account, confirmed at once', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    await pumpBackoffice(tester);

    await tester.tap(find.text('Nova rezervacija'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Gost'), 'Petra Ilić');
    await tester.enterText(find.widgetWithText(TextField, 'Telefon'), '064 555 0202');
    await settle(tester);
    await tester.tap(find.byType(ChoiceChip).last);
    await settle(tester);
    await tester.tap(find.text('Dalje'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Rezervisano telefonom.');
    await tester.tap(find.text('Sačuvaj'));
    await settle(tester);

    expect(find.text('Rezervacija je sačuvana.'), findsOneWidget);
    expect(find.text('Petra Ilić'), findsWidgets);
    expect(find.text('0645550202'), findsOneWidget);
    expect(find.text('Potvrđena'), findsOneWidget);
    expect(find.text('Marija Kostić'), findsOneWidget);
  });
}
