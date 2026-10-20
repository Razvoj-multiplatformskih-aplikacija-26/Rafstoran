import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

class ScheduleList extends StatefulWidget {
  const ScheduleList({
    super.key,
    required this.schedule,
    required this.selectedId,
    required this.onSelect,
    required this.onContextMenu,
    this.openAt,
  });

  final DailySchedule schedule;
  final ReservationId? selectedId;
  final ValueChanged<Reservation> onSelect;
  final void Function(Reservation reservation, Offset globalPosition) onContextMenu;
  final DateTime? openAt;

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  final _target = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _target.currentContext;
      if (target != null && target.mounted) Scrollable.ensureVisible(target);
    });
  }

  DateTime? _targetStart(List<Reservation> reservations) {
    final selected = reservations.where((r) => r.id == widget.selectedId).firstOrNull;
    if (selected != null) return selected.slot.start;
    final openAt = widget.openAt;
    return openAt == null ? null : reservations.where((r) => r.slot.end.isAfter(openAt)).firstOrNull?.slot.start;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedule = widget.schedule;
    final reservations = schedule.activeReservations;
    final groups = <DateTime, List<Reservation>>{};
    for (final reservation in reservations) {
      groups.putIfAbsent(reservation.slot.start, () => []).add(reservation);
    }
    if (reservations.isEmpty) {
      return const Center(child: EmptyView(title: 'Nema rezervacija za ovaj dan.'));
    }
    final target = _targetStart(reservations);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in groups.entries) ...[
            Padding(
              key: entry.key == target ? _target : null,
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Semantics(header: true, child: Text(formatTime(entry.key), style: theme.textTheme.titleLarge)),
            ),
            for (final reservation in entry.value) ...[
              _ReservationTile(
                reservation: reservation,
                guestName: schedule.guestNameOf(reservation),
                table: schedule.tables.where((t) => t.id == reservation.tableId).firstOrNull,
                selected: reservation.id == widget.selectedId,
                onTap: () => widget.onSelect(reservation),
                onContextMenu: (position) => widget.onContextMenu(reservation, position),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  const _ReservationTile({
    required this.reservation,
    required this.guestName,
    required this.table,
    required this.selected,
    required this.onTap,
    required this.onContextMenu,
  });

  final Reservation reservation;
  final String? guestName;
  final DiningTable? table;
  final bool selected;
  final VoidCallback onTap;
  final void Function(Offset globalPosition) onContextMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final guestName = this.guestName ?? 'Gost';
    final tableLabel = table?.label ?? '—';
    return Semantics(
      button: true,
      selected: selected,
      label: '$guestName, ${peopleLabel(reservation.partySize.value)}, sto $tableLabel, ${reservation.status.label}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onSecondaryTapUp: (details) => onContextMenu(details.globalPosition),
        onLongPressStart: (details) => onContextMenu(details.globalPosition),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
          ),
          child: ListTile(
            onTap: onTap,
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: Text(tableLabel, style: theme.textTheme.titleMedium),
            ),
            title: Text(guestName, style: theme.textTheme.titleMedium),
            subtitle: Text(peopleLabel(reservation.partySize.value)),
            trailing: StatusBadge(status: reservation.status),
          ),
        ),
      ),
    );
  }
}
