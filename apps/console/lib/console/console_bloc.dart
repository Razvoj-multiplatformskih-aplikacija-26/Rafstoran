import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/scenarios.dart';

part 'console_event.dart';
part 'console_state.dart';

final class ConsoleBloc extends Bloc<ConsoleEvent, ConsoleState> {
  ConsoleBloc({required this.scenarios, required this.now}) : super(const ConsoleState()) {
    on<ScenarioRequested>((event, emit) async {
      emit(state.copyWith(running: true));
      final run = await scenarios.run(event.scenario, caller: state.caller);
      final call = Call(scenario: event.scenario, caller: state.caller, at: now(), run: run);
      emit(state.copyWith(running: false, calls: [...state.calls, call], selected: state.calls.length));
    });
    on<CallerChanged>((event, emit) => emit(state.copyWith(caller: event.caller)));
    on<NoteLengthChanged>((event, emit) => emit(state.copyWith(noteLength: event.length)));
    on<CallSelected>((event, emit) => emit(state.copyWith(selected: event.index)));
  }

  final ScenarioRunner scenarios;
  final DateTime Function() now;
}
