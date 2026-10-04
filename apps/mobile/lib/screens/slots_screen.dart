import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/slot_selection.dart';
import '../text/serbian.dart';
import '../widgets/party_size_stepper.dart';
import '../widgets/rafstoran_mark.dart';
import '../widgets/table_illustration.dart';
import 'my_reservations_screen.dart';

final fakeOpeningHours = OpeningHours({
  DateTime.monday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.tuesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.wednesday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.thursday: const DayHours(open: LocalTime(12, 0), close: LocalTime(23, 0)),
  DateTime.friday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.saturday: const DayHours(open: LocalTime(12, 0), close: LocalTime(24, 0)),
  DateTime.sunday: const DayHours(open: LocalTime(12, 0), close: LocalTime(22, 0)),
});

const fakeTables = [
  DiningTable(id: DiningTableId('t-01'), label: 'S1', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-02'), label: 'S2', capacity: 2, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-03'), label: 'S3', capacity: 4, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-04'), label: 'S4', capacity: 4, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-05'), label: 'S5', capacity: 6, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-06'), label: 'S6', capacity: 8, area: TableArea.hall),
  DiningTable(id: DiningTableId('t-07'), label: 'T1', capacity: 2, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-08'), label: 'T2', capacity: 4, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-09'), label: 'T3', capacity: 4, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-10'), label: 'T4', capacity: 6, area: TableArea.terrace),
  DiningTable(id: DiningTableId('t-11'), label: 'B1', capacity: 4, area: TableArea.garden),
  DiningTable(id: DiningTableId('t-12'), label: 'B2', capacity: 10, area: TableArea.garden),
];

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  static const _daysAhead = 14;

  late DateTime _selectedDate = _today;
  PartySize _partySize = PartySize.parse(2).valueOrNull!;

  DateTime get _today => restaurantDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slots = availableSlots(
      openingHours: fakeOpeningHours,
      tables: fakeTables,
      reservations: fakeReservations,
      localDay: _selectedDate,
      partySize: _partySize,
      now: DateTime.now(),
    );

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

  final List<SlotAvailability> slots;
  final PartySize partySize;

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
                child: _SlotCard(availability: slot, partySize: partySize),
              ),
          ],
        );
      },
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.availability, required this.partySize});

  final SlotAvailability availability;
  final PartySize partySize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slot = availability.slot;
    final available = availability.isAvailable;
    final caption = available ? freeTablesLabel(availability.freeTables) : 'Popunjeno';
    void open() {
      final SlotSelection selection = (availability: availability, partySize: partySize);
      context.push('/slots/${slot.start.toIso8601String()}', extra: selection);
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
                  tag: 'slot-${slot.start.toIso8601String()}',
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
