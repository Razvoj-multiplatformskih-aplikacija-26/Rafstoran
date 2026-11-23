import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';
import 'package:use_cases/use_cases.dart';

import 'local/local_database.dart';

final class LocalFirstSchedule implements ScheduleFeed, ReservationRepository {
  LocalFirstSchedule({
    required this.schedules,
    required this.reservations,
    required this.database,
    required this.clock,
  });

  final ScheduleRepository schedules;
  final ReservationRepository reservations;
  final LocalDatabase database;
  final Clock clock;

  @override
  Stream<ScheduleSnapshot?> watch(DateTime localDay) {
    final days = database.storedDays;
    final stored = database.storedReservations;
    final query = database.select(days).join([leftOuterJoin(stored, stored.day.equalsExp(days.day))])
      ..where(days.day.equals(dayToJson(localDay)));
    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final day = rows.first.readTable(days);
      final layout = ScheduleDto.fromJson(_object(day.layout));
      final schedule = ScheduleDto(
        day: layout.day,
        openingHours: layout.openingHours,
        tables: layout.tables,
        reservations: [
          for (final row in rows)
            if (row.readTableOrNull(stored) case final reservation?)
              ReservationDto.fromJson(_object(reservation.contract)),
        ],
        guests: layout.guests,
        staff: layout.staff,
      );
      return ScheduleSnapshot(schedule.toDomain(), refreshedAt: day.refreshedAt);
    });
  }

  @override
  Future<void> refresh(DateTime localDay) async {
    final schedule = (await schedules.scheduleFor(localDay)).toDto();
    final day = dayToJson(localDay);
    final layout = ScheduleDto(
      day: schedule.day,
      openingHours: schedule.openingHours,
      tables: schedule.tables,
      reservations: const [],
      guests: schedule.guests,
      staff: schedule.staff,
    );
    await database.transaction(() async {
      if (!await _signedIn()) return;
      await (database.delete(database.storedReservations)..where((r) => r.day.equals(day))).go();
      await database.batch(
        (batch) => batch.insertAll(database.storedReservations, [
          for (final reservation in schedule.reservations)
            StoredReservationsCompanion.insert(
              id: reservation.id,
              day: day,
              contract: jsonEncode(reservation.toJson()),
            ),
        ]),
      );
      await database
          .into(database.storedDays)
          .insertOnConflictUpdate(
            StoredDaysCompanion.insert(day: day, layout: jsonEncode(layout.toJson()), refreshedAt: clock.now()),
          );
    });
  }

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) => reservations.reservationsOf(guestId);

  @override
  Future<Reservation?> find(ReservationId id) => reservations.find(id);

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async => _stored(await reservations.create(request));

  @override
  Future<Result<Reservation>> save(Reservation reservation, {required ReservationStatus from}) async =>
      _stored(await reservations.save(reservation, from: from));

  Future<Result<Reservation>> _stored(Result<Reservation> result) async {
    if (result case Success(value: final reservation)) {
      final day = dayToJson(restaurantDay(reservation.slot.start));
      await database.transaction(() async {
        final days = database.storedDays;
        final known = await (database.select(days)..where((d) => d.day.equals(day))).getSingleOrNull();
        if (known == null || !await _signedIn()) return;
        await database
            .into(database.storedReservations)
            .insertOnConflictUpdate(
              StoredReservationsCompanion.insert(
                id: reservation.id.value,
                day: day,
                contract: jsonEncode(reservation.toDto().toJson()),
              ),
            );
      });
    }
    return result;
  }

  Future<bool> _signedIn() async => await database.select(database.signedInUsers).getSingleOrNull() != null;

  static Map<String, Object?> _object(String json) => jsonDecode(json) as Map<String, Object?>;
}
