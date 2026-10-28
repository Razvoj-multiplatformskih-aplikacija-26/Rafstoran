part of 'console_bloc.dart';

final class Call extends Equatable {
  const Call({required this.scenario, required this.caller, required this.at, required this.run});

  final Scenario scenario;
  final UserId caller;
  final DateTime at;
  final Run run;

  @override
  List<Object?> get props => [scenario, caller, at, run];
}

final class ConsoleState extends Equatable {
  const ConsoleState({
    this.caller = const UserId('u-ana'),
    this.noteLength = 201,
    this.calls = const [],
    this.selected,
    this.running = false,
  });

  final UserId caller;
  final int noteLength;
  final List<Call> calls;
  final int? selected;
  final bool running;

  Call? get current => switch (selected) {
    final index? => calls[index],
    null => null,
  };

  ConsoleState copyWith({UserId? caller, int? noteLength, List<Call>? calls, int? selected, bool? running}) =>
      ConsoleState(
        caller: caller ?? this.caller,
        noteLength: noteLength ?? this.noteLength,
        calls: calls ?? this.calls,
        selected: selected ?? this.selected,
        running: running ?? this.running,
      );

  @override
  List<Object?> get props => [caller, noteLength, calls, selected, running];
}
