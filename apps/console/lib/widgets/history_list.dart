import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../console/console_bloc.dart';
import '../data/exchange.dart';
import '../data/scenarios.dart';
import 'exchange_cards.dart';
import 'labels.dart';
import 'steps.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ConsoleBloc, ConsoleState>(
      builder: (context, state) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: Spacing.sm, bottom: Spacing.xs),
            child: Text('Istorija', style: theme.textTheme.titleSmall),
          ),
          for (final index in [for (var i = state.calls.length - 1; i >= 0; i--) i])
            HistoryRow(
              call: state.calls[index],
              selected: index == state.selected,
              onTap: () => context.read<ConsoleBloc>().add(CallSelected(index)),
            ),
        ],
      ),
    );
  }
}

class HistoryRow extends StatelessWidget {
  const HistoryRow({super.key, required this.call, required this.selected, required this.onTap});

  final Call call;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answers = switch (call.run) {
      Sent(:final exchange) => [exchange.answer],
      Ran() => const <Answer>[],
    };
    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: theme.colorScheme.secondaryContainer,
      onTap: onTap,
      leading: Text(clockLabel(call.at), style: theme.textTheme.labelLarge),
      title: Text('${stepOf(call.scenario).title} · ${whoLabel(call.scenario, call.caller)}'),
      trailing: Wrap(
        spacing: Spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final answer in answers)
            switch (answer) {
              Answered(:final status, :final elapsed) => Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: StatusChip(status: status),
                    ),
                    TextSpan(text: '  ${elapsed.inMilliseconds} ms'),
                  ],
                ),
              ),
              Unreachable() => Text('Server nije dostupan.', style: TextStyle(color: theme.colorScheme.error)),
            },
          if (call.run case Ran(:final commands))
            CommandChip(
              succeeded: commands.every((command) => command.succeeded),
              exitCode: commands.lastOrNull?.exitCode ?? 0,
            ),
        ],
      ),
    );
  }
}
