import 'package:domain/domain.dart';

final class DailySchedule {
  const DailySchedule({
    required this.day,
    required this.openingHours,
    required this.tables,
    required this.reservations,
    this.guests = const {},
  });

  final DateTime day;
  final OpeningHours openingHours;
  final List<DiningTable> tables;
  final List<Reservation> reservations;
  final Map<UserId, User> guests;

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

  List<Reservation> reservationsFor(DiningTable table) =>
      reservations.where((r) => r.tableId == table.id && r.isActive).toList();

  Reservation? reservationAt(DiningTable table, DateTime instant) =>
      reservationsFor(table).where((r) => !instant.isBefore(r.slot.start) && instant.isBefore(r.slot.end)).firstOrNull;

  User? guestOf(Reservation reservation) => guests[reservation.guestId];
}
