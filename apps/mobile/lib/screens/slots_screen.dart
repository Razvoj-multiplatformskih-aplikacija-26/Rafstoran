import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/slot_selection.dart';
import '../models/time_slot.dart';
import '../text/serbian.dart';
import '../widgets/party_size_stepper.dart';
import '../widgets/rafstoran_mark.dart';
import '../widgets/table_illustration.dart';

typedef _OpeningHours = ({int open, int close});

const Map<int, _OpeningHours> _fakeOpeningHours = {
  DateTime.monday: (open: 12, close: 23),
  DateTime.tuesday: (open: 12, close: 23),
  DateTime.wednesday: (open: 12, close: 23),
  DateTime.thursday: (open: 12, close: 23),
  DateTime.friday: (open: 12, close: 24),
  DateTime.saturday: (open: 12, close: 24),
  DateTime.sunday: (open: 12, close: 22),
};

List<TimeSlot> _fakeSlotsFor(DateTime date, int partySize) {
  final hours = _fakeOpeningHours[date.weekday];
  if (hours == null) return const [];
  final lastStart = hours.close * 60 - TimeSlot.duration.inMinutes;
  final slots = <TimeSlot>[];
  for (var minutes = hours.open * 60; minutes <= lastStart; minutes += 30) {
    final start = DateTime(date.year, date.month, date.day, minutes ~/ 60, minutes % 60);
    final seed = date.day * 31 + minutes ~/ 30 + partySize * 7;
    final freeTables = math.max(0, (seed * 17 + 5) % 8 - (partySize > 6 ? 3 : 0));
    slots.add(TimeSlot(start: start, freeTables: freeTables));
  }
  return slots;
}

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  static const _daysAhead = 14;

  late DateTime _selectedDate = _today;
  int _partySize = 2;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final slots = _fakeSlotsFor(_selectedDate, _partySize).where((slot) => slot.start.isAfter(now)).toList();

    return Scaffold(
      appBar: AppBar(title: const RafstoranWordmark()),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: _DateChips(
                  today: _today,
                  daysAhead: _daysAhead,
                  selected: _selectedDate,
                  onSelected: (date) => setState(() => _selectedDate = date),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ExcludeSemantics(child: Text('Broj osoba', style: theme.textTheme.titleMedium)),
                      PartySizeStepper(value: _partySize, onChanged: (value) => setState(() => _partySize = value)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(capitalize(formatLongDate(_selectedDate)), style: theme.textTheme.titleLarge),
                        ),
                      ),
                      if (slots.isNotEmpty)
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            slotsLabel(slots.length),
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (slots.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Nema termina za izabrani dan.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: _SlotGrid(slots: slots, partySize: _partySize),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: Text('Rezervišite sto', style: theme.textTheme.headlineLarge)),
                const SizedBox(height: 8),
                Text(
                  'Izaberite datum i broj osoba, pa slobodan termin.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const TableIllustration(size: 112),
        ],
      ),
    );
  }
}

class _DateChips extends StatelessWidget {
  const _DateChips({required this.today, required this.daysAhead, required this.selected, required this.onSelected});

  final DateTime today;
  final int daysAhead;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  String _label(int offset, DateTime date) => switch (offset) {
    0 => 'Danas',
    1 => 'Sutra',
    _ => '${capitalize(formatShortWeekday(date))} ${formatDayOfMonth(date)}',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: daysAhead,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          return ChoiceChip(
            label: Text(_label(index, date)),
            selected: date == selected,
            onSelected: (_) => onSelected(date),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.slots, required this.partySize});

  static const _minCardWidth = 150.0;
  static const _spacing = 12.0;

  final List<TimeSlot> slots;
  final int partySize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(1, ((constraints.maxWidth + _spacing) / (_minCardWidth + _spacing)).floor());
        final cardWidth = (constraints.maxWidth - (columns - 1) * _spacing) / columns;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final slot in slots)
              SizedBox(
                width: cardWidth,
                child: _SlotCard(slot: slot, partySize: partySize),
              ),
          ],
        );
      },
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, required this.partySize});

  final TimeSlot slot;
  final int partySize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = slot.isAvailable;
    final caption = available ? freeTablesLabel(slot.freeTables) : 'Popunjeno';
    void open() {
      final SlotSelection selection = (slot: slot, partySize: partySize);
      context.push('/slots/${slot.id}', extra: selection);
    }

    return Semantics(
      button: true,
      enabled: available,
      label: '${formatTime(slot.start)}, $caption',
      excludeSemantics: true,
      onTap: available ? open : null,
      child: Card(
        color: available ? null : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: InkWell(
          onTap: available ? open : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'slot-${slot.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      formatTime(slot.start),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: available ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  caption,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: available ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
