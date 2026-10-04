import 'package:flutter/material.dart';

import '../models/reservation_status.dart';
import '../theme/theme.dart';

extension ReservationStatusLabel on ReservationStatus {
  String get label => switch (this) {
    ReservationStatus.pending => 'Na čekanju',
    ReservationStatus.confirmed => 'Potvrđena',
    ReservationStatus.cancelled => 'Otkazana',
    ReservationStatus.arrived => 'Gost stigao',
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
      ReservationStatus.pending => (colors.pending, colors.onPending),
      ReservationStatus.confirmed => (colors.confirmed, colors.onConfirmed),
      ReservationStatus.cancelled => (colors.cancelled, colors.onCancelled),
      ReservationStatus.arrived => (colors.arrived, colors.onArrived),
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
