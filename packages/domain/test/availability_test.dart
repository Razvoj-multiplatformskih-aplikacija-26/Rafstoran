import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  initializeDomainTimeZones();

  const tables = [
    DiningTable(id: DiningTableId('t-2'), label: 'S1', capacity: 2, area: TableArea.hall),
    DiningTable(id: DiningTableId('t-4'), label: 'S2', capacity: 4, area: TableArea.hall),
    DiningTable(id: DiningTableId('t-6'), label: 'T1', capacity: 6, area: TableArea.terrace),
  ];
  final noon = belgrade(2026, 10, 9, 12, 0);

  Reservation booked(String id, String tableId, int hour, {ReservationStatus status = const Pending()}) =>
      reservationAt(belgrade(2026, 10, 9, hour), id: id, status: status).copyWith(tableId: DiningTableId(tableId));

  test('availableSlots counts free tables with enough seats and ignores cancelled reservations', () {
    final slots = availableSlots(
      openingHours: standardOpeningHours(),
      tables: tables,
      reservations: [
        booked('r-a', 't-4', 20),
        booked(
          'r-b',
          't-2',
          19,
          status: Confirmed(confirmedBy: waiter.id, at: noon),
        ),
        booked(
          'r-c',
          't-6',
          20,
          status: Cancelled(reason: 'otkazano', cancelledBy: guest.id, at: noon),
        ),
      ],
      localDay: DateTime(2026, 10, 9),
      partySize: PartySize.parse(2).valueOrNull!,
      now: noon,
    );
    final at18 = slots.singleWhere((s) => s.slot.start == belgrade(2026, 10, 9, 18));
    final at20 = slots.singleWhere((s) => s.slot.start == belgrade(2026, 10, 9, 20));
    expect(at18.freeTables, 2);
    expect(at20.freeTables, 1);
  });

  test('one guest holds one table at a time, by account or by phone', () {
    final ana = ContactGuest.parse(name: 'Ana', phone: '064 123 4567').valueOrNull!;
    final anaAgain = ContactGuest.parse(name: 'Ana P.', phone: '0641234567').valueOrNull!;
    final at20 = TimeSlot.existing(belgrade(2026, 10, 9, 20));
    final reservations = [
      reservationAt(belgrade(2026, 10, 9, 19), id: 'r-a'),
      reservationAt(belgrade(2026, 10, 9, 21), id: 'r-b', guest: ana),
      reservationAt(
        belgrade(2026, 10, 9, 20),
        id: 'r-c',
        guest: const AccountGuest(UserId('u-ana')),
        status: Cancelled(reason: 'otkazano', cancelledBy: guest.id, at: noon),
      ),
    ];
    expect(guestIsFree(guest: const AccountGuest(UserId('u-guest')), slot: at20, reservations: reservations), isFalse);
    expect(guestIsFree(guest: anaAgain, slot: at20, reservations: reservations), isFalse);
    expect(guestIsFree(guest: const AccountGuest(UserId('u-ana')), slot: at20, reservations: reservations), isTrue);
  });
}
