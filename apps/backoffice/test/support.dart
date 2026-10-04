import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:use_cases/use_cases.dart';

final fridayAfternoon = DateTime.utc(2026, 10, 9, 15, 10);

Future<void> initializeTestEnvironment() {
  initializeDomainTimeZones();
  return initializeDateFormatting('sr_Latn');
}

BackofficeDependencies fakeDependencies({DateTime? now, Duration latency = Duration.zero}) =>
    BackofficeDependencies.fake(clock: FixedClock(now ?? fridayAfternoon), latency: latency);

void useWindow(WidgetTester tester, {required double width, required double height}) {
  tester.view.physicalSize = Size(width * 2, height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

Future<void> pumpBackoffice(WidgetTester tester, {BackofficeDependencies? dependencies}) async {
  await tester.pumpWidget(BackofficeApp(dependencies: dependencies ?? fakeDependencies()));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(const Duration(milliseconds: 100));

Finder visible(WidgetTester tester, Finder finder) {
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final screen = Offset.zero & size;
  for (var i = 0; i < finder.evaluate().length; i++) {
    final candidate = finder.at(i);
    if (screen.contains(tester.getCenter(candidate))) return candidate;
  }
  throw StateError('no visible widget matches $finder');
}
