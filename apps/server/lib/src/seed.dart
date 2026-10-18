import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

import 'restaurant_store.dart';

const _guest = User(id: UserId('u-guest'), username: 'Gost', role: Role.guest);
const _waiter = User(id: UserId('u-waiter'), username: 'Konobar', role: Role.waiter);

const _otherGuests = [
  User(id: UserId('u-ana'), username: 'Ana Petrović', role: Role.guest),
  User(id: UserId('u-marko'), username: 'Marko Jovanović', role: Role.guest),
  User(id: UserId('u-jelena'), username: 'Jelena Nikolić', role: Role.guest),
  User(id: UserId('u-nikola'), username: 'Nikola Đorđević', role: Role.guest),
  User(id: UserId('u-milica'), username: 'Milica Stojanović', role: Role.guest),
  User(id: UserId('u-stefan'), username: 'Stefan Ilić', role: Role.guest),
  User(id: UserId('u-tamara'), username: 'Tamara Pavlović', role: Role.guest),
  User(id: UserId('u-luka'), username: 'Luka Marković', role: Role.guest),
];

const _tables = [
  ('t-01', 'S1', 2, 'hall'),
  ('t-02', 'S2', 2, 'hall'),
  ('t-03', 'S3', 4, 'hall'),
  ('t-04', 'S4', 4, 'hall'),
  ('t-05', 'S5', 6, 'hall'),
  ('t-06', 'S6', 8, 'hall'),
  ('t-07', 'T1', 2, 'terrace'),
  ('t-08', 'T2', 4, 'terrace'),
  ('t-09', 'T3', 4, 'terrace'),
  ('t-10', 'T4', 6, 'terrace'),
  ('t-11', 'B1', 4, 'garden'),
  ('t-12', 'B2', 10, 'garden'),
];

const _openingHours = [
  (DateTime.monday, '12:00', '23:00'),
  (DateTime.tuesday, '12:00', '23:00'),
  (DateTime.wednesday, '12:00', '23:00'),
  (DateTime.thursday, '12:00', '23:00'),
  (DateTime.friday, '12:00', '24:00'),
  (DateTime.saturday, '12:00', '24:00'),
  (DateTime.sunday, '12:00', '22:00'),
];

const _evening = [
  (12, 30, 2, null),
  (13, 0, 4, 'Poslovni ručak.'),
  (13, 30, 6, null),
  (14, 0, 2, null),
  (18, 0, 4, 'Visoka stolica za dete.'),
  (19, 0, 8, 'Rođendan, torta stiže u 20h.'),
  (19, 30, 4, null),
  (20, 0, 2, 'Sto pored prozora, ako je moguće.'),
  (20, 0, 4, null),
  (20, 30, 6, null),
  (21, 0, 4, null),
  (21, 0, 2, 'Bez glutena.'),
];

const _mine = [
  (1, 20, 0, 4, 'Sto pored prozora, ako je moguće.', 'confirmed'),
  (5, 13, 0, 2, null, 'pending'),
  (2, 13, 0, 2, 'Terasa, ako je lepo vreme.', 'pending'),
  (10, 16, 0, 8, 'Poslovna večera.', 'confirmed'),
  (-3, 19, 30, 6, 'Rođendan, treba nam mesto za tortu.', 'arrived'),
  (-12, 21, 0, 3, null, 'cancelled'),
  (-7, 20, 0, 2, null, 'arrived'),
  (-20, 19, 0, 4, null, 'cancelled'),
  (8, 12, 30, 2, null, 'pending'),
  (3, 14, 30, 5, null, 'confirmed'),
];

Future<void> seedIfEmpty(Pool<void> database, RestaurantStore store, {required DateTime now}) async {
  if (!await store.isEmpty()) return;
  for (final user in [_guest, _waiter, ..._otherGuests]) {
    await database.execute(
      Sql.named('INSERT INTO users (id, name, role) VALUES (@id, @name, @role)'),
      parameters: {'id': user.id.value, 'name': user.username, 'role': user.role.name},
    );
  }
  for (final (id, label, capacity, area) in _tables) {
    await database.execute(
      Sql.named('INSERT INTO dining_tables (id, label, capacity, area) VALUES (@id, @label, @capacity, @area)'),
      parameters: {'id': id, 'label': label, 'capacity': capacity, 'area': area},
    );
  }
  for (final (weekday, opens, closes) in _openingHours) {
    await database.execute(
      Sql.named('INSERT INTO opening_hours (weekday, opens, closes) VALUES (@weekday, @opens::time, @closes::time)'),
      parameters: {'weekday': weekday, 'opens': opens, 'closes': closes},
    );
  }

  final openingHours = await store.openingHours();
  final tables = await store.tables();
  final today = restaurantDay(now);
  final seeded = <Reservation>[];

  Future<void> seed(UserId guest, int dayOffset, int hour, int minute, int size, String? note, String kind) async {
    final day = today.add(Duration(days: dayOffset));
    final start = openingHours.localToUtc(day.year, day.month, day.day, LocalTime(hour, minute));
    if (!openingHours.covers(start, TimeSlot.duration)) return;
    final slot = TimeSlot.existing(start);
    final partySize = PartySize.parse(size).valueOrNull!;
    final table = assignTable(tables: tables, reservations: seeded, slot: slot, partySize: partySize).valueOrNull;
    if (table == null) return;
    final createdAt = start.subtract(const Duration(days: 2));
    seeded.add(
      await store.insert(
        guestId: guest,
        slot: slot,
        partySize: partySize,
        tableId: table.id,
        createdAt: createdAt,
        note: note == null ? null : ReservationNote.parse(note).valueOrNull,
        status: switch (kind) {
          'confirmed' => Confirmed(confirmedBy: _waiter.id, at: createdAt.add(const Duration(hours: 1))),
          'arrived' => Arrived(arrivedAt: start.add(const Duration(minutes: 4))),
          'cancelled' => Cancelled(
            reason: 'Promena plana.',
            cancelledBy: guest,
            at: createdAt.add(const Duration(hours: 2)),
          ),
          _ => const Pending(),
        },
      ),
    );
  }

  for (final (dayOffset, hour, minute, size, note, kind) in _mine) {
    await seed(_guest.id, dayOffset, hour, minute, size, note, kind);
  }
  var turn = 0;
  for (var dayOffset = -7; dayOffset <= 13; dayOffset++) {
    for (final (hour, minute, size, note) in _evening) {
      final guest = _otherGuests[turn++ % _otherGuests.length].id;
      final past = dayOffset < 0;
      final kind = switch (turn % 6) {
        0 => 'cancelled',
        1 || 2 || 3 => past ? 'arrived' : 'confirmed',
        _ => past ? 'arrived' : 'pending',
      };
      await seed(guest, dayOffset, hour, minute, size, note, kind);
    }
  }
}
