import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'fake_restaurant.dart';

void main() {
  initializeDomainTimeZones();

  final noon = everyDayNoonToEleven().localToUtc(2026, 10, 9, const LocalTime(12, 0));
  final clock = FixedClock(noon);

  AvailableSlotsBloc build({bool failing = false}) {
    final restaurant = FakeRestaurant(clock: clock, failing: failing);
    return AvailableSlotsBloc(
      getAvailableSlots: GetAvailableSlots(slots: restaurant),
      clock: clock,
    );
  }

  group('AvailableSlotsBloc', () {
    blocTest<AvailableSlotsBloc, AvailableSlotsState>(
      'emits loading then loaded with the slots of the day',
      build: build,
      act: (bloc) => bloc.add(const AvailableSlotsRequested()),
      expect: () => [
        isA<AvailableSlotsLoading>(),
        isA<AvailableSlotsLoaded>().having((s) => s.slots.length, 'slots', 18),
      ],
    );

    blocTest<AvailableSlotsBloc, AvailableSlotsState>(
      'emits loading then failure when the repository throws',
      build: () => build(failing: true),
      act: (bloc) => bloc.add(const AvailableSlotsRequested()),
      expect: () => [isA<AvailableSlotsLoading>(), isA<AvailableSlotsFailure>()],
    );
  });
}
