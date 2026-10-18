import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;
import 'package:use_cases/use_cases.dart';

import 'seed.dart';

final class FakeRestaurant implements ReservationRepository, SlotRepository {
  FakeRestaurant({required this.clock, this.latency = const Duration(milliseconds: 700)})
    : _reservations = seedReservations(clock.now());

  final Clock clock;
  final Duration latency;
  final List<Reservation> _reservations;
  int failingRequests = 0;
  int emptyResponses = 0;
  int _nextId = 1;

  Future<void> _roundTrip() async {
    await Future<void>.delayed(latency);
    if (failingRequests > 0) {
      failingRequests--;
      throw const RepositoryException('Simulated outage');
    }
  }

  bool _answersEmpty() {
    if (emptyResponses == 0) return false;
    emptyResponses--;
    return true;
  }

  @override
  Future<OpeningHours> openingHours() async => fakeOpeningHours;

  @override
  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize}) async {
    await _roundTrip();
    if (_answersEmpty()) return const [];
    return domain.availableSlots(
      openingHours: fakeOpeningHours,
      tables: fakeTables,
      reservations: _reservations,
      localDay: localDay,
      partySize: partySize,
      now: clock.now(),
    );
  }

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) async {
    await _roundTrip();
    if (_answersEmpty()) return const [];
    return _reservations.where((r) => r.guestId == guestId).toList();
  }

  @override
  Future<Reservation?> find(ReservationId id) async {
    await _roundTrip();
    return _reservations.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async {
    await _roundTrip();
    final table = assignTable(
      tables: fakeTables,
      reservations: _reservations,
      slot: request.slot,
      partySize: request.partySize,
    );
    return switch (table) {
      Failure(:final error) => Failure(error),
      Success(:final value) => Success(_store(request, value)),
    };
  }

  Reservation _store(ReservationRequest request, DiningTable table) {
    final reservation = Reservation(
      id: ReservationId('local-${_nextId++}'),
      guestId: request.guestId,
      slot: request.slot,
      partySize: request.partySize,
      note: request.note,
      tableId: table.id,
      createdAt: clock.now(),
      enteredBy: request.enteredBy,
    );
    _reservations.add(reservation);
    return reservation;
  }

  @override
  Future<Reservation> save(Reservation reservation) async {
    await _roundTrip();
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    _reservations[index] = reservation;
    return reservation;
  }
}
