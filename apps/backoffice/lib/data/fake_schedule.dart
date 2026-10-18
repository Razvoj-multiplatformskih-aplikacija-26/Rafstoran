import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;
import 'package:use_cases/use_cases.dart';

final staffOpeningHours = OpeningHours({
  DateTime.monday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.tuesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.wednesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.thursday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.friday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.saturday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.sunday: const DayHours(open: LocalTime(12, 0), close: LocalTime(22, 0)),
});

const staffTables = [
  DiningTable(id: DiningTableId('t-01'), label: 'S1', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-02'), label: 'S2', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-03'), label: 'S3', capacity: 4, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-04'), label: 'S4', capacity: 4, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-05'), label: 'S5', capacity: 6, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-06'), label: 'S6', capacity: 8, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-07'), label: 'T1', capacity: 2, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-08'), label: 'T2', capacity: 4, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-09'), label: 'T3', capacity: 4, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-10'), label: 'T4', capacity: 6, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-11'), label: 'B1', capacity: 4, area: TableArea.garden),
  DiningTable(id: DiningTableId('t-12'), label: 'B2', capacity: 10, area: TableArea.garden),
];

const staffGuests = {
  UserId('u-ana'): User(id: UserId('u-ana'), username: 'Ana Petrović', role: Role.guest),
  UserId('u-marko'): User(id: UserId('u-marko'), username: 'Marko Jovanović', role: Role.guest),
  UserId('u-jelena'): User(id: UserId('u-jelena'), username: 'Jelena Nikolić', role: Role.guest),
  UserId('u-nikola'): User(id: UserId('u-nikola'), username: 'Nikola Đorđević', role: Role.guest),
  UserId('u-milica'): User(id: UserId('u-milica'), username: 'Milica Stojanović', role: Role.guest),
  UserId('u-stefan'): User(id: UserId('u-stefan'), username: 'Stefan Ilić', role: Role.guest),
  UserId('u-tamara'): User(id: UserId('u-tamara'), username: 'Tamara Pavlović', role: Role.guest),
  UserId('u-luka'): User(id: UserId('u-luka'), username: 'Luka Marković', role: Role.guest),
};

const staffWaiter = User(id: UserId('u-waiter'), username: 'Konobar', role: Role.waiter);

const staffMembers = {UserId('u-waiter'): staffWaiter};

const _waiter = UserId('u-waiter');

