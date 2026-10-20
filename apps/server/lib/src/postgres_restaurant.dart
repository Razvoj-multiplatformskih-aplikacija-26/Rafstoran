import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;
import 'package:postgres/postgres.dart' show ServerException;
import 'package:use_cases/use_cases.dart';

import 'restaurant_store.dart';

final class PostgresRestaurant implements ReservationRepository, SlotRepository, ScheduleRepository {
  PostgresRestaurant(this._store, {required this.clock, this.raceDelay = Duration.zero});

  final RestaurantStore _store;
  final Clock clock;
  final Duration raceDelay;

  @override
  Future<OpeningHours> openingHours() => _store.openingHours();

  @override
  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize}) async {
    final openingHours = await _store.openingHours();
    return domain.availableSlots(
      openingHours: openingHours,
      tables: await _store.tables(),
      reservations: await _reservationsOn(localDay, openingHours),
      localDay: localDay,
      partySize: partySize,
      now: clock.now(),
    );
  }

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) => _store.reservationsOf(guestId);

  @override
  Future<Reservation?> find(ReservationId id) => _store.find(id);

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async {
    final tables = await _store.tables();
    for (var attempt = 0; attempt <= tables.length; attempt++) {
      final overlapping = await _store.reservationsOverlapping(request.slot);
      if (!guestIsFree(guest: request.guest, slot: request.slot, reservations: overlapping)) {
        return const Failure(GuestAlreadyBooked());
      }
      final table = assignTable(
        tables: tables,
        reservations: overlapping,
        slot: request.slot,
        partySize: request.partySize,
      );
      if (table case Failure(:final error)) return Failure(error);
      await Future<void>.delayed(raceDelay);
      try {
        return Success(
          await _store.insert(
            guest: request.guest,
            slot: request.slot,
            partySize: request.partySize,
            note: request.note,
            tableId: table.valueOrNull!.id,
            createdAt: clock.now(),
            status: request.status,
            enteredBy: request.enteredBy,
          ),
        );
      } on ServerException catch (error) {
        if (error.code != exclusionViolation) rethrow;
        if (error.constraintName != tableConstraint) return const Failure(GuestAlreadyBooked());
      }
    }
    return const Failure(NoTableAvailable());
  }

  @override
  Future<Result<Reservation>> save(Reservation reservation, {required ReservationStatus from}) async {
    if (await _store.changeStatus(reservation, from: from)) return Success(reservation);
    final current = await _store.find(reservation.id);
    return Failure(InvalidTransition(from: current!.status, to: reservation.status));
  }

  @override
  Future<DailySchedule> scheduleFor(DateTime localDay) async {
    final openingHours = await _store.openingHours();
    final reservations = await _reservationsOn(localDay, openingHours);
    final guests = await _store.users({
      for (final reservation in reservations)
        if (reservation.guest case AccountGuest(:final userId)) userId,
    });
    return DailySchedule(
      day: localDay,
      openingHours: openingHours,
      tables: await _store.tables(),
      reservations: reservations,
      guests: {for (final guest in guests) guest.id: guest},
      staff: {for (final member in await _store.staff()) member.id: member},
    );
  }

  Future<List<Reservation>> _reservationsOn(DateTime day, OpeningHours openingHours) =>
      _store.reservationsStartingBetween(
        openingHours.localToUtc(day.year, day.month, day.day, const LocalTime(0, 0)),
        openingHours.localToUtc(day.year, day.month, day.day + 1, const LocalTime(0, 0)),
      );
}
