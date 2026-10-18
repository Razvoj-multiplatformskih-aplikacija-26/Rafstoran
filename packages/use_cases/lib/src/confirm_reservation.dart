import 'package:domain/domain.dart';

import 'change_status.dart';
import 'clock.dart';
import 'ports/reservation_repository.dart';

final class ConfirmReservation {
  const ConfirmReservation({required this.reservations, required this.clock});

  final ReservationRepository reservations;
  final Clock clock;

  Future<Result<Reservation>> call({required ReservationId id, required User by}) => changeStatus(
    reservations,
    id,
    by: by,
    change: (reservation) => confirmReservation(reservation, by: by, now: clock.now()),
  );
}
