import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class PaletteCommand {
  const PaletteCommand({required this.label, required this.run, this.detail, this.icon = Icons.bolt_outlined});

  final String label;
  final String? detail;
  final IconData icon;
  final VoidCallback run;
}

Future<void> showCommandPalette(BuildContext context, List<PaletteCommand> commands) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black38,
    builder: (context) => Dialog(
      alignment: const Alignment(0, -0.6),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 440),
        child: BlocProvider(
          create: (_) => CommandPaletteBloc(
            entries: [for (final command in commands) '${command.label}\n${command.detail ?? ''}'],
          ),
          child: _CommandPalette(commands: commands),
        ),
      ),
    ),
  );
}

class _CommandPalette extends StatelessWidget {
  const _CommandPalette({required this.commands});

  final List<PaletteCommand> commands;

  void _run(BuildContext context, PaletteCommand command) {
    Navigator.pop(context);
    command.run();
  }

  KeyEventResult _onKey(BuildContext context, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final bloc = context.read<CommandPaletteBloc>();
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        bloc.add(const CommandPaletteHighlightMoved(1));
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        bloc.add(const CommandPaletteHighlightMoved(-1));
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter:
        if (bloc.state.highlightedEntry case final entry?) _run(context, commands[entry]);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<CommandPaletteBloc>().state;
    return Focus(
      onKeyEvent: (node, event) => _onKey(context, event),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Komanda ili rezervacija',
                counterText: '',
              ),
              onChanged: (text) => context.read<CommandPaletteBloc>().add(CommandPaletteQueryChanged(text)),
            ),
          ),
          Flexible(
            child: state.matches.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Nema rezultata.', style: theme.textTheme.bodyMedium),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: state.matches.length,
                    itemBuilder: (context, index) {
                      final command = commands[state.matches[index]];
                      return ListTile(
                        selected: index == state.highlighted,
                        selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                        leading: Icon(command.icon),
                        title: Text(command.label),
                        subtitle: command.detail == null ? null : Text(command.detail!),
                        onTap: () => _run(context, command),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
