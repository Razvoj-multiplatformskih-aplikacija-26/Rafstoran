import 'package:drift/drift.dart';

part 'local_database.g.dart';

class StoredDays extends Table {
  TextColumn get day => text()();
  TextColumn get layout => text()();
  DateTimeColumn get refreshedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}

class StoredReservations extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()();
  TextColumn get contract => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SignedInUsers extends Table {
  TextColumn get id => text()();
  TextColumn get contract => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredDays, StoredReservations, SignedInUsers])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  Future<void> clear() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
