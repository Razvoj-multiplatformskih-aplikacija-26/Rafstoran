import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/reservation.dart';
import '../models/reservation_status.dart';
import '../text/serbian.dart';
import '../widgets/status_badge.dart';
import '../widgets/table_illustration.dart';

final DateTime _seedToday = () {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}();

final fakeReservations = <Reservation>[
  Reservation(
    id: 'r-1',
    start: _seedToday.add(const Duration(days: 1, hours: 20)),
    partySize: 4,
    note: 'Sto pored prozora, ako je moguće.',
    status: ReservationStatus.confirmed,
    createdAt: _seedToday.subtract(const Duration(days: 2)),
  ),
  Reservation(
    id: 'r-2',
    start: _seedToday.add(const Duration(days: 5, hours: 13)),
    partySize: 2,
    createdAt: _seedToday.subtract(const Duration(days: 1)),
  ),
  Reservation(
    id: 'r-3',
    start: _seedToday.subtract(const Duration(days: 3, hours: -19, minutes: -30)),
    partySize: 6,
    note: 'Rođendan, treba nam mesto za tortu.',
    status: ReservationStatus.arrived,
    createdAt: _seedToday.subtract(const Duration(days: 9)),
  ),
  Reservation(
    id: 'r-4',
    start: _seedToday.subtract(const Duration(days: 12, hours: -21)),
    partySize: 3,
    status: ReservationStatus.cancelled,
    createdAt: _seedToday.subtract(const Duration(days: 15)),
  ),
];

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  static const cancellationNotice = Duration(hours: 2);

  bool _canCancel(Reservation reservation) {
    final isActive =
        reservation.status == ReservationStatus.pending || reservation.status == ReservationStatus.confirmed;
    return isActive && DateTime.now().isBefore(reservation.start.subtract(cancellationNotice));
  }

  Future<void> _cancel(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkazati rezervaciju?'),
        content: Text('${capitalize(formatDateAndTime(reservation.start))}, ${peopleLabel(reservation.partySize)}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Otkaži rezervaciju')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => reservation.status = ReservationStatus.cancelled);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rezervacija je otkazana.')));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = fakeReservations.where((r) => r.end.isAfter(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final past = fakeReservations.where((r) => !r.end.isAfter(now)).toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    return Scaffold(
      appBar: AppBar(title: const Text('Moje rezervacije')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: fakeReservations.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      _SectionTitle('Predstojeće'),
                      for (final reservation in upcoming) ...[
                        _ReservationCard(
                          reservation: reservation,
                          onCancel: _canCancel(reservation) ? () => _cancel(reservation) : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                    if (past.isNotEmpty) ...[
                      _SectionTitle('Prethodne'),
                      for (final reservation in past) ...[
                        _ReservationCard(reservation: reservation, onCancel: null),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Semantics(header: true, child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, required this.onCancel});

  final Reservation reservation;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final note = reservation.note;
    final cancel = onCancel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formatTime(reservation.start), style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 2),
                            Text(
                              capitalize(formatLongDate(reservation.start)),
                              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: reservation.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.group_outlined, size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(peopleLabel(reservation.partySize), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      note,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: cancel == null
                  ? const SizedBox(height: 40)
                  : Semantics(
                      button: true,
                      label: 'Otkaži rezervaciju, ${capitalize(formatDateAndTime(reservation.start))}',
                      excludeSemantics: true,
                      onTap: cancel,
                      child: TextButton(onPressed: cancel, child: const Text('Otkaži')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TableIllustration(size: 140),
          const SizedBox(height: 24),
          Text('Nemate rezervacija.', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: () => context.go('/'), child: const Text('Pogledaj termine')),
        ],
      ),
    );
  }
}
