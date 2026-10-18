@Tags(['db'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:relic/relic.dart' show IOAdapter, RelicServer;
import 'package:server/server.dart';
import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

late Pool<void> database;
late RelicServer server;
late Uri base;

Future<http.Response> reserve(String guest, DateTime start, {int partySize = 10, String? note}) => http.post(
  base.replace(path: ApiPaths.reservations),
  headers: {'Content-Type': 'application/json', ApiHeaders.userId: guest},
  body: jsonEncode(NewReservationDto(guestId: guest, start: start, partySize: partySize, note: note).toJson()),
);

Future<DateTime> slotWithOneTableForTen() async {
  final day = DateTime.now().add(const Duration(days: 3));
  final answer = await http.get(
    base.replace(path: ApiPaths.slots, queryParameters: {ApiQuery.day: dayToJson(day), ApiQuery.partySize: '10'}),
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
    final databaseUrl = ServerConfig.fromEnvironment(serverEnvironment()).databaseUrl;
    final admin = Pool<void>.withUrl(databaseUrl);
    await admin.execute('DROP DATABASE IF EXISTS rafstoran_test WITH (FORCE)');
    await admin.execute('CREATE DATABASE rafstoran_test');
    await admin.close();
    database = Pool<void>.withUrl(Uri.parse(databaseUrl).replace(path: '/rafstoran_test').toString());
    await migrateWithDbmate(Uri.parse(databaseUrl));
    final store = RestaurantStore(database);
    await seedIfEmpty(database, store, now: DateTime.now());
    const clock = SystemClock();
    final restaurant = PostgresRestaurant(store, clock: clock, raceDelay: const Duration(milliseconds: 300));
    final handlers = RestaurantHandlers(restaurant: restaurant, users: store, clock: clock);
    server = RelicServer(() => IOAdapter.bind(InternetAddress.loopbackIPv4, port: 0));
    await server.mountAndStart(buildHandler(handlers, corsOrigins: const []));
    base = Uri.parse('http://localhost:${server.port}');
  });

  tearDownAll(() async {
    await server.close();
    await database.close();
  });

  test('two guests at the same moment for the last table: the database lets exactly one in', () async {
    final start = await slotWithOneTableForTen();

    final answers = await Future.wait([reserve('u-ana', start), reserve('u-marko', start)]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([201, 409]));
    expect(codeOf(answers.firstWhere((answer) => answer.statusCode == 409)), ErrorCodes.noTableAvailable);
  });

  test('a note of 201 characters sent around the app is refused by the same rule as in the app', () async {
    final start = await slotWithOneTableForTen();

    final answer = await reserve('u-guest', start, partySize: 2, note: 'a' * 201);

    expect(answer.statusCode, 422);
    expect(codeOf(answer), ErrorCodes.noteTooLong);
  });

  test('two staff changing the same reservation at once: one wins, the other is told it already changed', () async {
    final created = await reserve('u-guest', await slotWithOneTableForTen(), partySize: 2);
    final id = (jsonDecode(created.body) as Map<String, Object?>)['id']! as String;
    final asWaiter = {ApiHeaders.userId: 'u-waiter'};

    final answers = await Future.wait([
      http.post(base.replace(path: ApiPaths.confirmation(id)), headers: asWaiter),
      http.post(base.replace(path: ApiPaths.confirmation(id)), headers: asWaiter),
    ]);

    expect(answers.map((answer) => answer.statusCode), unorderedEquals([200, 409]));
    expect(codeOf(answers.firstWhere((answer) => answer.statusCode == 409)), ErrorCodes.invalidTransition);
  });
}
