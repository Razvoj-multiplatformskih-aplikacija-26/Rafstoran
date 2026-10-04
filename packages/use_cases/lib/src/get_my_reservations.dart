import 'package:domain/domain.dart';

import 'ports/reservation_repository.dart';

final class GetMyReservations {
  const GetMyReservations({required this.reservations});

  final ReservationRepository reservations;

  Future<List<Reservation>> call(User guest) async {
    final mine = await reservations.reservationsOf(guest.id);
    return mine..sort((a, b) => a.slot.start.compareTo(b.slot.start));
  }
}
