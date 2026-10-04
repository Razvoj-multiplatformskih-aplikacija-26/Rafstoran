import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/slot_selection.dart';
import '../text/serbian.dart';

class SlotDetailScreen extends StatelessWidget {
  const SlotDetailScreen({super.key, required this.selection});

  final SlotSelection selection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slot = selection.slot;
    return Scaffold(
      appBar: AppBar(title: const Text('Termin')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Semantics(
                header: true,
                child: Hero(
                  tag: 'slot-${slot.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(formatTime(slot.start), style: theme.textTheme.displayLarge),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                capitalize(formatLongDate(slot.start)),
                style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.schedule_outlined,
                      label: 'Trajanje',
                      value: '2 sata, do ${formatTime(slot.end)}',
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _DetailRow(
                      icon: Icons.group_outlined,
                      label: 'Broj osoba',
                      value: peopleLabel(selection.partySize),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _DetailRow(
                      icon: Icons.table_restaurant_outlined,
                      label: 'Slobodno',
                      value: freeTablesLabel(slot.freeTables),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sto dodeljuje osoblje pri potvrdi rezervacije.',
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: FilledButton.icon(
              onPressed: () => context.push('/slots/${slot.id}/reserve', extra: selection),
              icon: const Icon(Icons.restaurant_outlined),
              label: const Text('Rezerviši'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      subtitle: Text(value, style: theme.textTheme.titleMedium),
    );
  }
}
