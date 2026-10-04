import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/reservation_repository.dart';
import 'ports/slot_repository.dart';
import 'reservation_request.dart';

final class CreateReservation {
  const CreateReservation({required this.reservations, required this.slots, required this.clock});

  final ReservationRepository reservations;
  final SlotRepository slots;
  final Clock clock;

  Future<Result<Reservation>> call({
    required User guest,
    required DateTime start,
    required PartySize partySize,
    ReservationNote? note,
  }) async {
    if (!AccessPolicy.canCreateReservation(guest)) return const Failure(NotAllowed());
    final openingHours = await slots.openingHours();
    final slot = TimeSlot.parse(start, now: clock.now(), openingHours: openingHours);
    return switch (slot) {
      Failure(:final error) => Failure(error),
      Success(:final value) => reservations.create(
        ReservationRequest(guestId: guest.id, slot: value, partySize: partySize, note: note),
      ),
    };
  }
}
