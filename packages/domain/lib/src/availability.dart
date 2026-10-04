import 'package:meta/meta.dart';

import 'errors.dart';
import 'reservation/party_size.dart';
import 'reservation/reservation.dart';
import 'restaurant/dining_table.dart';
import 'restaurant/opening_hours.dart';
import 'restaurant/time_slot.dart';
import 'result.dart';

@immutable
final class SlotAvailability {
  const SlotAvailability({required this.slot, required this.freeTables});

  final TimeSlot slot;
  final int freeTables;

  bool get isAvailable => freeTables > 0;

  @override
  bool operator ==(Object other) => other is SlotAvailability && other.slot == slot && other.freeTables == freeTables;

  @override
  int get hashCode => Object.hash(slot, freeTables);

  @override
  String toString() => 'SlotAvailability($slot, $freeTables free)';
}

List<SlotAvailability> availableSlots({
  required OpeningHours openingHours,
  required List<DiningTable> tables,
  required List<Reservation> reservations,
  required DateTime localDay,
  required PartySize partySize,
  required DateTime now,
}) {
  final nowUtc = now.toUtc();
  final starts = openingHours.slotStartsOn(localDay, slotLength: TimeSlot.duration, step: TimeSlot.step);
  return [
    for (final start in starts)
      if (start.isAfter(nowUtc))
        SlotAvailability(
          slot: TimeSlot.existing(start),
          freeTables: freeTablesFor(
            tables: tables,
            reservations: reservations,
            slot: TimeSlot.existing(start),
            partySize: partySize,
          ).length,
        ),
  ];
}

List<DiningTable> freeTablesFor({
  required List<DiningTable> tables,
  required List<Reservation> reservations,
  required TimeSlot slot,
  required PartySize partySize,
}) {
  bool isTaken(DiningTable table) =>
      reservations.any((r) => r.isActive && r.tableId == table.id && r.slot.overlaps(slot));
  return [
    for (final table in tables)
      if (table.capacity >= partySize.value && !isTaken(table)) table,
  ];
}

Result<DiningTable> assignTable({
  required List<DiningTable> tables,
  required List<Reservation> reservations,
  required TimeSlot slot,
  required PartySize partySize,
}) {
  final free = freeTablesFor(tables: tables, reservations: reservations, slot: slot, partySize: partySize);
  if (free.isEmpty) return const Failure(NoTableAvailable());
  free.sort((a, b) {
    final byCapacity = a.capacity.compareTo(b.capacity);
    return byCapacity != 0 ? byCapacity : a.label.compareTo(b.label);
  });
  return Success(free.first);
}
