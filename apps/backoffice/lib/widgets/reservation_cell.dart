import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ReservationCell extends StatelessWidget {
  const ReservationCell({
    super.key,
    required this.reservation,
    required this.guestName,
    required this.selected,
    required this.focused,
    required this.onTap,
    required this.onContextMenu,
  });

  final Reservation reservation;
  final String? guestName;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;
  final void Function(Offset globalPosition) onContextMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.statusColors;
    final (background, foreground) = switch (reservation.status) {
      Pending() => (colors.pending, colors.onPending),
      Confirmed() => (colors.confirmed, colors.onConfirmed),
      Cancelled() || NoShow() => (colors.cancelled, colors.onCancelled),
      Arrived() => (colors.arrived, colors.onArrived),
    };
    final guestName = this.guestName ?? 'Gost';
    final outline = selected
        ? theme.colorScheme.primary
        : focused
        ? theme.colorScheme.onSurface
        : foreground.withValues(alpha: 0.35);
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
          onLongPressStart: (details) => onContextMenu(details.globalPosition),
          child: Material(
            color: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: outline, width: selected || focused ? 2 : 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onSecondaryTapUp: (details) => onContextMenu(details.globalPosition),
              canRequestFocus: false,
              hoverColor: foreground.withValues(alpha: 0.08),
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              child: Padding(
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
      ),
    );
  }
}
