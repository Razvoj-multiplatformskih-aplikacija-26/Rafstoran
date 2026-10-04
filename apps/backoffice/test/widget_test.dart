import 'package:backoffice/app.dart';
import 'package:backoffice/dependencies.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:use_cases/use_cases.dart';

void main() {
  setUpAll(() {
    initializeDomainTimeZones();
    return initializeDateFormatting('sr_Latn');
  });

  testWidgets('shows the schedule of today', (tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final dependencies = BackofficeDependencies.fake(
      clock: FixedClock(DateTime.utc(2026, 10, 9, 11)),
      latency: Duration.zero,
    );
    await tester.pumpWidget(BackofficeApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.text('Petak, 9. oktobar'), findsOneWidget);
    expect(find.text('S1'), findsOneWidget);
  });
}
