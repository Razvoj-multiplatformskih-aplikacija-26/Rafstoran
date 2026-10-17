import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ReservationCell extends StatefulWidget {
  const ReservationCell({
    super.key,
    required this.reservation,
    required this.guest,
    required this.selected,
    required this.focused,
    required this.onTap,
    required this.onContextMenu,
  });

  final Reservation reservation;
  final User? guest;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;
  final void Function(Offset globalPosition) onContextMenu;

  @override
  State<ReservationCell> createState() => _ReservationCellState();
}

class _ReservationCellState extends State<ReservationCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final ReservationCell(:reservation, :guest, :selected, :focused, :onTap, :onContextMenu) = widget;
    final theme = Theme.of(context);
    final colors = theme.statusColors;
    final (background, foreground) = switch (reservation.status) {
      Pending() => (colors.pending, colors.onPending),
      Confirmed() => (colors.confirmed, colors.onConfirmed),
      Cancelled() => (colors.cancelled, colors.onCancelled),
      Arrived() => (colors.arrived, colors.onArrived),
    };
    final guestName = guest?.username ?? 'Gost';
    final outline = selected
        ? theme.colorScheme.primary
        : focused
        ? theme.colorScheme.onSurface
        : foreground.withValues(alpha: _hovered ? 0.8 : 0.35);
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${formatTime(reservation.slot.start)}, $guestName, ${peopleLabel(reservation.partySize.value)}, ${reservation.status.label}',
      excludeSemantics: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: onTap,
          onSecondaryTapUp: (details) => onContextMenu(details.globalPosition),
          onLongPressStart: (details) => onContextMenu(details.globalPosition),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: _hovered ? Color.lerp(background, foreground, 0.08) : background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: outline, width: selected || focused ? 2 : 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${formatTime(reservation.slot.start)} · ${peopleLabel(reservation.partySize.value)}',
                    style: theme.textTheme.labelLarge?.copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    guestName,
                    style: theme.textTheme.bodySmall?.copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
