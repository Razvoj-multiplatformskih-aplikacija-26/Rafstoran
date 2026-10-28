import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

import 'exchange.dart';
import 'local_system.dart';
import 'server_calls.dart';

sealed class Scenario extends Equatable {
  const Scenario();

  @override
  List<Object?> get props => [];
}

final class HealthCheck extends Scenario {
  const HealthCheck();
}

final class TomorrowSlots extends Scenario {
  const TomorrowSlots();
}

final class NewReservation extends Scenario {
  const NewReservation();
}

final class LongNote extends Scenario {
  const LongNote(this.length);

  final int length;

  @override
  List<Object?> get props => [length];
}

final class LocalStep extends Scenario {
  const LocalStep(this.task);

  final LocalTask task;

  @override
  List<Object?> get props => [task];
}

sealed class Run extends Equatable {
  const Run();
}

final class Sent extends Run {
  const Sent(this.exchange);

  final Exchange exchange;

  @override
  List<Object?> get props => [exchange];
}

final class Ran extends Run {
  const Ran(this.commands);

  final List<CommandResult> commands;

  @override
  List<Object?> get props => [commands];
}

final class ScenarioRunner {
  ScenarioRunner({required this.calls, required this.local, required this.now});

  final ServerCalls calls;
  final LocalSystem local;
  final DateTime Function() now;

  Future<Run> run(Scenario scenario, {required UserId caller}) async => switch (scenario) {
    HealthCheck() => Sent(await calls.get(ApiPaths.health)),
    TomorrowSlots() => Sent(
      await calls.get(
        ApiPaths.slots,
        query: {ApiQuery.day: dayToJson(_tomorrow()), ApiQuery.partySize: '2'},
        caller: caller,
      ),
    ),
    NewReservation() => Sent(await _reserve(caller, hour: 15, note: 'Sto pored prozora')),
    LongNote(:final length) => Sent(await _reserve(caller, hour: 17, note: 'a' * length)),
    LocalStep(:final task) => Ran(await _local(task)),
  };

  Future<List<CommandResult>> _local(LocalTask task) async {
    final results = [...await local.run(task)];
    final restartsServer = task == LocalTask.reset || task == LocalTask.rebuildServer;
    if (restartsServer && results.every((result) => result.succeeded)) results.add(await _serverReady());
    return results;
  }

  Future<CommandResult> _serverReady() async {
    for (var attempt = 0; attempt < 60; attempt++) {
      if ((await calls.get(ApiPaths.health)).answer case Answered(status: 200)) {
        return const CommandResult(command: 'GET /health', exitCode: 0, output: 'ok');
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return const CommandResult(command: 'GET /health', exitCode: 1, output: 'Server nije dostupan.');
  }

  DateTime _tomorrow() {
    final today = now();
    return DateTime(today.year, today.month, today.day + 1);
  }

  Future<Exchange> _reserve(UserId caller, {required int hour, required String note}) {
    final day = _tomorrow();
    final start = DateTime(day.year, day.month, day.day, hour).toUtc();
    return calls.post(
      ApiPaths.reservations,
      NewReservationDto(start: start, partySize: 2, note: note).toJson(),
      caller: caller,
    );
  }
}
