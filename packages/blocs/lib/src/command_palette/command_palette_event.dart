part of 'command_palette_bloc.dart';

sealed class CommandPaletteEvent {
  const CommandPaletteEvent();
}

final class CommandPaletteQueryChanged extends CommandPaletteEvent {
  const CommandPaletteQueryChanged(this.query);

  final String query;
}

final class CommandPaletteHighlightMoved extends CommandPaletteEvent {
  const CommandPaletteHighlightMoved(this.steps);

  final int steps;
}
