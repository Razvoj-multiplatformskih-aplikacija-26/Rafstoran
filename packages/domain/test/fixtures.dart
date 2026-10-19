import 'package:domain/domain.dart';

OpeningHours standardOpeningHours() => OpeningHours({
  DateTime.monday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.tuesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.wednesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.thursday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.friday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.saturday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.sunday: const DayHours(open: LocalTime(12, 0), close: LocalTime(22, 0)),
});

DateTime belgrade(int year, int month, int day, int hour, [int minute = 0]) =>
    standardOpeningHours().localToUtc(year, month, day, LocalTime(hour, minute));

const guest = User(id: UserId('u-guest'), username: 'guest1', role: Role.guest);
const waiter = User(id: UserId('u-waiter'), username: 'waiter1', role: Role.waiter);

Reservation reservationAt(
  DateTime start, {
  ReservationGuest guest = const AccountGuest(UserId('u-guest')),
  ReservationStatus status = const Pending(),
  int partySize = 2,
  String id = 'r-1',
}) {
  return Reservation(
    id: ReservationId(id),
    guest: guest,
    slot: TimeSlot.existing(start),
    partySize: PartySize.parse(partySize).valueOrNull!,
    status: status,
    createdAt: start.subtract(const Duration(days: 1)),
  );
}
