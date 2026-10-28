import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../console/console_bloc.dart';
import '../data/local_system.dart';
import '../data/scenarios.dart';
import 'exchange_cards.dart';
import 'labels.dart';
import 'steps.dart';

class CallView extends StatelessWidget {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ConsoleBloc, ConsoleState>(
      builder: (context, state) {
        final call = state.current;
        if (call == null) return const Center(child: EmptyView(title: 'Još nema poziva.'));
        final step = stepOf(call.scenario);
        return Padding(
          padding: const EdgeInsets.all(Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(step.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.xs),
              Text(
                '${clockLabel(call.at)} · ${whoLabel(call.scenario, call.caller)}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: Spacing.md),
              Explanation(text: step.explanation),
              const SizedBox(height: Spacing.lg),
              Expanded(
                child: switch (call.run) {
                  Ran(:final commands) => ListView(
                    children: [for (final command in commands) CommandCard(result: command)],
                  ),
                  Sent(:final exchange) => Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: RequestCard(exchange: exchange)),
                      const SizedBox(width: Spacing.lg),
                      Expanded(child: AnswerCard(answer: exchange.answer)),
                    ],
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class Explanation extends StatelessWidget {
  const Explanation({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
      ),
      child: Text(text, style: theme.textTheme.bodyLarge),
    );
  }
}

class CommandCard extends StatelessWidget {
  const CommandCard({super.key, required this.result});

  final CommandResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: SelectableText(result.command, style: theme.textTheme.titleSmall)),
                  const SizedBox(width: Spacing.md),
                  CommandChip(succeeded: result.succeeded, exitCode: result.exitCode),
                ],
              ),
              if (result.output.isNotEmpty) ...[
                const SizedBox(height: Spacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: CodeBox(text: result.output),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
