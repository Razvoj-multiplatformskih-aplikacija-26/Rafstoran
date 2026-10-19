import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

OpeningHours standardOpeningHours() => OpeningHours({
  for (var day = DateTime.monday; day <= DateTime.sunday; day++)
    day: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
});

const tables = [
  DiningTable(id: DiningTableId('t-2'), label: 'S1', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-4'), label: 'S2', capacity: 4, area: TableArea.hall),
];

const guest = User(id: UserId('u-guest'), username: 'guest1', role: Role.guest);

final class InMemoryRestaurant implements ReservationRepository, SlotRepository {
  InMemoryRestaurant({required this.clock, List<Reservation> reservations = const []})
    : reservations = List.of(reservations);

  final Clock clock;
  final List<Reservation> reservations;
  int _nextId = 1;

  @override
  Future<OpeningHours> openingHours() async => standardOpeningHours();

  @override
  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize}) async {
    return domainAvailableSlots(
      openingHours: standardOpeningHours(),
      tables: tables,
      reservations: reservations,
      localDay: localDay,
      partySize: partySize,
      now: clock.now(),
    );
  }

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) async =>
      reservations.where((r) => r.guest.isAccount(guestId)).toList();

  @override
  Future<Reservation?> find(ReservationId id) async => reservations.where((r) => r.id == id).firstOrNull;

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async {
    if (!guestIsFree(guest: request.guest, slot: request.slot, reservations: reservations)) {
      return const Failure(GuestAlreadyBooked());
    }
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
      guest: request.guest,
      slot: request.slot,
      partySize: request.partySize,
      note: request.note,
      tableId: table.id,
      status: request.status,
      createdAt: clock.now(),
      enteredBy: request.enteredBy,
    );
    reservations.add(reservation);
    return reservation;
  }

  @override
  Future<Reservation> save(Reservation reservation) async {
    final index = reservations.indexWhere((r) => r.id == reservation.id);
    reservations[index] = reservation;
    return reservation;
  }
}

List<SlotAvailability> domainAvailableSlots({
  required OpeningHours openingHours,
  required List<DiningTable> tables,
  required List<Reservation> reservations,
  required DateTime localDay,
  required PartySize partySize,
  required DateTime now,
}) => availableSlots(
  openingHours: openingHours,
  tables: tables,
  reservations: reservations,
  localDay: localDay,
  partySize: partySize,
  now: now,
);
