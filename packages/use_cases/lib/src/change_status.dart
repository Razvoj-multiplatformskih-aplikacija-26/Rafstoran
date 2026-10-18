import 'package:domain/domain.dart';

import 'ports/reservation_repository.dart';

const _attempts = 3;

Future<Result<Reservation>> changeStatus(
  ReservationRepository reservations,
  ReservationId id, {
  required User by,
  required Result<Reservation> Function(Reservation current) change,
}) async {
  Result<Reservation> outcome = const Failure(NotFound());
  for (var attempt = 0; attempt < _attempts; attempt++) {
    final reservation = await reservations.find(id);
    if (reservation == null || !AccessPolicy.canView(by, reservation)) return const Failure(NotFound());
    switch (change(reservation)) {
      case Failure(:final error):
        return Failure(error);
      case Success(:final value):
        outcome = await reservations.save(value, from: reservation.status);
        if (outcome case Failure(error: InvalidTransition(:final from)) when from != reservation.status) continue;
        return outcome;
    }
  }
  return outcome;
}
