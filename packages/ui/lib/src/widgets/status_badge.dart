import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../status_colors.dart';

extension ReservationStatusLabel on ReservationStatus {
  String get label => switch (this) {
    Pending() => 'Na čekanju',
    Confirmed() => 'Potvrđena',
    Cancelled() => 'Otkazana',
    Arrived() => 'Gost stigao',
  };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.statusColors;
    final (background, foreground) = switch (status) {
      Pending() => (colors.pending, colors.onPending),
      Confirmed() => (colors.confirmed, colors.onConfirmed),
      Cancelled() => (colors.cancelled, colors.onCancelled),
      Arrived() => (colors.arrived, colors.onArrived),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: theme.textTheme.labelMedium?.copyWith(color: foreground)),
    );
  }
}
