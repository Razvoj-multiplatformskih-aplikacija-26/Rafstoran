part of 'command_palette_bloc.dart';

final class CommandPaletteState extends Equatable {
  const CommandPaletteState({required this.entries, required this.query, required this.matches, this.highlighted = 0});

  factory CommandPaletteState.search(List<String> entries, String query) {
    final needle = query.trim().toLowerCase();
    return CommandPaletteState(
      entries: entries,
      query: query,
      matches: [
        for (var index = 0; index < entries.length; index++)
          if (needle.isEmpty || entries[index].toLowerCase().contains(needle)) index,
      ],
    );
  }

  final List<String> entries;
  final String query;
  final List<int> matches;
  final int highlighted;

  @override
  List<Object?> get props => [entries, query, matches, highlighted];

  @override
  String toString() => 'CommandPaletteState(${matches.length} matches, highlighted $highlighted)';

  int? get highlightedEntry => matches.isEmpty ? null : matches[highlighted];

  CommandPaletteState movedBy(int steps) => CommandPaletteState(
    entries: entries,
    query: query,
    matches: matches,
    highlighted: matches.isEmpty ? 0 : (highlighted + steps).clamp(0, matches.length - 1),
  );
}
