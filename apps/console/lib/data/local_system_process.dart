import 'dart:convert';
import 'dart:io';

import 'local_system.dart';

const adminerAddress =
    'http://127.0.0.1:8082/?pgsql=db&username=rafstoran&db=rafstoran&ns=public&select=reservations'
    '&order%5B0%5D=created_at&desc%5B0%5D=1';

LocalSystem createLocalSystem() => ProcessLocalSystem.find();

final class ProcessLocalSystem implements LocalSystem {
  ProcessLocalSystem({required this.root, required this.docker, required this.environment});

  factory ProcessLocalSystem.find() =>
      ProcessLocalSystem(root: _repositoryRoot(), docker: _docker(), environment: _environment());

  final Directory? root;
  final String docker;
  final Map<String, String> environment;

  @override
  bool get available => root != null;

  @override
  Future<List<CommandResult>> run(LocalTask task) async {
    final results = <CommandResult>[];
    for (final step in _steps(task)) {
      final result = await _run(step);
      results.add(result);
      if (!result.succeeded) break;
    }
    return results;
  }

  List<_Step> _steps(LocalTask task) => switch (task) {
    LocalTask.reset => [
      _Step(docker, ['compose', 'down', '-v']),
      _Step(docker, ['compose', 'up', '-d']),
    ],
    LocalTask.rebuildServer => [
      _Step(docker, ['compose', 'up', '-d', '--build', 'server']),
    ],
    LocalTask.startAdminer => [
      _Step(docker, ['compose', '--profile', 'tools', 'up', '-d', 'adminer']),
      _Step(Platform.isWindows ? 'explorer.exe' : '/usr/bin/open', [adminerAddress], shown: 'Adminer u pregledaču'),
    ],
  };

  Future<CommandResult> _run(_Step step) async {
    final command = step.display;
    try {
      final process = await Process.start(
        step.executable,
        step.arguments,
        workingDirectory: root!.path,
        environment: environment,
        includeParentEnvironment: false,
      );
      await process.stdin.close();
      final output = await Future.wait([
        process.stdout.transform(utf8.decoder).join(),
        process.stderr.transform(utf8.decoder).join(),
      ]);
      final exitCode = await process.exitCode;
      final text = output.join().trim();
      return CommandResult(command: command, exitCode: exitCode, output: text);
    } on Exception catch (error) {
      return CommandResult(command: command, exitCode: -1, output: '$error');
    }
  }

  static Directory? _repositoryRoot() {
    for (final start in [Directory.current, File(Platform.resolvedExecutable).parent]) {
      var directory = start.absolute;
      while (true) {
        if (File('${directory.path}/compose.yaml').existsSync() &&
            Directory('${directory.path}/apps/server').existsSync()) {
          return directory;
        }
        if (directory.parent.path == directory.path) break;
        directory = directory.parent;
      }
    }
    return null;
  }

  static String _docker() {
    if (Platform.isWindows) return 'docker';
    const candidates = [
      '/usr/local/bin/docker',
      '/opt/homebrew/bin/docker',
      '/Applications/Docker.app/Contents/Resources/bin/docker',
    ];
    return candidates.firstWhere((path) => File(path).existsSync(), orElse: () => 'docker');
  }

  static Map<String, String> _environment() {
    final environment = {
      for (final entry in Platform.environment.entries)
        if (!_composeVariables.contains(entry.key)) entry.key: entry.value,
    };
    if (Platform.isWindows) return environment;
    final home = environment['HOME'] ?? '';
    final path = environment['PATH'] ?? '/usr/bin:/bin';
    return {
      ...environment,
      'PATH':
          '/usr/local/bin:/opt/homebrew/bin:$home/.docker/bin:/Applications/Docker.app/Contents/Resources/bin:$path',
    };
  }

  static const _composeVariables = {
    'POSTGRES_USER',
    'POSTGRES_PASSWORD',
    'POSTGRES_DB',
    'POSTGRES_PORT',
    'SERVER_PORT',
    'ADMINER_PORT',
    'CORS_ORIGINS',
    'DATABASE_URL',
  };
}

final class _Step {
  _Step(this.executable, this.arguments, {String? shown})
    : display =
          shown ??
          [
            if (executable.endsWith('docker')) 'docker' else executable,
            ...arguments.map((argument) => argument.contains(' ') ? "'$argument'" : argument),
          ].join(' ');

  final String executable;
  final List<String> arguments;
  final String display;
}
