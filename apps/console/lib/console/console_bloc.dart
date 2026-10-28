import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/scenarios.dart';

part 'console_event.dart';
part 'console_state.dart';

final class ConsoleBloc extends Bloc<ConsoleEvent, ConsoleState> {
  ConsoleBloc({required this.scenarios, required this.now}) : super(const ConsoleState()) {
    on<ScenarioRequested>((event, emit) async {
      final account = state.account;
      emit(state.copyWith(running: true));
      final run = await scenarios.run(
        event.scenario,
        account: account,
        password: state.password,
        token: state.tokens[account],
      );
      final call = Call(scenario: event.scenario, account: account, at: now(), run: run);
      emit(
        state.copyWith(
          running: false,
          calls: [...state.calls, call],
          selected: state.calls.length,
          tokens: _tokensAfter(event.scenario, run, account),
        ),
      );
    });
    on<AccountChanged>((event, emit) => emit(state.copyWith(account: event.account)));
    on<PasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<NoteLengthChanged>((event, emit) => emit(state.copyWith(noteLength: event.length)));
    on<CallSelected>((event, emit) => emit(state.copyWith(selected: event.index)));
  }

  final ScenarioRunner scenarios;
  final DateTime Function() now;

  Map<String, String> _tokensAfter(Scenario scenario, Run run, String account) => switch ((scenario, run)) {
    (LogIn(), Sent(:final exchange)) => {
      for (final MapEntry(:key, :value) in state.tokens.entries)
        if (key != account) key: value,
      account: ?sessionTokenOf(exchange),
    },
    _ => state.tokens,
  };
}
