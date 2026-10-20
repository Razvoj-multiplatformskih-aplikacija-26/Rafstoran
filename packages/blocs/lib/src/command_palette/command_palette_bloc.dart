import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'command_palette_event.dart';
part 'command_palette_state.dart';

final class CommandPaletteBloc extends Bloc<CommandPaletteEvent, CommandPaletteState> {
  CommandPaletteBloc({required List<String> entries}) : super(CommandPaletteState.search(entries, '')) {
    on<CommandPaletteQueryChanged>((event, emit) => emit(CommandPaletteState.search(state.entries, event.query)));
    on<CommandPaletteHighlightMoved>((event, emit) => emit(state.movedBy(event.steps)));
  }
}
