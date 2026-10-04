import 'dart:math' as math;

import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../dependencies.dart';
import '../models/slot_selection.dart';
import '../text/serbian.dart';
import '../widgets/party_size_stepper.dart';
import '../widgets/rafstoran_mark.dart';
import '../widgets/state_views.dart';
import '../widgets/table_illustration.dart';

class SlotsScreen extends StatelessWidget {
  const SlotsScreen({super.key});

  static const _daysAhead = 14;

  Future<void> _refresh(AvailableSlotsBloc bloc) {
    bloc.add(const AvailableSlotsRefreshed());
    return bloc.stream.firstWhere((state) => state is! AvailableSlotsLoading);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<AvailableSlotsBloc>();
    return Scaffold(
      appBar: AppBar(title: const RafstoranWordmark(), actions: [if (kDebugMode) const _OutageSwitch()]),
      body: BlocBuilder<AvailableSlotsBloc, AvailableSlotsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => _refresh(bloc),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: _Header()),
                    SliverToBoxAdapter(
                      child: _DateChips(
                        today: bloc.today,
                        daysAhead: _daysAhead,
                        selected: state.day,
                        onSelected: (day) => bloc.add(AvailableSlotsDaySelected(day)),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ExcludeSemantics(child: Text('Broj osoba', style: theme.textTheme.titleMedium)),
                            PartySizeStepper(
                              value: state.partySize,
                              onChanged: (size) => bloc.add(AvailableSlotsPartySizeSelected(size)),
                            ),
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
                                child: Text(capitalize(formatLongDate(state.day)), style: theme.textTheme.titleLarge),
                              ),
                            ),
                            if (state case AvailableSlotsLoaded(:final slots))
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  slotsLabel(slots.length),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    switch (state) {
                      AvailableSlotsLoading() => const SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverToBoxAdapter(child: SlotSkeleton()),
                      ),
                      AvailableSlotsFailure() => SliverFillRemaining(
                        hasScrollBody: false,
                        child: FailureView(onRetry: () => bloc.add(const AvailableSlotsRefreshed())),
                      ),
                      AvailableSlotsEmpty() => const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyView(title: 'Nema termina za izabrani dan.'),
                      ),
                      AvailableSlotsLoaded(:final slots, :final partySize) => SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: _SlotGrid(slots: slots, partySize: partySize),
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OutageSwitch extends StatelessWidget {
  const _OutageSwitch();

  @override
  Widget build(BuildContext context) {
    final fake = context.read<AppDependencies>().fakeRestaurant;
    if (fake == null) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Simuliraj grešku',
      icon: const Icon(Icons.cloud_off_outlined),
      onPressed: () {
        fake.failingRequests = 1;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sledeći zahtev neće uspeti.')));
      },
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
