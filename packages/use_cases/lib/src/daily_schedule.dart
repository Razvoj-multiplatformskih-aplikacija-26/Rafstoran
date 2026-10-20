import 'package:collection/collection.dart';
import 'package:domain/domain.dart';

final class DailySchedule {
  const DailySchedule({
    required this.day,
    required this.openingHours,
    required this.tables,
    required this.reservations,
    this.guests = const {},
    this.staff = const {},
  });

  final DateTime day;
  final OpeningHours openingHours;
  final List<DiningTable> tables;
  final List<Reservation> reservations;
  final Map<UserId, User> guests;
  final Map<UserId, User> staff;

  DayHours? get hours => openingHours.forWeekday(day.weekday);

  List<DateTime> get slotStarts => openingHours.slotStartsOn(day, slotLength: TimeSlot.duration, step: TimeSlot.step);

  List<DateTime> get halfHours {
    final hours = this.hours;
    if (hours == null) return const [];
    final starts = <DateTime>[];
    for (var minutes = hours.open.minutesSinceMidnight; minutes < hours.close.minutesSinceMidnight; minutes += 30) {
      starts.add(openingHours.localToUtc(day.year, day.month, day.day, LocalTime(minutes ~/ 60, minutes % 60)));
    }
    return starts;
  }

  List<Reservation> get activeReservations =>
      reservations.where((r) => r.isActive).toList()..sort((a, b) => a.slot.start.compareTo(b.slot.start));

  List<Reservation> reservationsFor(DiningTable table) =>
      activeReservations.where((r) => r.tableId == table.id).toList();

  Reservation? reservationAt(DiningTable table, DateTime instant) =>
      reservationsFor(table).where((r) => !instant.isBefore(r.slot.start) && instant.isBefore(r.slot.end)).firstOrNull;

  String? guestNameOf(Reservation reservation) => switch (reservation.guest) {
    AccountGuest(:final userId) => guests[userId]?.username,
    ContactGuest(:final name) => name.text,
  };

  User? enteredByOf(Reservation reservation) => staff[reservation.enteredBy];

  @override
  bool operator ==(Object other) =>
      other is DailySchedule &&
      other.day == day &&
      other.hours == hours &&
      const ListEquality<DiningTable>().equals(other.tables, tables) &&
      const ListEquality<Reservation>().equals(other.reservations, reservations) &&
      const MapEquality<UserId, User>().equals(other.guests, guests) &&
      const MapEquality<UserId, User>().equals(other.staff, staff);

  @override
  int get hashCode => Object.hash(day, hours, Object.hashAll(tables), Object.hashAll(reservations), guests.length);
}
