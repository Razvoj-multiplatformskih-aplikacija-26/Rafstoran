import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        child: _CommandPalette(commands: commands),
      ),
    ),
  );
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette({required this.commands});

  final List<PaletteCommand> commands;

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _highlighted = 0;

  List<PaletteCommand> get _matches {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return widget.commands;
    return widget.commands
        .where((c) => c.label.toLowerCase().contains(query) || (c.detail?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _run(PaletteCommand command) {
    Navigator.pop(context);
    command.run();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final matches = _matches;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlighted = (_highlighted + 1).clamp(0, matches.isEmpty ? 0 : matches.length - 1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _highlighted = (_highlighted - 1).clamp(0, matches.isEmpty ? 0 : matches.length - 1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (matches.isNotEmpty) _run(matches[_highlighted.clamp(0, matches.length - 1)]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _matches;
    final highlighted = matches.isEmpty ? -1 : _highlighted.clamp(0, matches.length - 1);
    return Focus(
      onKeyEvent: _onKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Komanda ili rezervacija',
                counterText: '',
              ),
              onChanged: (_) => setState(() => _highlighted = 0),
            ),
          ),
          Flexible(
            child: matches.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Nema rezultata.', style: theme.textTheme.bodyMedium),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final command = matches[index];
                      final isHighlighted = index == highlighted;
                      return ListTile(
                        selected: isHighlighted,
                        selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                        leading: Icon(command.icon),
                        title: Text(command.label),
                        subtitle: command.detail == null ? null : Text(command.detail!),
                        onTap: () => _run(command),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
