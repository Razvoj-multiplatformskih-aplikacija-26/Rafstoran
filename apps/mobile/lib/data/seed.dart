import 'package:domain/domain.dart';

const currentUserId = UserId('u-guest');

final fakeOpeningHours = OpeningHours({
  DateTime.monday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.tuesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.wednesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.thursday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.friday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.saturday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.sunday: const DayHours(open: LocalTime(12, 0), close: LocalTime(22, 0)),
});

const fakeTables = [
  DiningTable(id: DiningTableId('t-01'), label: 'S1', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-02'), label: 'S2', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-03'), label: 'S3', capacity: 4, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-04'), label: 'S4', capacity: 4, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-05'), label: 'S5', capacity: 6, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-06'), label: 'S6', capacity: 8, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-07'), label: 'T1', capacity: 2, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-08'), label: 'T2', capacity: 4, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-09'), label: 'T3', capacity: 4, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-10'), label: 'T4', capacity: 6, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-11'), label: 'B1', capacity: 4, area: TableArea.garden),
  DiningTable(id: DiningTableId('t-12'), label: 'B2', capacity: 12, area: TableArea.garden),
];

const _waiter = UserId('u-waiter');

List<Reservation> seedReservations(DateTime now) {
  final today = restaurantDay(now);
  Reservation seed({
    required String id,
    UserId? guestId,
    required int dayOffset,
    required int hour,
    required int partySize,
    required String tableId,
    int minute = 0,
    String? note,
    ReservationStatus status = const Pending(),
  }) {
    final day = addDays(today, dayOffset);
    final start = fakeOpeningHours.localToUtc(day.year, day.month, day.day, LocalTime(hour, minute));
    return Reservation(
      id: ReservationId(id),
      guest: AccountGuest(guestId ?? UserId('u-$id')),
      slot: TimeSlot.existing(start),
      partySize: PartySize.parse(partySize).valueOrNull!,
      note: note == null ? null : ReservationNote.parse(note).valueOrNull,
      tableId: DiningTableId(tableId),
      status: status,
      createdAt: start.subtract(const Duration(days: 2)),
    );
  }

  Confirmed confirmed(DateTime start) => Confirmed(confirmedBy: _waiter, at: start.subtract(const Duration(days: 1)));
  final tomorrowEight = fakeOpeningHours.localToUtc(today.year, today.month, today.day + 1, const LocalTime(20, 0));
  final threeDaysAgo = fakeOpeningHours.localToUtc(today.year, today.month, today.day - 3, const LocalTime(19, 42));
  final inThreeDays = fakeOpeningHours.localToUtc(today.year, today.month, today.day + 3, const LocalTime(14, 30));
  final inTenDays = fakeOpeningHours.localToUtc(today.year, today.month, today.day + 10, const LocalTime(16, 0));
  final weekAgo = fakeOpeningHours.localToUtc(today.year, today.month, today.day - 7, const LocalTime(20, 5));
  final monthAgo = fakeOpeningHours.localToUtc(today.year, today.month, today.day - 30, const LocalTime(13, 8));

  return [
    seed(
      id: 'r-1',
      guestId: currentUserId,
      dayOffset: 1,
      hour: 20,
      partySize: 4,
      tableId: 't-03',
      note: 'Sto pored prozora, ako je moguće.',
      status: confirmed(tomorrowEight),
    ),
    seed(id: 'r-2', guestId: currentUserId, dayOffset: 5, hour: 13, partySize: 2, tableId: 't-01'),
    seed(
      id: 'r-3',
      guestId: currentUserId,
      dayOffset: -3,
      hour: 19,
      minute: 30,
      partySize: 6,
      tableId: 't-05',
      note: 'Rođendan, treba nam mesto za tortu.',
      status: Arrived(arrivedAt: threeDaysAgo),
    ),
    seed(
      id: 'r-4',
      guestId: currentUserId,
      dayOffset: -12,
      hour: 21,
      partySize: 3,
      tableId: 't-08',
      status: Cancelled(
        reason: 'Promena plana.',
        cancelledBy: currentUserId,
        at: today.subtract(const Duration(days: 13)),
      ),
    ),
    seed(
      id: 'r-5',
      guestId: currentUserId,
      dayOffset: 2,
      hour: 13,
      partySize: 2,
      tableId: 't-07',
      note: 'Terasa, ako je lepo vreme.',
    ),
    seed(
      id: 'r-6',
      guestId: currentUserId,
      dayOffset: 3,
      hour: 14,
      minute: 30,
      partySize: 5,
      tableId: 't-10',
      status: confirmed(inThreeDays),
    ),
    seed(id: 'r-7', guestId: currentUserId, dayOffset: 8, hour: 12, minute: 30, partySize: 2, tableId: 't-02'),
    seed(
      id: 'r-8',
      guestId: currentUserId,
      dayOffset: 10,
      hour: 16,
      partySize: 8,
      tableId: 't-06',
      note: 'Poslovna večera.',
      status: confirmed(inTenDays),
    ),
    seed(
      id: 'r-9',
      guestId: currentUserId,
      dayOffset: -7,
      hour: 20,
      partySize: 2,
      tableId: 't-01',
      status: NoShow(recordedBy: _waiter, at: weekAgo.add(const Duration(minutes: 40))),
    ),
    seed(
      id: 'r-10',
      guestId: currentUserId,
      dayOffset: -20,
      hour: 19,
      partySize: 4,
      tableId: 't-04',
      status: Cancelled(
        reason: 'Restoran zatvoren zbog privatne proslave.',
        cancelledBy: _waiter,
        at: today.subtract(const Duration(days: 21)),
      ),
    ),
    seed(
      id: 'r-11',
      guestId: currentUserId,
      dayOffset: -30,
      hour: 13,
      partySize: 3,
      tableId: 't-03',
      note: 'Dečija stolica.',
      status: Arrived(arrivedAt: monthAgo),
    ),
    for (var day = 0; day < 14; day++) ...[
      seed(id: 'o-$day-a', dayOffset: day, hour: 19, partySize: 2, tableId: 't-01'),
      seed(id: 'o-$day-b', dayOffset: day, hour: 19, partySize: 2, tableId: 't-02'),
      seed(id: 'o-$day-c', dayOffset: day, hour: 20, partySize: 2, tableId: 't-07'),
      seed(id: 'o-$day-d', dayOffset: day, hour: 20, partySize: 4, tableId: 't-03'),
      seed(id: 'o-$day-e', dayOffset: day, hour: 20, minute: 30, partySize: 4, tableId: 't-04'),
      seed(id: 'o-$day-f', dayOffset: day, hour: 20, minute: 30, partySize: 4, tableId: 't-08'),
      seed(id: 'o-$day-g', dayOffset: day, hour: 20, partySize: 6, tableId: 't-05'),
      seed(id: 'o-$day-h', dayOffset: day, hour: 21, partySize: 4, tableId: 't-09'),
      seed(id: 'o-$day-i', dayOffset: day, hour: 20, partySize: 6, tableId: 't-10'),
      seed(id: 'o-$day-j', dayOffset: day, hour: 20, minute: 30, partySize: 4, tableId: 't-11'),
      seed(id: 'o-$day-k', dayOffset: day, hour: 20, partySize: 8, tableId: 't-06'),
      seed(id: 'o-$day-l', dayOffset: day, hour: 20, partySize: 10, tableId: 't-12'),
    ],
  ];
}
