import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'fake_restaurant.dart';

final class FakeSchedules implements ScheduleRepository {
  FakeSchedules(this.restaurant);

  final FakeRestaurant restaurant;
  int failingLoads = 0;

  @override
  Future<DailySchedule> scheduleFor(DateTime localDay) async {
    if (failingLoads > 0) {
      failingLoads--;
      throw const RepositoryException('simulated outage');
    }
    return DailySchedule(
      day: localDay,
      openingHours: everyDayNoonToEleven(),
      tables: tables,
      reservations: [...restaurant.reservations],
    );
  }
}

void main() {
  initializeDomainTimeZones();

  final hours = everyDayNoonToEleven();
  final noon = hours.localToUtc(2026, 10, 9, const LocalTime(12, 0));
  final tonight = hours.localToUtc(2026, 10, 9, const LocalTime(20, 0));
  final clock = FixedClock(noon);
  const waiter = User(id: UserId('u-waiter'), username: 'Konobar', role: Role.waiter);

  final pending = Reservation(
    id: const ReservationId('r-1'),
    guestId: guest.id,
    slot: TimeSlot.existing(tonight),
    partySize: PartySize.parse(2).valueOrNull!,
    tableId: const DiningTableId('t-2'),
    createdAt: noon,
  );

  late FakeSchedules schedules;

  DailyScheduleBloc build() {
    final restaurant = FakeRestaurant(clock: clock, reservations: [pending]);
    schedules = FakeSchedules(restaurant);
    return DailyScheduleBloc(
      getDailySchedule: GetDailySchedule(schedules: schedules),
      confirmReservation: ConfirmReservation(reservations: restaurant, clock: clock),
      recordArrival: RecordArrival(reservations: restaurant, clock: clock),
      cancelReservation: CancelReservation(reservations: restaurant, clock: clock),
      clock: clock,
      staff: waiter,
    );
  }

  blocTest<DailyScheduleBloc, DailyScheduleState>(
    'DailyScheduleBloc reports a failed reload after a confirmation and is no longer busy',
    build: build,
    act: (bloc) async {
      bloc.add(DailyScheduleRequested(DateTime(2026, 10, 9)));
      await bloc.stream.firstWhere((s) => s is DailyScheduleLoaded);
      bloc.add(ScheduleReservationSelected(pending.id));
      schedules.failingLoads = 1;
      bloc.add(ScheduleConfirmationRequested(pending.id));
    },
    skip: 3,
    expect: () => [
      isA<DailyScheduleLoaded>().having((s) => s.inFlightId, 'in flight', pending.id),
      isA<DailyScheduleLoaded>()
          .having((s) => s.isBusy, 'busy', isFalse)
          .having((s) => s.selectedId, 'selected', pending.id)
          .having((s) => s.notice, 'notice', isA<ScheduleActionFailed>()),
    ],
  );
}
