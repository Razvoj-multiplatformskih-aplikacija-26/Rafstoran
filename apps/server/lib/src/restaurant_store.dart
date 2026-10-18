import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';

const exclusionViolation = '23P01';

final class RestaurantStore {
  const RestaurantStore(this._database);

  final Pool<void> _database;

  Future<bool> isEmpty() async {
    final rows = await _database.execute('SELECT count(*) FROM users');
    return rows.single[0] == 0;
  }

  Future<OpeningHours> openingHours() async {
    final rows = await _database.execute(
      "SELECT weekday, to_char(opens, 'HH24:MI'), to_char(closes, 'HH24:MI') FROM opening_hours",
    );
    return OpeningHours({
      for (final row in rows)
        row[0]! as int: DayHours(open: _localTime(row[1]! as String), close: _localTime(row[2]! as String)),
    });
  }

  Future<List<DiningTable>> tables() async {
    final rows = await _database.execute('SELECT id, label, capacity, area FROM dining_tables ORDER BY label');
    return [
      for (final row in rows)
        DiningTable(
          id: DiningTableId(row[0]! as String),
          label: row[1]! as String,
          capacity: row[2]! as int,
          area: TableArea.values.byName(row[3]! as String),
        ),
    ];
  }

  Future<User?> user(UserId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT id, name, role FROM users WHERE id = @id'),
      parameters: {'id': id.value},
    );
    return rows.isEmpty ? null : _user(rows.single);
  }

  Future<List<User>> users(Iterable<UserId> ids) async {
    final rows = await _database.execute(
      Sql.named('SELECT id, name, role FROM users WHERE id = ANY(@ids)'),
      parameters: {
        'ids': TypedValue(Type.textArray, [for (final id in ids) id.value]),
      },
    );
    return [for (final row in rows) _user(row)];
  }

  Future<List<User>> staff() async {
    final rows = await _database.execute("SELECT id, name, role FROM users WHERE role <> 'guest'");
    return [for (final row in rows) _user(row)];
  }

  Future<List<Reservation>> reservationsStartingBetween(DateTime from, DateTime to) =>
      _reservations('starts_at >= @from AND starts_at < @to', {'from': from.toUtc(), 'to': to.toUtc()});

  Future<List<Reservation>> reservationsOverlapping(TimeSlot slot) => _reservations(
    "status <> 'cancelled' AND tstzrange(starts_at, ends_at) && tstzrange(@from, @to)",
    {'from': slot.start, 'to': slot.end},
  );

  Future<List<Reservation>> reservationsOf(UserId guestId) =>
      _reservations('guest_id = @guest', {'guest': guestId.value});

  Future<Reservation?> find(ReservationId id) async {
    if (!_uuid.hasMatch(id.value)) return null;
    final found = await _reservations('id = @id::uuid', {'id': id.value});
    return found.isEmpty ? null : found.single;
  }

  Future<Reservation> insert({
    required UserId guestId,
    required TimeSlot slot,
    required PartySize partySize,
    required DiningTableId tableId,
    required DateTime createdAt,
    ReservationNote? note,
    ReservationStatus status = const Pending(),
    UserId? enteredBy,
  }) async {
    final columns = _statusColumns(status);
    final rows = await _database.execute(
      Sql.named('''
        INSERT INTO reservations
          (guest_id, table_id, starts_at, ends_at, party_size, note, status, status_by, status_at, cancel_reason,
           created_at, entered_by)
        VALUES
          (@guest, @table, @starts, @ends, @size, @note, @status, @statusBy, @statusAt, @reason, @created, @enteredBy)
        RETURNING id::text
      '''),
      parameters: {
        'guest': guestId.value,
        'table': tableId.value,
        'starts': slot.start,
        'ends': slot.end,
        'size': partySize.value,
        'note': note?.text,
        'status': columns.kind,
        'statusBy': columns.by,
        'statusAt': columns.at,
        'reason': columns.reason,
        'created': createdAt.toUtc(),
        'enteredBy': enteredBy?.value,
      },
    );
    return Reservation(
      id: ReservationId(rows.single[0]! as String),
      guestId: guestId,
      slot: slot,
      partySize: partySize,
      createdAt: createdAt.toUtc(),
      note: note,
      tableId: tableId,
      status: status,
      enteredBy: enteredBy,
    );
  }

  Future<bool> changeStatus(Reservation changed, {required ReservationStatus from}) async {
    final columns = _statusColumns(changed.status);
    final result = await _database.execute(
      Sql.named('''
        UPDATE reservations
        SET status = @status, status_by = @statusBy, status_at = @statusAt, cancel_reason = @reason
        WHERE id = @id::uuid AND status = @previous
      '''),
      parameters: {
        'id': changed.id.value,
        'status': columns.kind,
        'statusBy': columns.by,
        'statusAt': columns.at,
        'reason': columns.reason,
        'previous': _statusColumns(from).kind,
      },
    );
    return result.affectedRows == 1;
  }

  Future<List<Reservation>> _reservations(String where, Map<String, Object?> parameters) async {
    final rows = await _database.execute(
      Sql.named('''
        SELECT id::text, guest_id, table_id, starts_at, party_size, note, status, status_by, status_at,
               cancel_reason, created_at, entered_by
        FROM reservations
        WHERE $where
        ORDER BY starts_at
      '''),
      parameters: parameters,
    );
    return [for (final row in rows) _reservation(row.toColumnMap())];
  }
}

final _uuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

User _user(ResultRow row) =>
    User(id: UserId(row[0]! as String), username: row[1]! as String, role: Role.values.byName(row[2]! as String));

Reservation _reservation(Map<String, dynamic> row) => Reservation(
  id: ReservationId(row['id'] as String),
  guestId: UserId(row['guest_id'] as String),
  tableId: DiningTableId(row['table_id'] as String),
  slot: TimeSlot.existing(row['starts_at'] as DateTime),
  partySize: PartySize.parse(row['party_size'] as int).valueOrNull!,
  note: switch (row['note']) {
    final String text => ReservationNote.parse(text).valueOrNull,
    _ => null,
  },
  status: _status(row),
  createdAt: (row['created_at'] as DateTime).toUtc(),
  enteredBy: switch (row['entered_by']) {
    final String id => UserId(id),
    _ => null,
  },
);

ReservationStatus _status(Map<String, dynamic> row) {
  final at = (row['status_at'] as DateTime?)?.toUtc();
  final by = row['status_by'] as String?;
  return switch (row['status']) {
    'confirmed' => Confirmed(confirmedBy: UserId(by!), at: at!),
    'cancelled' => Cancelled(reason: row['cancel_reason'] as String? ?? '', cancelledBy: UserId(by!), at: at!),
    'arrived' => Arrived(arrivedAt: at!),
    _ => const Pending(),
  };
}

({String kind, String? by, DateTime? at, String? reason}) _statusColumns(ReservationStatus status) => switch (status) {
  Pending() => (kind: 'pending', by: null, at: null, reason: null),
  Confirmed(:final confirmedBy, :final at) => (kind: 'confirmed', by: confirmedBy.value, at: at, reason: null),
  Cancelled(:final reason, :final cancelledBy, :final at) => (
    kind: 'cancelled',
    by: cancelledBy.value,
    at: at,
    reason: reason,
  ),
  Arrived(:final arrivedAt) => (kind: 'arrived', by: null, at: arrivedAt, reason: null),
};

LocalTime _localTime(String value) {
  final [hour, minute] = value.split(':');
  return LocalTime(int.parse(hour), int.parse(minute));
}
