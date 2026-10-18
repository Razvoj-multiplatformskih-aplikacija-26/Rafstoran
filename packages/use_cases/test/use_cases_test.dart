import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

import 'in_memory_fakes.dart';

void main() {
  initializeDomainTimeZones();

  final hours = standardOpeningHours();
  final noon = hours.localToUtc(2026, 10, 9, const LocalTime(12, 0));
  final tonight = hours.localToUtc(2026, 10, 9, const LocalTime(20, 0));
  final two = PartySize.parse(2).valueOrNull!;

  late InMemoryRestaurant restaurant;
  late CreateReservation create;

  setUp(() {
    restaurant = InMemoryRestaurant(clock: FixedClock(noon));
    create = CreateReservation(reservations: restaurant, slots: restaurant, clock: FixedClock(noon));
  });

  test('CreateReservation stores a valid request with the smallest free table', () async {
    final result = await create(by: guest, start: tonight, partySize: two);
    final reservation = result.valueOrNull!;
    expect(reservation.tableId, const DiningTableId('t-2'));
    expect(reservation.status, const Pending());
    expect(restaurant.reservations, [reservation]);
  });

  test('CancelReservation decides the two-hour window with the injected clock, not the wall clock', () async {
    final created = (await create(by: guest, start: tonight, partySize: two)).valueOrNull!;
    final oneMinuteLate = FixedClock(tonight.subtract(const Duration(hours: 1, minutes: 59)));
    final exactlyTwoHours = FixedClock(tonight.subtract(const Duration(hours: 2)));

    final tooLate = CancelReservation(reservations: restaurant, clock: oneMinuteLate);
    expect(await tooLate(id: created.id, by: guest), const Failure<Reservation>(CancellationTooLate()));

    final inTime = CancelReservation(reservations: restaurant, clock: exactlyTwoHours);
    expect((await inTime(id: created.id, by: guest)).valueOrNull?.status, isA<Cancelled>());
    expect((await restaurant.find(created.id))?.status, isA<Cancelled>());
  });

  test('two daily schedules built from the same data are equal', () async {
    await create(by: guest, start: tonight, partySize: two);
    DailySchedule build() => DailySchedule(
      day: DateTime(2026, 10, 9),
      openingHours: standardOpeningHours(),
      tables: [...tables],
      reservations: [...restaurant.reservations],
    );
    expect(build(), build());
    expect(build().hashCode, build().hashCode);
  });

  test('staff create a reservation for a guest and are recorded as the ones who entered it', () async {
    const waiter = User(id: UserId('u-waiter'), username: 'Konobar', role: Role.waiter);
    final reservation = (await create(by: waiter, forGuest: guest.id, start: tonight, partySize: two)).valueOrNull!;
    expect(reservation.guestId, guest.id);
    expect(reservation.enteredBy, waiter.id);
  });

  test('a guest creates reservations only for themselves', () async {
    final own = (await create(by: guest, start: tonight, partySize: two)).valueOrNull!;
    expect(own.enteredBy, isNull);
    expect(
      await create(by: guest, forGuest: const UserId('u-other'), start: tonight, partySize: two),
      const Failure<Reservation>(NotAllowed()),
    );
  });
}
