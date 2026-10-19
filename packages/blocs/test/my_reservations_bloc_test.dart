import 'package:bloc_test/bloc_test.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'fake_restaurant.dart';

void main() {
  initializeDomainTimeZones();

  final hours = everyDayNoonToEleven();
  final noon = hours.localToUtc(2026, 10, 9, const LocalTime(12, 0));
  final tonight = hours.localToUtc(2026, 10, 9, const LocalTime(20, 0));
  final clock = FixedClock(noon);

  final reservation = Reservation(
    id: const ReservationId('r-1'),
    guest: AccountGuest(guest.id),
    slot: TimeSlot.existing(tonight),
    partySize: PartySize.parse(2).valueOrNull!,
    tableId: const DiningTableId('t-2'),
    createdAt: noon,
  );

  blocTest<MyReservationsBloc, MyReservationsState>(
    'MyReservationsBloc marks the reservation in flight, cancels it and reports it in the reloaded state',
    build: () {
      final restaurant = FakeRestaurant(clock: clock, reservations: [reservation]);
      return MyReservationsBloc(
        getMyReservations: GetMyReservations(reservations: restaurant),
        cancelReservation: CancelReservation(reservations: restaurant, clock: clock),
        clock: clock,
        guest: guest,
      );
    },
    act: (bloc) => bloc
      ..add(const MyReservationsRequested())
      ..add(const ReservationCancellationRequested(ReservationId('r-1'), reason: 'Promena plana.')),
    skip: 2,
    expect: () => [
      isA<MyReservationsLoaded>().having((s) => s.cancellingId, 'cancelling', const ReservationId('r-1')),
      isA<MyReservationsLoaded>()
          .having((s) => s.upcoming.single.status, 'status', isA<Cancelled>())
          .having((s) => s.notice, 'notice', isA<ReservationCancelled>())
          .having((s) => s.cancellingId, 'cancelling', isNull),
    ],
  );
}
