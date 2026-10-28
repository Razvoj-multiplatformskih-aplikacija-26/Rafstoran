import 'package:console/console/console_bloc.dart';
import 'package:console/data/exchange.dart';
import 'package:console/data/local_system.dart';
import 'package:console/data/scenarios.dart';
import 'package:console/data/server_calls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final class FakeLocalSystem implements LocalSystem {
  final tasks = <LocalTask>[];

  @override
  bool get available => true;

  @override
  Future<List<CommandResult>> run(LocalTask task) async {
    tasks.add(task);
    return [CommandResult(command: '$task', exitCode: 0, output: '')];
  }
}

ConsoleBloc consoleOver(http.Client client, LocalSystem local) {
  DateTime now() => DateTime(2026, 10, 29, 10);
  return ConsoleBloc(
    scenarios: ScenarioRunner(
      calls: ServerCalls(client: client, server: Uri.parse('http://localhost:8080')),
      local: local,
      now: now,
    ),
    now: now,
  );
}

void main() {
  test('a note the server refuses shows the same message as the app', () async {
    final client = MockClient(
      (request) async => http.Response(
        '{"type":"tag:raf.rs,2026:rafstoran/problem/note-too-long","title":"Note too long","status":422,'
        '"code":"note-too-long","value":201,"max":200}',
        422,
        headers: {'content-type': 'application/problem+json'},
      ),
    );
    final bloc = consoleOver(client, FakeLocalSystem())..add(const ScenarioRequested(LongNote(201)));
    final state = await bloc.stream.firstWhere((state) => state.calls.isNotEmpty);
    final answer = (state.current!.run as Sent).exchange.answer as Answered;
    expect(answer.status, 422);
    expect(answer.message, 'Napomena može imati najviše 200 znakova.');
    await bloc.close();
  });

  test('a reset waits until the server answers again', () async {
    final client = MockClient((request) async => http.Response('ok', 200));
    final local = FakeLocalSystem();
    final bloc = consoleOver(client, local)..add(const ScenarioRequested(LocalStep(LocalTask.reset)));
    final state = await bloc.stream.firstWhere((state) => state.calls.isNotEmpty);
    final commands = (state.current!.run as Ran).commands;
    expect(local.tasks, [LocalTask.reset]);
    expect([for (final command in commands) command.command], ['LocalTask.reset', 'GET /health']);
    await bloc.close();
  });
}
