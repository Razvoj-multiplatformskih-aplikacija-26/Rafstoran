import 'package:meta/meta.dart';

import 'identifiers.dart';
import 'party_size.dart';
import 'reservation_note.dart';
import 'reservation_status.dart';
import 'time_slot.dart';

@immutable
final class Reservation {
  const Reservation({
    required this.id,
    required this.guestId,
    required this.slot,
    required this.partySize,
    required this.createdAt,
    this.note,
    this.tableId,
    this.status = const Pending(),
  });

  final ReservationId id;
  final UserId guestId;
  final TimeSlot slot;
  final PartySize partySize;
  final ReservationNote? note;
  final DiningTableId? tableId;
  final ReservationStatus status;
  final DateTime createdAt;

  bool get isActive => status.isActive;

  Reservation copyWith({ReservationStatus? status, DiningTableId? tableId}) {
    return Reservation(
      id: id,
      guestId: guestId,
      slot: slot,
      partySize: partySize,
      createdAt: createdAt,
      note: note,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Reservation &&
      other.id == id &&
      other.guestId == guestId &&
      other.slot == slot &&
      other.partySize == partySize &&
      other.note == note &&
      other.tableId == tableId &&
      other.status == status &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, guestId, slot, partySize, note, tableId, status, createdAt);

  @override
  String toString() => 'Reservation($id, ${slot.start.toIso8601String()}, $partySize, $status)';
}
