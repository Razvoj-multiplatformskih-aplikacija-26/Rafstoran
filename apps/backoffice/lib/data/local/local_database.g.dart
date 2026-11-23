// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $StoredDaysTable extends StoredDays with TableInfo<$StoredDaysTable, StoredDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _layoutMeta = const VerificationMeta('layout');
  @override
  late final GeneratedColumn<String> layout = GeneratedColumn<String>(
    'layout',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refreshedAtMeta = const VerificationMeta('refreshedAt');
  @override
  late final GeneratedColumn<DateTime> refreshedAt = GeneratedColumn<DateTime>(
    'refreshed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, layout, refreshedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_days';
  @override
  VerificationContext validateIntegrity(Insertable<StoredDay> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('layout')) {
      context.handle(_layoutMeta, layout.isAcceptableOrUnknown(data['layout']!, _layoutMeta));
    } else if (isInserting) {
      context.missing(_layoutMeta);
    }
    if (data.containsKey('refreshed_at')) {
      context.handle(_refreshedAtMeta, refreshedAt.isAcceptableOrUnknown(data['refreshed_at']!, _refreshedAtMeta));
    } else if (isInserting) {
      context.missing(_refreshedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  StoredDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDay(
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      layout: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}layout'])!,
      refreshedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}refreshed_at'])!,
    );
  }

  @override
  $StoredDaysTable createAlias(String alias) {
    return $StoredDaysTable(attachedDatabase, alias);
  }
}

