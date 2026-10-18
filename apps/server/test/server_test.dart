@Tags(['db'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:relic/relic.dart' show IOAdapter, RelicServer;
import 'package:server/server.dart';
import 'package:server/src/passwords.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

late Pool<void> database;
late RelicServer server;
late Uri base;
late String demoPassword;
late String jwtSecret;

const testGuests = 10;

Future<String> logIn(String login) async {
  final answer = await http.post(
    base.replace(path: ApiPaths.sessions),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(LoginDto(username: login, password: demoPassword).toJson()),
  );
  return SessionDto.fromJson(jsonDecode(answer.body) as Map<String, Object?>).token!;
}

Map<String, String> as(String token) => {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

Future<http.Response> reserve(String token, String guest, DateTime start, {int partySize = 10, String? note}) =>
    http.post(
      base.replace(path: ApiPaths.reservations),
      headers: as(token),
      body: jsonEncode(
        NewReservationDto(
          guest: GuestDto(kind: GuestDto.account, id: guest),
          start: start,
          partySize: partySize,
          note: note,
        ).toJson(),
      ),
    );

Future<DateTime> slotWithOneTableForTen() async {
  final day = DateTime.now().add(const Duration(days: 3));
  final answer = await http.get(
    base.replace(path: ApiPaths.slots, queryParameters: {ApiQuery.day: dayToJson(day), ApiQuery.partySize: '10'}),
    headers: as(await logIn('waiter1')),
  );
  final slots = [
    for (final slot in jsonDecode(answer.body) as List<Object?>) SlotDto.fromJson(slot! as Map<String, Object?>),
  ];
  return slots.firstWhere((slot) => slot.freeTables == 1).start;
}

Future<void> migrateWithDbmate(Uri databaseUrl) async {
  final insideCompose = databaseUrl.replace(host: 'db', port: 5432, path: '/rafstoran_test');
  final result = await Process.run('docker', [
    'compose',
    'run',
    '--rm',
    '-e',
    'DATABASE_URL=$insideCompose',
    'migrate',
  ], workingDirectory: '../..');
  if (result.exitCode != 0) throw StateError('dbmate failed: ${result.stderr}');
}

String codeOf(http.Response response) => (jsonDecode(response.body) as Map<String, Object?>)['code']! as String;

void main() {
  setUpAll(() async {
    initializeDomainTimeZones();
    final config = ServerConfig.fromEnvironment(serverEnvironment());
    demoPassword = config.demoPassword!;
    jwtSecret = config.jwtSecret;
    final admin = Pool<void>.withUrl(config.databaseUrl);
    await admin.execute('DROP DATABASE IF EXISTS rafstoran_test WITH (FORCE)');
    await admin.execute('CREATE DATABASE rafstoran_test');
    await admin.close();
    database = Pool<void>.withUrl(Uri.parse(config.databaseUrl).replace(path: '/rafstoran_test').toString());
    await migrateWithDbmate(Uri.parse(config.databaseUrl));
    await seedIfEmpty(database, now: DateTime.now(), demoPassword: demoPassword);
    final hash = await hashPassword(demoPassword);
    for (var n = 1; n <= testGuests; n++) {
      await database.execute(
        Sql.named(
          "INSERT INTO users (id, name, role, login, password_hash) VALUES (@id, @login, 'guest', @login, @hash)",
        ),
        parameters: {'id': 'u-test-$n', 'login': 'test$n', 'hash': hash},
      );
    }
    final store = RestaurantStore(database);
    const clock = SystemClock();
    final restaurant = PostgresRestaurant(store, clock: clock);
    final handlers = RestaurantHandlers(restaurant: restaurant, clock: clock);
    final sessions = SessionHandlers(
      accounts: AccountStore(database),
      secret: jwtSecret,
      ttl: const Duration(hours: 1),
    );
    server = RelicServer(() => IOAdapter.bind(InternetAddress.loopbackIPv4, port: 0));
    await server.mountAndStart(buildHandler(handlers, sessions, corsOrigins: const []));
    base = Uri.parse('http://localhost:${server.port}');
  });

  tearDownAll(() async {
    await server.close();
    await database.close();
  });

  test('two guests at the same moment for the last table: the database lets exactly one in', () async {
    final start = await slotWithOneTableForTen();
    final first = await logIn('test1');
    final second = await logIn('test2');

    final answers = await Future.wait([reserve(first, 'u-test-1', start), reserve(second, 'u-test-2', start)]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([201, 409]));
    expect(codeOf(answers.firstWhere((answer) => answer.statusCode == 409)), ErrorCodes.noTableAvailable);
  });

  test('guests booking one slot at the same moment each get a table while tables are free', () async {
    final start = await slotWithOneTableForTen();
    final waiter = await logIn('waiter1');
    final guests = ['u-test-3', 'u-test-4', 'u-test-5', 'u-test-6'];

    final answers = await Future.wait([for (final guest in guests) reserve(waiter, guest, start, partySize: 2)]);

    expect(answers.map((answer) => answer.statusCode), everyElement(201));
    final tables = {for (final answer in answers) (jsonDecode(answer.body) as Map<String, Object?>)['tableId']};
    expect(tables, hasLength(guests.length));
  });

  test('one guest booking the same slot from two devices at once keeps one table', () async {
    final start = await slotWithOneTableForTen();

    final phone = await logIn('test7');
    final browser = await logIn('test7');

    final answers = await Future.wait([
      reserve(phone, 'u-test-7', start, partySize: 2),
      reserve(browser, 'u-test-7', start, partySize: 2),
    ]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([201, 409]));
    expect(codeOf(answers.firstWhere((answer) => answer.statusCode == 409)), ErrorCodes.guestAlreadyBooked);
  });

  test('a note of 201 characters sent around the app is refused by the same rule as in the app', () async {
    final start = await slotWithOneTableForTen();

    final answer = await reserve(await logIn('guest1'), 'u-guest', start, partySize: 2, note: 'a' * 201);

    expect(answer.statusCode, 422);
    expect(codeOf(answer), ErrorCodes.noteTooLong);
  });

  test(
    'another guest changing the id in the call neither sees nor cancels the reservation; a guest may not confirm',
    () async {
      final owner = await logIn('test8');
      final created = await reserve(owner, 'u-test-8', await slotWithOneTableForTen(), partySize: 2);
      final id = (jsonDecode(created.body) as Map<String, Object?>)['id']! as String;
      final cancel = jsonEncode(const CancellationDto(reason: 'test').toJson());

      final intruder = await logIn('guest1');
      final seen = await http.get(base.replace(path: ApiPaths.reservation(id)), headers: as(intruder));
      final cancelled = await http.post(
        base.replace(path: ApiPaths.cancellation(id)),
        headers: as(intruder),
        body: cancel,
      );
      final confirmedByOwner = await http.post(base.replace(path: ApiPaths.confirmation(id)), headers: as(owner));

      expect([seen.statusCode, cancelled.statusCode, confirmedByOwner.statusCode], [404, 404, 403]);
    },
  );

  test('a token whose time has passed gets 401 and a code the clients understand', () async {
    final expired = JWT({
      'name': 'Gost',
      'role': 'guest',
      'exp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    }, subject: 'u-guest').sign(SecretKey(jwtSecret), noIssueAt: true);

    final answer = await http.get(base.replace(path: ApiPaths.reservationsOfGuest('u-guest')), headers: as(expired));

    expect(answer.statusCode, 401);
    expect(codeOf(answer), ErrorCodes.sessionExpired);
  });

  test('two staff changing the same reservation at once: one wins, the other is told it already changed', () async {
    final created = await reserve(await logIn('test9'), 'u-test-9', await slotWithOneTableForTen(), partySize: 2);
    final id = (jsonDecode(created.body) as Map<String, Object?>)['id']! as String;
    final waiter = as(await logIn('waiter1'));

    final answers = await Future.wait([
      http.post(base.replace(path: ApiPaths.confirmation(id)), headers: waiter),
      http.post(base.replace(path: ApiPaths.confirmation(id)), headers: waiter),
    ]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([200, 409]));
    expect(codeOf(answers.firstWhere((answer) => answer.statusCode == 409)), ErrorCodes.invalidTransition);
  });
}