List<Reservation> staffSeedReservations(DateTime now) {
  final today = restaurantDay(now);
  final guestIds = staffGuests.keys.toList();
  var counter = 0;

  Reservation seed({
    required int dayOffset,
    required int hour,
    required int partySize,
    required String tableId,
    int minute = 0,
    String? note,
    String status = 'pending',
  }) {
    final day = addDays(today, dayOffset);
    final start = staffOpeningHours.localToUtc(day.year, day.month, day.day, LocalTime(hour, minute));
    final id = 's-${counter++}';
    final guestId = guestIds[counter % guestIds.length];
    final confirmedAt = start.subtract(const Duration(hours: 20));
    return Reservation(
      id: ReservationId(id),
      guestId: guestId,
      slot: TimeSlot.existing(start),
      partySize: PartySize.parse(partySize).valueOrNull!,
      note: note == null ? null : ReservationNote.parse(note).valueOrNull,
      tableId: DiningTableId(tableId),
      status: switch (status) {
        'confirmed' => Confirmed(confirmedBy: _waiter, at: confirmedAt),
        'arrived' => Arrived(arrivedAt: start.add(const Duration(minutes: 4))),
        'cancelled' => Cancelled(reason: 'Gost otkazao.', cancelledBy: guestId, at: confirmedAt),
        _ => const Pending(),
      },
      createdAt: start.subtract(const Duration(days: 2)),
    );
  }

  return [
    for (final offset in [-1, 0, 1, 2]) ...[
      seed(dayOffset: offset, hour: 12, minute: 30, partySize: 2, tableId: 't-01', status: 'arrived'),
      seed(dayOffset: offset, hour: 13, partySize: 4, tableId: 't-03', status: 'arrived', note: 'Poslovni ručak.'),
      seed(dayOffset: offset, hour: 13, minute: 30, partySize: 6, tableId: 't-05', status: 'confirmed'),
      seed(dayOffset: offset, hour: 14, partySize: 2, tableId: 't-07', status: 'confirmed'),
      seed(dayOffset: offset, hour: 14, minute: 30, partySize: 2, tableId: 't-02', note: 'Bez glutena.'),
      seed(dayOffset: offset, hour: 15, minute: 30, partySize: 4, tableId: 't-09'),
      seed(
        dayOffset: offset,
        hour: 18,
        partySize: 4,
        tableId: 't-08',
        status: 'confirmed',
        note: 'Visoka stolica za dete.',
      ),
      seed(dayOffset: offset, hour: 18, minute: 30, partySize: 2, tableId: 't-02'),
      seed(
        dayOffset: offset,
        hour: 19,
        partySize: 8,
        tableId: 't-06',
        status: 'confirmed',
        note: 'Rođendan, torta stiže u 20h.',
      ),
      seed(dayOffset: offset, hour: 19, minute: 30, partySize: 4, tableId: 't-04', status: 'confirmed'),
      seed(dayOffset: offset, hour: 20, partySize: 2, tableId: 't-01'),
      seed(
        dayOffset: offset,
        hour: 20,
        partySize: 4,
        tableId: 't-09',
        status: 'confirmed',
        note: 'Sto pored prozora, ako je moguće.',
      ),
      seed(dayOffset: offset, hour: 20, minute: 30, partySize: 6, tableId: 't-10'),
      seed(
        dayOffset: offset,
        hour: 20,
        minute: 30,
        partySize: 10,
        tableId: 't-12',
        status: 'confirmed',
        note: 'Proslava diplome.',
      ),
      seed(dayOffset: offset, hour: 21, partySize: 4, tableId: 't-11'),
      seed(dayOffset: offset, hour: 21, partySize: 2, tableId: 't-07', status: 'cancelled'),
      seed(dayOffset: offset, hour: 15, partySize: 4, tableId: 't-03', status: 'cancelled'),
    ],
  ];
}

final class FakeSchedule implements ScheduleRepository, ReservationRepository, SlotRepository {
  FakeSchedule({required this.clock, this.latency = const Duration(milliseconds: 400)})
    : _reservations = staffSeedReservations(clock.now());

  final Clock clock;
  final Duration latency;
  final List<Reservation> _reservations;
  int failingRequests = 0;
  int _nextId = 1;

  Future<void> _roundTrip() async {
    await Future<void>.delayed(latency);
    if (failingRequests > 0) {
      failingRequests--;
      throw const RepositoryException('Simulated outage');
    }
  }

  @override
  Future<DailySchedule> scheduleFor(DateTime localDay) async {
    await _roundTrip();
    return DailySchedule(
      day: localDay,
      openingHours: staffOpeningHours,
      tables: staffTables,
      reservations: _reservations.where((r) => restaurantDay(r.slot.start) == localDay).toList(),
      guests: staffGuests,
      staff: staffMembers,
    );
  }

  @override
  Future<Reservation?> find(ReservationId id) async {
    await _roundTrip();
    return _reservations.where((r) => r.id == id).firstOrNull;
  }

  @override
  Future<Reservation> save(Reservation reservation) async {
    await _roundTrip();
    final index = _reservations.indexWhere((r) => r.id == reservation.id);
    _reservations[index] = reservation;
    return reservation;
  }

  @override
  Future<List<Reservation>> reservationsOf(UserId guestId) async {
    await _roundTrip();
    return _reservations.where((r) => r.guestId == guestId).toList();
  }

  @override
  Future<OpeningHours> openingHours() async => staffOpeningHours;

  @override
  Future<List<SlotAvailability>> availableSlots({required DateTime localDay, required PartySize partySize}) async {
    await _roundTrip();
    return domain.availableSlots(
      openingHours: staffOpeningHours,
      tables: staffTables,
      reservations: _reservations,
      localDay: localDay,
      partySize: partySize,
      now: clock.now(),
    );
  }

  @override
  Future<Result<Reservation>> create(ReservationRequest request) async {
    await _roundTrip();
    final table = assignTable(
      tables: staffTables,
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
      id: ReservationId('staff-${_nextId++}'),
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
}