class StoredDay extends DataClass implements Insertable<StoredDay> {
  final String day;
  final String layout;
  final DateTime refreshedAt;
  const StoredDay({required this.day, required this.layout, required this.refreshedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['layout'] = Variable<String>(layout);
    map['refreshed_at'] = Variable<DateTime>(refreshedAt);
    return map;
  }

  StoredDaysCompanion toCompanion(bool nullToAbsent) {
    return StoredDaysCompanion(day: Value(day), layout: Value(layout), refreshedAt: Value(refreshedAt));
  }

  factory StoredDay.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDay(
      day: serializer.fromJson<String>(json['day']),
      layout: serializer.fromJson<String>(json['layout']),
      refreshedAt: serializer.fromJson<DateTime>(json['refreshedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'layout': serializer.toJson<String>(layout),
      'refreshedAt': serializer.toJson<DateTime>(refreshedAt),
    };
  }

  StoredDay copyWith({String? day, String? layout, DateTime? refreshedAt}) =>
      StoredDay(day: day ?? this.day, layout: layout ?? this.layout, refreshedAt: refreshedAt ?? this.refreshedAt);
  StoredDay copyWithCompanion(StoredDaysCompanion data) {
    return StoredDay(
      day: data.day.present ? data.day.value : this.day,
      layout: data.layout.present ? data.layout.value : this.layout,
      refreshedAt: data.refreshedAt.present ? data.refreshedAt.value : this.refreshedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDay(')
          ..write('day: $day, ')
          ..write('layout: $layout, ')
          ..write('refreshedAt: $refreshedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, layout, refreshedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDay &&
          other.day == this.day &&
          other.layout == this.layout &&
          other.refreshedAt == this.refreshedAt);
}

class StoredDaysCompanion extends UpdateCompanion<StoredDay> {
  final Value<String> day;
  final Value<String> layout;
  final Value<DateTime> refreshedAt;
  final Value<int> rowid;
  const StoredDaysCompanion({
    this.day = const Value.absent(),
    this.layout = const Value.absent(),
    this.refreshedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredDaysCompanion.insert({
    required String day,
    required String layout,
    required DateTime refreshedAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       layout = Value(layout),
       refreshedAt = Value(refreshedAt);
  static Insertable<StoredDay> custom({
    Expression<String>? day,
    Expression<String>? layout,
    Expression<DateTime>? refreshedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (layout != null) 'layout': layout,
      if (refreshedAt != null) 'refreshed_at': refreshedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredDaysCompanion copyWith({
    Value<String>? day,
    Value<String>? layout,
    Value<DateTime>? refreshedAt,
    Value<int>? rowid,
  }) {
    return StoredDaysCompanion(
      day: day ?? this.day,
      layout: layout ?? this.layout,
      refreshedAt: refreshedAt ?? this.refreshedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (layout.present) {
      map['layout'] = Variable<String>(layout.value);
    }
    if (refreshedAt.present) {
      map['refreshed_at'] = Variable<DateTime>(refreshedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredDaysCompanion(')
          ..write('day: $day, ')
          ..write('layout: $layout, ')
          ..write('refreshedAt: $refreshedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredReservationsTable extends StoredReservations with TableInfo<$StoredReservationsTable, StoredReservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredReservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractMeta = const VerificationMeta('contract');
  @override
  late final GeneratedColumn<String> contract = GeneratedColumn<String>(
    'contract',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, contract];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_reservations';
  @override
  VerificationContext validateIntegrity(Insertable<StoredReservation> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('contract')) {
      context.handle(_contractMeta, contract.isAcceptableOrUnknown(data['contract']!, _contractMeta));
    } else if (isInserting) {
      context.missing(_contractMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredReservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredReservation(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      contract: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}contract'])!,
    );
  }

  @override
  $StoredReservationsTable createAlias(String alias) {
    return $StoredReservationsTable(attachedDatabase, alias);
  }
}

class StoredReservation extends DataClass implements Insertable<StoredReservation> {
  final String id;
  final String day;
  final String contract;
  const StoredReservation({required this.id, required this.day, required this.contract});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['contract'] = Variable<String>(contract);
    return map;
  }

  StoredReservationsCompanion toCompanion(bool nullToAbsent) {
    return StoredReservationsCompanion(id: Value(id), day: Value(day), contract: Value(contract));
  }

  factory StoredReservation.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredReservation(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      contract: serializer.fromJson<String>(json['contract']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'contract': serializer.toJson<String>(contract),
    };
  }

  StoredReservation copyWith({String? id, String? day, String? contract}) =>
      StoredReservation(id: id ?? this.id, day: day ?? this.day, contract: contract ?? this.contract);
  StoredReservation copyWithCompanion(StoredReservationsCompanion data) {
    return StoredReservation(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      contract: data.contract.present ? data.contract.value : this.contract,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredReservation(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('contract: $contract')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, contract);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredReservation && other.id == this.id && other.day == this.day && other.contract == this.contract);
}

class StoredReservationsCompanion extends UpdateCompanion<StoredReservation> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> contract;
  final Value<int> rowid;
  const StoredReservationsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.contract = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredReservationsCompanion.insert({
    required String id,
    required String day,
    required String contract,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       contract = Value(contract);
  static Insertable<StoredReservation> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? contract,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (contract != null) 'contract': contract,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredReservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String>? contract,
    Value<int>? rowid,
  }) {
    return StoredReservationsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      contract: contract ?? this.contract,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (contract.present) {
      map['contract'] = Variable<String>(contract.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredReservationsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('contract: $contract, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SignedInUsersTable extends SignedInUsers with TableInfo<$SignedInUsersTable, SignedInUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignedInUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractMeta = const VerificationMeta('contract');
  @override
  late final GeneratedColumn<String> contract = GeneratedColumn<String>(
    'contract',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, contract];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signed_in_users';
  @override
  VerificationContext validateIntegrity(Insertable<SignedInUser> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('contract')) {
      context.handle(_contractMeta, contract.isAcceptableOrUnknown(data['contract']!, _contractMeta));
    } else if (isInserting) {
      context.missing(_contractMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SignedInUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SignedInUser(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contract: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}contract'])!,
    );
  }

  @override
  $SignedInUsersTable createAlias(String alias) {
    return $SignedInUsersTable(attachedDatabase, alias);
  }
}

class SignedInUser extends DataClass implements Insertable<SignedInUser> {
  final String id;
  final String contract;
  const SignedInUser({required this.id, required this.contract});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contract'] = Variable<String>(contract);
    return map;
  }

  SignedInUsersCompanion toCompanion(bool nullToAbsent) {
    return SignedInUsersCompanion(id: Value(id), contract: Value(contract));
  }

  factory SignedInUser.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SignedInUser(
      id: serializer.fromJson<String>(json['id']),
      contract: serializer.fromJson<String>(json['contract']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<String>(id), 'contract': serializer.toJson<String>(contract)};
  }

  SignedInUser copyWith({String? id, String? contract}) =>
      SignedInUser(id: id ?? this.id, contract: contract ?? this.contract);
  SignedInUser copyWithCompanion(SignedInUsersCompanion data) {
    return SignedInUser(
      id: data.id.present ? data.id.value : this.id,
      contract: data.contract.present ? data.contract.value : this.contract,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SignedInUser(')
          ..write('id: $id, ')
          ..write('contract: $contract')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contract);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SignedInUser && other.id == this.id && other.contract == this.contract);
}

class SignedInUsersCompanion extends UpdateCompanion<SignedInUser> {
  final Value<String> id;
  final Value<String> contract;
  final Value<int> rowid;
  const SignedInUsersCompanion({
    this.id = const Value.absent(),
    this.contract = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SignedInUsersCompanion.insert({required String id, required String contract, this.rowid = const Value.absent()})
    : id = Value(id),
      contract = Value(contract);
  static Insertable<SignedInUser> custom({
    Expression<String>? id,
    Expression<String>? contract,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contract != null) 'contract': contract,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SignedInUsersCompanion copyWith({Value<String>? id, Value<String>? contract, Value<int>? rowid}) {
    return SignedInUsersCompanion(id: id ?? this.id, contract: contract ?? this.contract, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contract.present) {
      map['contract'] = Variable<String>(contract.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignedInUsersCompanion(')
          ..write('id: $id, ')
          ..write('contract: $contract, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $StoredDaysTable storedDays = $StoredDaysTable(this);
  late final $StoredReservationsTable storedReservations = $StoredReservationsTable(this);
  late final $SignedInUsersTable signedInUsers = $SignedInUsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [storedDays, storedReservations, signedInUsers];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$StoredDaysTableCreateCompanionBuilder = StoredDaysCompanion Function({
  required String day,
  required String layout,
  required DateTime refreshedAt,
  Value<int> rowid,
});
typedef $$StoredDaysTableUpdateCompanionBuilder = StoredDaysCompanion Function({
  Value<String> day,
  Value<String> layout,
  Value<DateTime> refreshedAt,
  Value<int> rowid,
});

class $$StoredDaysTableFilterComposer extends Composer<_$LocalDatabase, $StoredDaysTable> {
  $$StoredDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get refreshedAt =>
      $composableBuilder(column: $table.refreshedAt, builder: (column) => ColumnFilters(column));
}

class $$StoredDaysTableOrderingComposer extends Composer<_$LocalDatabase, $StoredDaysTable> {
  $$StoredDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get refreshedAt =>
      $composableBuilder(column: $table.refreshedAt, builder: (column) => ColumnOrderings(column));
}

class $$StoredDaysTableAnnotationComposer extends Composer<_$LocalDatabase, $StoredDaysTable> {
  $$StoredDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get layout => $composableBuilder(column: $table.layout, builder: (column) => column);

  GeneratedColumn<DateTime> get refreshedAt =>
      $composableBuilder(column: $table.refreshedAt, builder: (column) => column);
}

class $$StoredDaysTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $StoredDaysTable,
          StoredDay,
          $$StoredDaysTableFilterComposer,
          $$StoredDaysTableOrderingComposer,
          $$StoredDaysTableAnnotationComposer,
          $$StoredDaysTableCreateCompanionBuilder,
          $$StoredDaysTableUpdateCompanionBuilder,
          (StoredDay, BaseReferences<_$LocalDatabase, $StoredDaysTable, StoredDay>),
          StoredDay,
          PrefetchHooks Function()
        > {
  $$StoredDaysTableTableManager(_$LocalDatabase db, $StoredDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StoredDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StoredDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$StoredDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<String> layout = const Value.absent(),
            Value<DateTime> refreshedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StoredDaysCompanion(day: day, layout: layout, refreshedAt: refreshedAt, rowid: rowid),
          createCompanionCallback: ({
            required String day,
            required String layout,
            required DateTime refreshedAt,
            Value<int> rowid = const Value.absent(),
          }) => StoredDaysCompanion.insert(day: day, layout: layout, refreshedAt: refreshedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $StoredDaysTable,
      StoredDay,
      $$StoredDaysTableFilterComposer,
      $$StoredDaysTableOrderingComposer,
      $$StoredDaysTableAnnotationComposer,
      $$StoredDaysTableCreateCompanionBuilder,
      $$StoredDaysTableUpdateCompanionBuilder,
      (StoredDay, BaseReferences<_$LocalDatabase, $StoredDaysTable, StoredDay>),
      StoredDay,
      PrefetchHooks Function()
    >;
typedef $$StoredReservationsTableCreateCompanionBuilder = StoredReservationsCompanion Function({
  required String id,
  required String day,
  required String contract,
  Value<int> rowid,
});
typedef $$StoredReservationsTableUpdateCompanionBuilder = StoredReservationsCompanion Function({
  Value<String> id,
  Value<String> day,
  Value<String> contract,
  Value<int> rowid,
});

class $$StoredReservationsTableFilterComposer extends Composer<_$LocalDatabase, $StoredReservationsTable> {
  $$StoredReservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contract =>
      $composableBuilder(column: $table.contract, builder: (column) => ColumnFilters(column));
}

class $$StoredReservationsTableOrderingComposer extends Composer<_$LocalDatabase, $StoredReservationsTable> {
  $$StoredReservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contract =>
      $composableBuilder(column: $table.contract, builder: (column) => ColumnOrderings(column));
}

class $$StoredReservationsTableAnnotationComposer extends Composer<_$LocalDatabase, $StoredReservationsTable> {
  $$StoredReservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get contract => $composableBuilder(column: $table.contract, builder: (column) => column);
}

class $$StoredReservationsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $StoredReservationsTable,
          StoredReservation,
          $$StoredReservationsTableFilterComposer,
          $$StoredReservationsTableOrderingComposer,
          $$StoredReservationsTableAnnotationComposer,
          $$StoredReservationsTableCreateCompanionBuilder,
          $$StoredReservationsTableUpdateCompanionBuilder,
          (StoredReservation, BaseReferences<_$LocalDatabase, $StoredReservationsTable, StoredReservation>),
          StoredReservation,
          PrefetchHooks Function()
        > {
  $$StoredReservationsTableTableManager(_$LocalDatabase db, $StoredReservationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StoredReservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StoredReservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$StoredReservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<String> contract = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => StoredReservationsCompanion(id: id, day: day, contract: contract, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String day,
            required String contract,
            Value<int> rowid = const Value.absent(),
          }) => StoredReservationsCompanion.insert(id: id, day: day, contract: contract, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredReservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $StoredReservationsTable,
      StoredReservation,
      $$StoredReservationsTableFilterComposer,
      $$StoredReservationsTableOrderingComposer,
      $$StoredReservationsTableAnnotationComposer,
      $$StoredReservationsTableCreateCompanionBuilder,
      $$StoredReservationsTableUpdateCompanionBuilder,
      (StoredReservation, BaseReferences<_$LocalDatabase, $StoredReservationsTable, StoredReservation>),
      StoredReservation,
      PrefetchHooks Function()
    >;
typedef $$SignedInUsersTableCreateCompanionBuilder = SignedInUsersCompanion Function({
  required String id,
  required String contract,
  Value<int> rowid,
});
typedef $$SignedInUsersTableUpdateCompanionBuilder = SignedInUsersCompanion Function({
  Value<String> id,
  Value<String> contract,
  Value<int> rowid,
});

class $$SignedInUsersTableFilterComposer extends Composer<_$LocalDatabase, $SignedInUsersTable> {
  $$SignedInUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contract =>
      $composableBuilder(column: $table.contract, builder: (column) => ColumnFilters(column));
}

class $$SignedInUsersTableOrderingComposer extends Composer<_$LocalDatabase, $SignedInUsersTable> {
  $$SignedInUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contract =>
      $composableBuilder(column: $table.contract, builder: (column) => ColumnOrderings(column));
}

class $$SignedInUsersTableAnnotationComposer extends Composer<_$LocalDatabase, $SignedInUsersTable> {
  $$SignedInUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contract => $composableBuilder(column: $table.contract, builder: (column) => column);
}

class $$SignedInUsersTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SignedInUsersTable,
          SignedInUser,
          $$SignedInUsersTableFilterComposer,
          $$SignedInUsersTableOrderingComposer,
          $$SignedInUsersTableAnnotationComposer,
          $$SignedInUsersTableCreateCompanionBuilder,
          $$SignedInUsersTableUpdateCompanionBuilder,
          (SignedInUser, BaseReferences<_$LocalDatabase, $SignedInUsersTable, SignedInUser>),
          SignedInUser,
          PrefetchHooks Function()
        > {
  $$SignedInUsersTableTableManager(_$LocalDatabase db, $SignedInUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SignedInUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SignedInUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SignedInUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> contract = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SignedInUsersCompanion(id: id, contract: contract, rowid: rowid),
          createCompanionCallback: ({
            required String id,
            required String contract,
            Value<int> rowid = const Value.absent(),
          }) => SignedInUsersCompanion.insert(id: id, contract: contract, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SignedInUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SignedInUsersTable,
      SignedInUser,
      $$SignedInUsersTableFilterComposer,
      $$SignedInUsersTableOrderingComposer,
      $$SignedInUsersTableAnnotationComposer,
      $$SignedInUsersTableCreateCompanionBuilder,
      $$SignedInUsersTableUpdateCompanionBuilder,
      (SignedInUser, BaseReferences<_$LocalDatabase, $SignedInUsersTable, SignedInUser>),
      SignedInUser,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$StoredDaysTableTableManager get storedDays => $$StoredDaysTableTableManager(_db, _db.storedDays);
  $$StoredReservationsTableTableManager get storedReservations =>
      $$StoredReservationsTableTableManager(_db, _db.storedReservations);
  $$SignedInUsersTableTableManager get signedInUsers => $$SignedInUsersTableTableManager(_db, _db.signedInUsers);
}
