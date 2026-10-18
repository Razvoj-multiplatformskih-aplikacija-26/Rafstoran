import 'package:domain/domain.dart';

import 'clock.dart';
import 'ports/reservation_repository.dart';

final class RecordArrival {
  const RecordArrival({required this.reservations, required this.clock});

  final ReservationRepository reservations;
  final Clock clock;

  Future<Result<Reservation>> call({required ReservationId id, required User by}) async {
    final reservation = await reservations.find(id);
    if (reservation == null) return const Failure(NotFound());
    return switch (recordArrival(reservation, by: by, now: clock.now())) {
      Failure(:final error) => Failure(error),
      Success(:final value) => await reservations.save(value, from: reservation.status),
    };
  }
}
