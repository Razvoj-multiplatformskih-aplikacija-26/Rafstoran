import 'dart:io';

import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';
import 'package:relic/relic.dart' show IOAdapter, RelicServer;
import 'package:server/server.dart';
import 'package:use_cases/use_cases.dart';

Future<void> main() async {
  initializeDomainTimeZones();
  final config = ServerConfig.fromEnvironment(serverEnvironment());
  final database = Pool<void>.withUrl(config.databaseUrl);
  final store = RestaurantStore(database);
  await seedIfEmpty(database, store, now: DateTime.now());
  const clock = SystemClock();
  final restaurant = PostgresRestaurant(store, clock: clock, raceDelay: config.raceDelay);
  final handlers = RestaurantHandlers(restaurant: restaurant, users: store, clock: clock);
  final server = RelicServer(() => IOAdapter.bind(InternetAddress(config.host), port: config.port));
  await server.mountAndStart(buildHandler(handlers, corsOrigins: config.corsOrigins));
  stdout.writeln('Rafstoran server on http://${config.host}:${config.port}');
}
