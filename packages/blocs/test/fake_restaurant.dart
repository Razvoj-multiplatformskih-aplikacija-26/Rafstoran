import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;
import 'package:use_cases/use_cases.dart';

OpeningHours everyDayNoonToEleven() => OpeningHours({
  for (var day = DateTime.monday; day <= DateTime.sunday; day++)
    day: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
});

const guest = User(id: UserId('u-guest'), username: 'guest1', role: Role.guest);
const tables = [
  DiningTable(id: DiningTableId('t-2'), label: 'S1', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-4'), label: 'S2', capacity: 4, area: TableArea.hall),
];

final class FakeRestaurant implements ReservationRepository, SlotRepository {
  FakeRestaurant({required this.clock, List<Reservation> reservations = const [], this.failing = false})
    : reservations = List.of(reservations);

  final Clock clock;
  final List<Reservation> reservations;
  bool failing;
  int _nextId = 1;

  void _maybeFail() {
    if (failing) throw const RepositoryException('simulated outage');
  }

  @override
  Future<OpeningHours> openingHours() async => everyDayNoonToEleven();

  @override
  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize}) async {
    _maybeFail();
    return domain.availableSlots(
      openingHours: everyDayNoonToEleven(),
      tables: tables,
      reservations: reservations,
      localDay: localDay,
      partySize: partySize,
      now: clock.now(),
    );
  }

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) async {
    _maybeFail();
    return reservations.where((r) => r.guestId == guestId).toList();
  }

  @override
  Future<Reservation?> find(ReservationId id) async {
    _maybeFail();
    return reservations.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async {
    _maybeFail();
    final table = assignTable(
      tables: tables,
      reservations: reservations,
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
      id: ReservationId('r-${_nextId++}'),
      guestId: request.guestId,
      slot: request.slot,
      partySize: request.partySize,
      note: request.note,
      tableId: table.id,
      createdAt: clock.now(),
      enteredBy: request.enteredBy,
    );
    reservations.add(reservation);
    return reservation;
  }

  @override
  Future<Reservation> save(Reservation reservation) async {
    _maybeFail();
    final index = reservations.indexWhere((r) => r.id == reservation.id);
    reservations[index] = reservation;
    return reservation;
  }
}
