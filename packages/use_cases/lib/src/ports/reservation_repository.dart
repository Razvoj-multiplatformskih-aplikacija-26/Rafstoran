import 'package:domain/domain.dart';

import '../reservation_request.dart';

abstract interface class ReservationRepository {
  Future<List<Reservation>> reservationsOf(UserId guestId);

  Future<Reservation?> find(ReservationId id);

  Future<Result<Reservation>> create(ReservationRequest request);

  Future<Result<Reservation>> save(Reservation reservation, {required ReservationStatus from});
}
