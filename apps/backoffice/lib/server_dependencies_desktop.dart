import 'package:api_client/api_client.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:use_cases/use_cases.dart';

import 'data/local/local_database.dart';
import 'data/local_first_schedule.dart';
import 'data/local_first_sessions.dart';
import 'data/secure_token_store.dart';
import 'dependencies.dart';

BackofficeDependencies serverDependencies({required Uri baseUri}) {
  const clock = SystemClock();
  final api = ApiClient(
    baseUri: baseUri,
    appVersion: BackofficeDependencies.appVersion,
    tokens: const SecureTokenStore(),
  );
  final database = LocalDatabase(
    driftDatabase(
      name: 'rafstoran',
      native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    ),
  );
  final schedule = LocalFirstSchedule(
    schedules: HttpScheduleRepository(api),
    reservations: HttpReservationRepository(api),
    database: database,
    clock: clock,
  );
  return BackofficeDependencies(
    clock: clock,
    schedules: schedule,
    reservations: schedule,
    slots: HttpSlotRepository(api),
    sessions: LocalFirstSessions(remote: HttpSessionRepository(api), database: database),
  );
}
