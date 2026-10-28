import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../data/exchange.dart';
import 'labels.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.exchange, this.withBody = true});

  final Exchange exchange;
  final bool withBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = exchange.body;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Zahtev', style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.md),
            SelectableText('${exchange.method} ${exchange.url}', style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            for (final header in exchange.headers.entries)
              Text(
                '${header.key}: ${header.value}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            if (withBody && body != null) ...[const SizedBox(height: Spacing.md), Expanded(child: CodeBox(text: body))],
          ],
        ),
      ),
    );
  }
}

class AnswerCard extends StatelessWidget {
  const AnswerCard({super.key, required this.answer});

  final Answer answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: switch (answer) {
          Unreachable() => Text(
            'Server nije dostupan.',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
          ),
          Answered(:final status, :final elapsed, :final contentType, :final body, :final message) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('Odgovor', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  StatusChip(status: status, withReason: true),
                  const SizedBox(width: Spacing.md),
                  Text('${elapsed.inMilliseconds} ms', style: theme.textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Content-Type: $contentType',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (message != null) ...[const SizedBox(height: Spacing.md), MessageBox(message: message)],
              const SizedBox(height: Spacing.md),
              Expanded(child: CodeBox(text: body)),
            ],
          ),
        },
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.withReason = false});

  final int status;
  final bool withReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<ReservationStatusColors>()!;
    final (background, foreground) = switch (status) {
      >= 200 && < 300 => (colors.confirmed, colors.onConfirmed),
      >= 400 && < 500 => (colors.pending, colors.onPending),
      _ => (colors.cancelled, colors.onCancelled),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Text(
        withReason ? '$status ${reasonPhrase(status)}' : '$status',
        style: theme.textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Poruka u aplikaciji',
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: Spacing.xs),
          Text(message, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class CodeBox extends StatelessWidget {
  const CodeBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: SingleChildScrollView(
        child: SelectableText(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
      ),
    );
  }
}

class CommandChip extends StatelessWidget {
  const CommandChip({super.key, required this.succeeded, required this.exitCode});

  final bool succeeded;
  final int exitCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<ReservationStatusColors>()!;
    final (background, foreground) = succeeded
        ? (colors.confirmed, colors.onConfirmed)
        : (colors.cancelled, colors.onCancelled);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(Radii.pill)),
      child: Text(
        succeeded ? 'uspešno' : 'greška $exitCode',
        style: theme.textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}
