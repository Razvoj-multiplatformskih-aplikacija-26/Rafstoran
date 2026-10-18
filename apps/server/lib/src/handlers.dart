import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:relic/relic.dart' hide Result;
import 'package:use_cases/use_cases.dart';

import 'http.dart';
import 'postgres_restaurant.dart';
import 'restaurant_store.dart';

final class RestaurantHandlers {
  RestaurantHandlers({required this.restaurant, required this.users, required Clock clock})
    : _getAvailableSlots = GetAvailableSlots(slots: restaurant),
      _getDailySchedule = GetDailySchedule(schedules: restaurant),
      _createReservation = CreateReservation(reservations: restaurant, slots: restaurant, clock: clock),
      _confirmReservation = ConfirmReservation(reservations: restaurant, clock: clock),
      _cancelReservation = CancelReservation(reservations: restaurant, clock: clock),
      _recordArrival = RecordArrival(reservations: restaurant, clock: clock);

  final PostgresRestaurant restaurant;
  final RestaurantStore users;
  final GetAvailableSlots _getAvailableSlots;
  final GetDailySchedule _getDailySchedule;
  final CreateReservation _createReservation;
  final ConfirmReservation _confirmReservation;
  final CancelReservation _cancelReservation;
  final RecordArrival _recordArrival;

  Future<Response> openingHours(Request request) async => json(200, (await restaurant.openingHours()).toDto().toJson());

  Future<Response> slots(Request request) async {
    final day = dayFromJson(_query(request, ApiQuery.day));
    final partySize = PartySize.parse(int.parse(_query(request, ApiQuery.partySize)));
    if (partySize case Failure(:final error)) return problem(error);
    final slots = await _getAvailableSlots(localDay: day, partySize: partySize.valueOrNull!);
    return json(200, [for (final slot in slots) slot.toDto().toJson()]);
  }

  Future<Response> schedule(Request request) async =>
      json(200, (await _getDailySchedule(dayFromJson(_query(request, ApiQuery.day)))).toDto().toJson());

  Future<Response> reservationsOfGuest(Request request) async {
    final reservations = await restaurant.reservationsOf(UserId(request.rawPathParameters[#guestId]!));
    return json(200, [for (final reservation in reservations) reservation.toDto().toJson()]);
  }

  Future<Response> find(Request request) async {
    final reservation = await restaurant.find(ReservationId(request.rawPathParameters[#id]!));
    return reservation == null ? problem(const NotFound()) : json(200, reservation.toDto().toJson());
  }

  Future<Response> create(Request request) async {
    final actor = await _actor(request);
    if (actor == null) return badRequest('Unknown user');
    final body = NewReservationDto.fromJson(await readObject(request));
    final guest = await users.user(UserId(body.guestId));
    if (guest == null || !AccessPolicy.canHoldReservation(guest)) return problem(const NotAllowed());
    final partySize = PartySize.parse(body.partySize);
    if (partySize case Failure(:final error)) return problem(error);
    final note = ReservationNote.parse(body.note ?? '');
    if (note case Failure(:final error)) return problem(error);
    final created = await _createReservation(
      by: actor,
      forGuest: UserId(body.guestId),
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

  Future<Response> _change(
    Request request,
    Future<Result<Reservation>> Function(ReservationId id, User actor) change,
  ) async {
    final actor = await _actor(request);
    if (actor == null) return badRequest('Unknown user');
    return respond(await change(ReservationId(request.rawPathParameters[#id]!), actor));
  }

  Future<User?> _actor(Request request) async {
    final id = request.headers[ApiHeaders.userId]?.firstOrNull;
    return id == null ? null : users.user(UserId(id));
  }

  String _query(Request request, String name) =>
      request.queryParameters.raw[name] ?? (throw FormatException('Missing query parameter $name'));
}
