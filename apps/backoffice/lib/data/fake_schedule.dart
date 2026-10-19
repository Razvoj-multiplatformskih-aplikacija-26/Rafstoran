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
  DiningTable(id: DiningTableId('t-12'), label: 'B2', capacity: 12, area: TableArea.garden),
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

const staffWaiter = User(id: UserId('u-waiter'), username: 'Marija Kostić', role: Role.waiter);

const staffMembers = {UserId('u-waiter'): staffWaiter};

const _waiter = UserId('u-waiter');

enum _Plan { pending, confirmed, cancelled }

enum _Outcome { arrived, noShow }

typedef _Entry = ({
  int minutes,
  String tableId,
  int partySize,
  _Plan plan,
  _Outcome outcome,
  String? note,
  (String, String)? caller,
});

const _day = <_Entry>[
  (
    minutes: -360,
    tableId: 't-01',
    partySize: 2,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
  (
    minutes: -330,
    tableId: 't-03',
    partySize: 4,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: 'Poslovni ručak.',
    caller: null,
  ),
  (
    minutes: -300,
    tableId: 't-05',
    partySize: 6,
    plan: _Plan.confirmed,
    outcome: _Outcome.noShow,
    note: null,
    caller: ('Ivana Ristić', '063 777 2020'),
  ),
  (
    minutes: -270,
    tableId: 't-07',
    partySize: 2,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
  (
    minutes: -240,
    tableId: 't-02',
    partySize: 2,
    plan: _Plan.cancelled,
    outcome: _Outcome.arrived,
    note: 'Bez laktoze.',
    caller: null,
  ),
  (
    minutes: -210,
    tableId: 't-09',
    partySize: 4,
    plan: _Plan.pending,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
  (
    minutes: -60,
    tableId: 't-08',
    partySize: 4,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: 'Visoka stolica za dete.',
    caller: null,
  ),
  (
    minutes: -30,
    tableId: 't-07',
    partySize: 2,
    plan: _Plan.confirmed,
    outcome: _Outcome.noShow,
    note: null,
    caller: null,
  ),
  (
    minutes: 0,
    tableId: 't-06',
    partySize: 8,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: 'Rođendan, torta stiže kasnije.',
    caller: null,
  ),
  (
    minutes: 30,
    tableId: 't-04',
    partySize: 4,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
  (
    minutes: 90,
    tableId: 't-02',
    partySize: 2,
    plan: _Plan.pending,
    outcome: _Outcome.arrived,
    note: 'Bez glutena.',
    caller: null,
  ),
  (
    minutes: 90,
    tableId: 't-09',
    partySize: 4,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: 'Sto pored prozora, ako je moguće.',
    caller: null,
  ),
  (
    minutes: 120,
    tableId: 't-10',
    partySize: 6,
    plan: _Plan.pending,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
  (
    minutes: 120,
    tableId: 't-12',
    partySize: 12,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: 'Proslava diplome.',
    caller: null,
  ),
  (
    minutes: 150,
    tableId: 't-11',
    partySize: 4,
    plan: _Plan.pending,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
  (
    minutes: 150,
    tableId: 't-01',
    partySize: 2,
    plan: _Plan.confirmed,
    outcome: _Outcome.arrived,
    note: null,
    caller: ('Petar Lukić', '064 555 0101'),
  ),
  (
    minutes: 60,
    tableId: 't-03',
    partySize: 4,
    plan: _Plan.cancelled,
    outcome: _Outcome.arrived,
    note: null,
    caller: null,
  ),
];

DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

List<Reservation> staffSeedReservations(DateTime now) {
  final today = restaurantDay(now);
  final local = restaurantTime(now);
  final anchor = ((local.hour * 60 + local.minute) ~/ 30 * 30).clamp(14 * 60, 20 * 60);
  final accounts = staffGuests.keys.toList();

  Reservation seed(int dayOffset, int index, _Entry entry, ReservationGuest guest) {
    final day = addDays(today, dayOffset);
    final start = staffOpeningHours
        .localToUtc(day.year, day.month, day.day, LocalTime(anchor ~/ 60, anchor % 60))
        .add(Duration(minutes: entry.minutes));
    final end = start.add(TimeSlot.duration);
    final decidedAt = _earlier(start.subtract(const Duration(hours: 20)), now.subtract(const Duration(hours: 1)));
    final arrivedAt = start.add(const Duration(minutes: 4));
    final undecided = entry.plan == _Plan.confirmed ? Confirmed(confirmedBy: _waiter, at: decidedAt) : const Pending();
    final ReservationStatus status = switch (entry.plan) {
      _Plan.cancelled => Cancelled(
        reason: 'Gost otkazao.',
        cancelledBy: guest is AccountGuest ? guest.userId : _waiter,
        at: decidedAt,
      ),
      _ when now.isBefore(start) => undecided,
      _ when entry.outcome == _Outcome.arrived && !now.isBefore(arrivedAt) => Arrived(arrivedAt: arrivedAt),
      _ when entry.outcome == _Outcome.noShow && !now.isBefore(end) => NoShow(
        recordedBy: _waiter,
        at: start.add(const Duration(minutes: 30)),
      ),
      _ => undecided,
    };
    return Reservation(
      id: ReservationId('s-${dayOffset + 1}${(index + 1).toString().padLeft(2, '0')}'),
      guest: guest,
      slot: TimeSlot.existing(start),
      partySize: PartySize.parse(entry.partySize).valueOrNull!,
      note: entry.note == null ? null : ReservationNote.parse(entry.note!).valueOrNull,
      tableId: DiningTableId(entry.tableId),
      status: status,
      createdAt: _earlier(start.subtract(const Duration(days: 2)), now.subtract(const Duration(hours: 2))),
      enteredBy: guest is ContactGuest ? _waiter : null,
    );
  }

  return [
    for (final dayOffset in [-1, 0, 1, 2])
      for (final (index, entry) in _day.indexed)
        if (seed(dayOffset, index, entry, _guestFor(entry, index, accounts)) case final reservation
            when staffOpeningHours.covers(reservation.slot.start, TimeSlot.duration))
          reservation,
  ];
}

ReservationGuest _guestFor(_Entry entry, int index, List<UserId> accounts) => switch (entry.caller) {
  (final name, final phone) => ContactGuest.parse(name: name, phone: phone).valueOrNull!,
  null => AccountGuest(accounts[index % accounts.length]),
};

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
    return _reservations.where((r) => r.guest.isAccount(guestId)).toList();
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
    if (!guestIsFree(guest: request.guest, slot: request.slot, reservations: _reservations)) {
      return const Failure(GuestAlreadyBooked());
    }
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
      guest: request.guest,
      slot: request.slot,
      partySize: request.partySize,
      note: request.note,
      tableId: table.id,
      status: request.status,
      createdAt: clock.now(),
      enteredBy: request.enteredBy,
    );
    _reservations.add(reservation);
    return reservation;
  }
}
