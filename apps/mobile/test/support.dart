import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/theme/theme.dart';
import 'package:use_cases/use_cases.dart';

final fridayNoon = DateTime.utc(2026, 10, 9, 10);

Future<void> initializeTestEnvironment() async {
  initializeDomainTimeZones();
}

AppDependencies fakeDependencies({DateTime? now, Duration latency = Duration.zero}) =>
    AppDependencies.fake(clock: FixedClock(now ?? fridayNoon), latency: latency);

Widget appWith(AppDependencies dependencies) => RafstoranApp(dependencies: dependencies);

Widget localized(Widget child) => MaterialApp(
  theme: RafTheme.light(),
  locale: RafstoranApp.locale,
  supportedLocales: const [RafstoranApp.locale],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: child,
);

Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(const Duration(milliseconds: 100));

void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

Future<void> openMyReservations(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Moje rezervacije')));
  await settle(tester);
}
