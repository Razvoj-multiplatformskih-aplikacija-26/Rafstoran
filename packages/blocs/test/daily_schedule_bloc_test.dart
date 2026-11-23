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
  const waiter = User(id: UserId('u-waiter'), name: 'Marija Kostić', role: Role.waiter);

  final pending = Reservation(
    id: const ReservationId('r-1'),
    guest: AccountGuest(guest.id),
    slot: TimeSlot.existing(tonight),
    partySize: PartySize.parse(2).valueOrNull!,
    tableId: const DiningTableId('t-2'),
    createdAt: noon,
  );

  late FakeSchedules schedules;

  DailyScheduleBloc build() {
    final restaurant = FakeRestaurant(clock: clock, reservations: [pending]);
    schedules = FakeSchedules(restaurant);
    final feed = OnlineScheduleFeed(schedules: schedules, clock: clock);
    return DailyScheduleBloc(
      watchDailySchedule: WatchDailySchedule(feed: feed),
      refreshDailySchedule: RefreshDailySchedule(feed: feed),
      confirmReservation: ConfirmReservation(reservations: restaurant, clock: clock),
      recordArrival: RecordArrival(reservations: restaurant, clock: clock),
      recordNoShow: RecordNoShow(reservations: restaurant, clock: clock),
      cancelReservation: CancelReservation(reservations: restaurant, clock: clock),
      clock: clock,
      staff: waiter,
    );
  }

  Future<DailyScheduleLoaded> loaded(DailyScheduleBloc bloc, bool Function(DailyScheduleLoaded state) test) async =>
      await bloc.stream.firstWhere((s) => s is DailyScheduleLoaded && test(s)) as DailyScheduleLoaded;

  test('DailyScheduleBloc keeps the schedule and says why a refresh failed', () async {
    final bloc = build()..add(DailyScheduleRequested(DateTime(2026, 10, 9)));
    final first = await loaded(bloc, (s) => true);
    schedules.failingLoads = 1;
    bloc.add(const DailyScheduleRefreshed());
    final after = await loaded(bloc, (s) => s.refreshFailure != null);
    expect(after.schedule.reservations, [pending]);
    expect(after.refreshedAt, first.refreshedAt);
    expect(after.refreshFailure, isA<RepositoryException>());
    await bloc.close();
  });

  test('DailyScheduleBloc reports a confirmation that succeeded even when the refresh after it fails', () async {
    final bloc = build()..add(DailyScheduleRequested(DateTime(2026, 10, 9)));
    await loaded(bloc, (s) => true);
    bloc.add(ScheduleReservationSelected(pending.id));
    schedules.failingLoads = 1;
    bloc.add(ScheduleConfirmationRequested(pending.id));
    final busy = await loaded(bloc, (s) => s.isBusy);
    expect(busy.actionsFor(pending), {ScheduleAction.confirm, ScheduleAction.cancel});
    final after = await loaded(bloc, (s) => s.refreshFailure != null);
    expect(after.isBusy, isFalse);
    expect(after.selectedId, pending.id);
    expect(after.notice, isA<ScheduleActionSucceeded>());
    await bloc.close();
  });

  test('DailyScheduleBloc shows why the server refused an action and the status from the server', () async {
    final bloc = build()..add(DailyScheduleRequested(DateTime(2026, 10, 9)));
    await loaded(bloc, (s) => true);
    schedules.restaurant.reservations[0] = pending.copyWith(
      status: Cancelled(reason: 'Promena plana.', cancelledBy: guest.id, at: noon),
    );
    bloc.add(ScheduleConfirmationRequested(pending.id));
    final after = await loaded(bloc, (s) => s.schedule.reservations.single.status is Cancelled);
    expect(after.notice, isA<ScheduleActionRejected>());
    await bloc.close();
  });

  test('DailyScheduleBloc shows a failure when a day that was never loaded cannot be refreshed', () async {
    final bloc = build();
    schedules.failingLoads = 1;
    bloc.add(DailyScheduleRequested(DateTime(2026, 10, 9)));
    final failure = await bloc.stream.firstWhere((s) => s is DailyScheduleFailure);
    expect((failure as DailyScheduleFailure).cause, isA<RepositoryException>());
    await bloc.close();
  });
}
