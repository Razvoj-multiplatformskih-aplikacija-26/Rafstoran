part of 'console_bloc.dart';

sealed class ConsoleEvent {
  const ConsoleEvent();
}

final class ScenarioRequested extends ConsoleEvent {
  const ScenarioRequested(this.scenario);

  final Scenario scenario;
}

final class CallerChanged extends ConsoleEvent {
  const CallerChanged(this.caller);

  final UserId caller;
}

final class NoteLengthChanged extends ConsoleEvent {
  const NoteLengthChanged(this.length);

  final int length;
}

final class CallSelected extends ConsoleEvent {
  const CallSelected(this.index);

  final int index;
}
