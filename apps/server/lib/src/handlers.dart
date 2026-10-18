import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'http.dart';
import 'postgres_restaurant.dart';
import 'sessions.dart';

final class RestaurantHandlers {
  RestaurantHandlers({required this.restaurant, required Clock clock})
    : _getAvailableSlots = GetAvailableSlots(slots: restaurant, clock: clock),
      _getDailySchedule = GetDailySchedule(schedules: restaurant),
      _createReservation = CreateReservation(reservations: restaurant, slots: restaurant, clock: clock),
      _confirmReservation = ConfirmReservation(reservations: restaurant, clock: clock),
      _cancelReservation = CancelReservation(reservations: restaurant, clock: clock),
      _recordArrival = RecordArrival(reservations: restaurant, clock: clock),
      _recordNoShow = RecordNoShow(reservations: restaurant, clock: clock);

  final PostgresRestaurant restaurant;
  final GetAvailableSlots _getAvailableSlots;
  final GetDailySchedule _getDailySchedule;
  final CreateReservation _createReservation;
  final ConfirmReservation _confirmReservation;
  final CancelReservation _cancelReservation;
  final RecordArrival _recordArrival;
  final RecordNoShow _recordNoShow;

  Future<Response> openingHours(Request request) async => json(200, (await restaurant.openingHours()).toDto().toJson());

  Future<Response> slots(Request request) async {
    final actor = currentSession[request]?.user;
    final day = dayFromJson(_query(request, ApiQuery.day));
    final partySize = PartySize.parse(int.parse(_query(request, ApiQuery.partySize)));
    if (partySize case Failure(:final error)) return problem(error);
    final slots = await _getAvailableSlots(by: actor, localDay: day, partySize: partySize.valueOrNull!);
    return json(200, [for (final slot in slots) slot.toDto().toJson()]);
  }

  Future<Response> schedule(Request request) async {
    if (!_actor(request).role.isStaff) return problem(const NotAllowed());
    final schedule = await _getDailySchedule(dayFromJson(_query(request, ApiQuery.day)));
    return json(200, schedule.toDto().toJson());
  }

  Future<Response> reservationsOfGuest(Request request) async {
    final actor = _actor(request);
    final reservations = await restaurant.reservationsOf(UserId(request.rawPathParameters[#guestId]!));
    return json(200, [
      for (final reservation in reservations)
        if (AccessPolicy.canView(actor, reservation)) reservation.toDto().toJson(),
    ]);
  }

  Future<Response> find(Request request) async {
    final reservation = await restaurant.find(ReservationId(request.rawPathParameters[#id]!));
    if (reservation == null || !AccessPolicy.canView(_actor(request), reservation)) return problem(const NotFound());
    return json(200, reservation.toDto().toJson());
  }

  Future<Response> create(Request request) async {
    final actor = _actor(request);
    final body = NewReservationDto.fromJson(await readObject(request));
    final guest = switch (body.guest) {
      null => Success<ReservationGuest>(AccountGuest(actor.id)),
      final dto => dto.toDomain(),
    };
    if (guest case Failure(:final error)) return problem(error);
    if (guest.valueOrNull case AccountGuest(:final userId)) {
      final account = await restaurant.user(userId);
      if (account == null || !AccessPolicy.canHoldReservation(account)) return problem(const NotAllowed());
    }
    final partySize = PartySize.parse(body.partySize);
    if (partySize case Failure(:final error)) return problem(error);
    final note = ReservationNote.parse(body.note ?? '');
    if (note case Failure(:final error)) return problem(error);
    final created = await _createReservation(
      by: actor,
      guest: guest.valueOrNull,
      start: body.start,
      partySize: partySize.valueOrNull!,
      note: note.valueOrNull!.isEmpty ? null : note.valueOrNull,
    );
    return respond(created, status: 201);
  }

  Future<Response> confirm(Request request) => _change(request, (id, actor) => _confirmReservation(id: id, by: actor));

  Future<Response> cancel(Request request) => _change(request, (id, actor) async {
    final body = CancellationDto.fromJson(await readObject(request));
    return _cancelReservation(id: id, by: actor, reason: body.reason);
  });

  Future<Response> arrival(Request request) => _change(request, (id, actor) => _recordArrival(id: id, by: actor));

  Future<Response> noShow(Request request) => _change(request, (id, actor) => _recordNoShow(id: id, by: actor));

  Future<Response> _change(
    Request request,
    Future<Result<Reservation>> Function(ReservationId id, User actor) change,
  ) async {
    return respond(await change(ReservationId(request.rawPathParameters[#id]!), _actor(request)));
  }

  User _actor(Request request) => currentSession.get(request).user;

  String _query(Request request, String name) =>
      request.queryParameters.raw[name] ?? (throw FormatException('Missing query parameter $name'));
}
