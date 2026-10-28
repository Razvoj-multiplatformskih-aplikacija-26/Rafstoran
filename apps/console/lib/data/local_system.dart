import 'package:equatable/equatable.dart';

import 'local_system_none.dart' if (dart.library.io) 'local_system_process.dart' as platform;

enum LocalTask { reset, rebuildServer, startAdminer }

final class CommandResult extends Equatable {
  const CommandResult({required this.command, required this.exitCode, required this.output});

  final String command;
  final int exitCode;
  final String output;

  bool get succeeded => exitCode == 0;

  @override
  List<Object?> get props => [command, exitCode, output];
}

abstract interface class LocalSystem {
  bool get available;

  Future<List<CommandResult>> run(LocalTask task);
}

LocalSystem createLocalSystem() => platform.createLocalSystem();
