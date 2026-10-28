import 'package:design_tokens/design_tokens.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../console/console_bloc.dart';
import '../data/scenarios.dart';
import 'labels.dart';
import 'steps.dart';

class ScenarioPanel extends StatelessWidget {
  const ScenarioPanel({super.key, required this.server, required this.localCommands});

  final Uri server;
  final bool localCommands;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ConsoleBloc, ConsoleState>(
      builder: (context, state) {
        final bloc = context.read<ConsoleBloc>();
        VoidCallback? run(Scenario scenario) => state.running ? null : () => bloc.add(ScenarioRequested(scenario));
        final steps = [
          for (final step in demoSteps(noteLength: state.noteLength))
            if (localCommands || step.scenario is! LocalStep) step,
        ];
        return ListView(
          padding: const EdgeInsets.all(Spacing.xxl),
          children: [
            Row(
              children: [
                const RafstoranMark(size: 36),
                const SizedBox(width: Spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Konzola', style: theme.textTheme.headlineSmall),
                    Text(
                      '$server',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxl),
            DropdownMenu<UserId>(
              label: const Text('Poziva'),
              initialSelection: state.caller,
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: [
                for (final entry in callers.entries) DropdownMenuEntry(value: entry.key, label: entry.value),
              ],
              onSelected: (caller) => caller == null ? null : bloc.add(CallerChanged(caller)),
            ),
            const SizedBox(height: Spacing.lg),
            for (final (index, step) in steps.indexed)
              StepTile(
                number: index + 1,
                step: step,
                onTap: run(step.scenario),
                trailing: step.scenario is LongNote
                    ? SizedBox(
                        width: 76,
                        child: TextFormField(
                          initialValue: '${state.noteLength}',
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.md),
                          ),
                          onChanged: (value) => switch (int.tryParse(value)) {
                            final length? => bloc.add(NoteLengthChanged(length)),
                            null => null,
                          },
                        ),
                      )
                    : null,
              ),
            if (localCommands) ...[
              const SizedBox(height: Spacing.sm),
              const Divider(),
              const SizedBox(height: Spacing.sm),
              for (final step in toolSteps) StepTile(step: step, onTap: run(step.scenario)),
            ],
            if (state.running) const LinearProgressIndicator(),
          ],
        );
      },
    );
  }
}

class StepTile extends StatelessWidget {
  const StepTile({super.key, required this.step, required this.onTap, this.number, this.trailing});

  final DemoStep step;
  final VoidCallback? onTap;
  final int? number;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Row(
              children: [
                if (number case final number?) ...[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      '$number',
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        step.detail,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
