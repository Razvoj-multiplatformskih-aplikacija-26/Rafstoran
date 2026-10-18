import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/reservation_repository.dart';

final class CancelReservation {
  const CancelReservation({required this.reservations, required this.clock});

  final ReservationRepository reservations;
  final Clock clock;

  Future<Result<Reservation>> call({required ReservationId id, required User by, String reason = ''}) async {
    final reservation = await reservations.find(id);
    if (reservation == null || !AccessPolicy.canView(by, reservation)) return const Failure(NotFound());
    final result = cancelReservation(reservation, by: by, now: clock.now(), reason: reason);
    return switch (result) {
      Failure(:final error) => Failure(error),
      Success(:final value) => await reservations.save(value, from: reservation.status),
    };
  }
}
