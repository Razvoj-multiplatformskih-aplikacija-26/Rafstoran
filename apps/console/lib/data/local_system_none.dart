import 'local_system.dart';

LocalSystem createLocalSystem() => const _NoLocalSystem();

final class _NoLocalSystem implements LocalSystem {
  const _NoLocalSystem();

  @override
  bool get available => false;

  @override
  Future<List<CommandResult>> run(LocalTask task) async => const [];
}
