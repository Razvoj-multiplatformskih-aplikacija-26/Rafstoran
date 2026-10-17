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
    for (var i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);

    useWindow(tester, width: 600, height: 900);
    await settle(tester);
    expect(find.byType(ScheduleList), findsOneWidget);
    expect(find.byType(ScheduleGrid), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp(r'^Tamara Pavlović, .*sto S2'))),
      containsSemantics(isSelected: true),
    );

    useWindow(tester, width: 1440, height: 900);
    await settle(tester);
    expect(find.text('Bez glutena.'), findsOneWidget);
  });

  testWidgets('the schedule works from the keyboard alone, from launch to a confirmation', (tester) async {
    useWindow(tester, width: 1440, height: 900);
    await pumpBackoffice(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    for (var i = 0; i < 5; i++) {
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
}
