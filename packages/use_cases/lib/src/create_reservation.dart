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
    required User by,
    ReservationGuest? guest,
    required DateTime start,
    required PartySize partySize,
    ReservationNote? note,
  }) async {
    final forGuest = guest ?? AccountGuest(by.id);
    if (!AccessPolicy.canCreateReservation(by, guest: forGuest)) return const Failure(NotAllowed());
    final now = clock.now();
    final openingHours = await slots.openingHours();
    final slot = TimeSlot.parse(start, now: now, openingHours: openingHours);
    return switch (slot) {
      Failure(:final error) => Failure(error),
      Success(:final value) when !mayBook(value, by: by, now: now) => Failure(
        TooSoonToBook(notice: bookingNoticeFor(by)),
      ),
      Success(:final value) => reservations.create(
        ReservationRequest(
          guest: forGuest,
          slot: value,
          partySize: partySize,
          status: initialStatus(by: by, now: now),
          note: note,
          enteredBy: forGuest.isAccount(by.id) ? null : by.id,
        ),
      ),
    };
  }
}
