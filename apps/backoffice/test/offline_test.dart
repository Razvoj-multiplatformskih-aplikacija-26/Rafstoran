import 'dart:async';

import 'package:backoffice/data/fake_schedule.dart';
import 'package:backoffice/data/local/local_database.dart';
import 'package:backoffice/data/local_first_schedule.dart';
import 'package:backoffice/data/local_first_sessions.dart';
import 'package:domain/domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:use_cases/use_cases.dart';

import 'support.dart';

final class FakeServerSessions implements SessionRepository {
  bool reachable = true;
  final _expirations = StreamController<void>.broadcast();

  void expire() => _expirations.add(null);

  @override
  Future<User?> logIn({required String username, required String password}) async => staffWaiter;

  @override
  Future<User?> current() async {
    if (!reachable) throw const RepositoryException('offline', failure: RepositoryFailure.unreachable);
    return staffWaiter;
  }

  @override
  Future<void> logOut() async {
    if (!reachable) throw const RepositoryException('offline', failure: RepositoryFailure.unreachable);
  }

  @override
  Stream<void> get expirations => _expirations.stream;
}

void main() {
  setUpAll(initializeTestEnvironment);

  final clock = FixedClock(fridayAfternoon);
  late final today = restaurantDay(fridayAfternoon);

  late LocalDatabase database;
  late FakeServerSessions server;
  late LocalFirstSessions sessions;
  late FakeSchedule restaurant;
  late LocalFirstSchedule schedule;

  LocalFirstSchedule scheduleOver(FakeSchedule restaurant) =>
      LocalFirstSchedule(schedules: restaurant, reservations: restaurant, database: database, clock: clock);

  setUp(() async {
    database = LocalDatabase(NativeDatabase.memory());
    server = FakeServerSessions();
    sessions = LocalFirstSessions(remote: server, database: database);
    restaurant = FakeSchedule(clock: clock, latency: Duration.zero);
    schedule = scheduleOver(restaurant);
    await sessions.logIn(username: 'waiter1', password: 'secret');
  });
  tearDown(() => database.close());

  Future<bool> nothingLeftOnTheComputer() async =>
      (await database.select(database.storedDays).get()).isEmpty &&
      (await database.select(database.storedReservations).get()).isEmpty &&
      (await database.select(database.signedInUsers).get()).isEmpty;

  test('the last schedule stays readable when the server cannot be reached', () async {
    await schedule.refresh(today);

    restaurant.failingRequests = 1;
    await expectLater(schedule.refresh(today), throwsA(isA<RepositoryException>()));

    final stored = await schedule.watch(today).first;
    expect(stored?.schedule.reservations, isNotEmpty);
    expect(stored?.refreshedAt, fridayAfternoon);
  });

  test('a day that was never loaded has no stored schedule', () async {
    expect(await schedule.watch(today).first, isNull);
  });

  test('a status change the server accepted reaches the stored day without another refresh', () async {
    await schedule.refresh(today);
    final pending = (await schedule.watch(today).first)!.schedule.reservations.firstWhere((r) => r.status is Pending);

    final confirmed = await ConfirmReservation(reservations: schedule, clock: clock)(id: pending.id, by: staffWaiter);
    expect(confirmed.isSuccess, isTrue);

    final stored = await schedule.watch(today).first;
    expect(stored!.schedule.reservations.firstWhere((r) => r.id == pending.id).status, isA<Confirmed>());
  });

  test('a staff member who was signed in starts the backoffice without a network', () async {
    server.reachable = false;

    expect(await sessions.current(), staffWaiter);
  });

  test('logging out leaves no schedule on the computer, even without a network', () async {
    await schedule.refresh(today);

    server.reachable = false;
    await expectLater(sessions.logOut(), throwsA(isA<RepositoryException>()));

    expect(await nothingLeftOnTheComputer(), isTrue);
  });

  test('an expired session leaves no schedule on the computer', () async {
    await schedule.refresh(today);

    final reported = sessions.expirations.first;
    server.expire();
    await reported;
    server.reachable = false;

    expect(await nothingLeftOnTheComputer(), isTrue);
    expect(await sessions.current(), isNull);
  });

  test('a refresh that answers after logout does not bring the schedule back', () async {
    final slow = scheduleOver(FakeSchedule(clock: clock, latency: const Duration(milliseconds: 50)));

    final refresh = slow.refresh(today);
    await sessions.logOut();
    await refresh;

    expect(await nothingLeftOnTheComputer(), isTrue);
  });
}
