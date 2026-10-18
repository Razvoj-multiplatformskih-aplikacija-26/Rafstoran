import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'api_client.dart';

final class HttpReservationRepository implements ReservationRepository {
  const HttpReservationRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) async {
    final answer = await _api.get(ApiPaths.reservationsOfGuest(guestId.value));
    return accepted(answer, (json) => [for (final item in objects(json)) _reservation(item)]);
  }

  @override
  Future<Reservation?> find(ReservationId id) async {
    final answer = await _api.get(ApiPaths.reservation(id.value));
    if (answer case ApiRejected(error: NotFound())) return null;
    return accepted(answer, _reservation);
  }

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async {
    final body = NewReservationDto(
      guestId: request.guestId.value,
      start: request.slot.start,
      partySize: request.partySize.value,
      note: request.note?.text,
    );
    return resultOf(await _api.post(ApiPaths.reservations, body: body.toJson()), _reservation);
  }

  @override
  Future<Result<Reservation>> save(Reservation reservation, {required ReservationStatus from}) async {
    final id = reservation.id.value;
    final answer = await switch (reservation.status) {
      Confirmed() => _api.post(ApiPaths.confirmation(id)),
      Cancelled(:final reason) => _api.post(ApiPaths.cancellation(id), body: CancellationDto(reason: reason).toJson()),
      Arrived() => _api.post(ApiPaths.arrival(id)),
      Pending() => throw ArgumentError.value(reservation, 'reservation', 'A pending reservation is created, not saved'),
    };
    return resultOf(answer, _reservation);
  }

  Reservation _reservation(Object? json) => ReservationDto.fromJson(object(json)).toDomain();
}
