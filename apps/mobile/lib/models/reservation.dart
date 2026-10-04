import 'reservation_status.dart';
import 'time_slot.dart';

class Reservation {
  Reservation({
    required this.id,
    required this.start,
    required this.partySize,
    required this.createdAt,
    this.note,
    this.status = ReservationStatus.pending,
  });

  final String id;
  final DateTime start;
  final int partySize;
  final String? note;
  final DateTime createdAt;
  ReservationStatus status;

  DateTime get end => start.add(TimeSlot.duration);
}
