import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../text/domain_errors.dart';
import '../text/serbian.dart';
import '../widgets/status_badge.dart';
import '../widgets/table_illustration.dart';

const currentUser = User(id: UserId('u-guest'), username: 'gost', role: Role.guest);
const _waiter = UserId('u-waiter');

final DateTime _seedToday = restaurantDay(DateTime.now());

Reservation _seed({
  required String id,
  required Duration fromToday,
  required int partySize,
  required String tableId,
  String? note,
  ReservationStatus status = const Pending(),
}) {
  final start = _seedToday.add(fromToday);
  return Reservation(
    id: ReservationId(id),
    guestId: currentUser.id,
    slot: TimeSlot.existing(start),
    partySize: PartySize.parse(partySize).valueOrNull!,
    note: note == null ? null : ReservationNote.parse(note).valueOrNull,
    tableId: DiningTableId(tableId),
    status: status,
    createdAt: start.subtract(const Duration(days: 2)).toUtc(),
  );
}

final fakeReservations = <Reservation>[
  _seed(
    id: 'r-1',
    fromToday: const Duration(days: 1, hours: 20),
    partySize: 4,
    tableId: 't-03',
    note: 'Sto pored prozora, ako je moguće.',
    status: Confirmed(confirmedBy: _waiter, at: _seedToday.subtract(const Duration(hours: 20)).toUtc()),
  ),
  _seed(id: 'r-2', fromToday: const Duration(days: 5, hours: 13), partySize: 2, tableId: 't-01'),
  _seed(
    id: 'r-3',
    fromToday: const Duration(days: -3, hours: 19, minutes: 30),
    partySize: 6,
    tableId: 't-05',
    note: 'Rođendan, treba nam mesto za tortu.',
    status: Arrived(arrivedAt: _seedToday.subtract(const Duration(days: 3, hours: -19, minutes: -42)).toUtc()),
  ),
  _seed(
    id: 'r-4',
    fromToday: const Duration(days: -12, hours: 21),
    partySize: 3,
    tableId: 't-08',
    status: Cancelled(
      reason: 'Promena plana.',
      cancelledBy: currentUser.id,
      at: _seedToday.subtract(const Duration(days: 13)).toUtc(),
    ),
  ),
];

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  bool _canCancel(Reservation reservation, DateTime now) =>
      !reservation.status.isFinal &&
      AccessPolicy.canCancel(currentUser, reservation) &&
      guestMayStillCancel(reservation, now: now);

  Future<void> _cancel(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkazati rezervaciju?'),
        content: Text(
          '${capitalize(formatDateAndTime(reservation.slot.start))}, ${peopleLabel(reservation.partySize.value)}.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Otkaži rezervaciju')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = cancelReservation(reservation, by: currentUser, now: DateTime.now(), reason: 'Otkazao gost.');
    final message = switch (result) {
      Success(:final value) => _replace(value),
      Failure(:final error) => error.message,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _replace(Reservation updated) {
    setState(() {
      final index = fakeReservations.indexWhere((r) => r.id == updated.id);
      fakeReservations[index] = updated;
    });
    return 'Rezervacija je otkazana.';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = fakeReservations.where((r) => r.slot.end.isAfter(now)).toList()
      ..sort((a, b) => a.slot.start.compareTo(b.slot.start));
    final past = fakeReservations.where((r) => !r.slot.end.isAfter(now)).toList()
      ..sort((a, b) => b.slot.start.compareTo(a.slot.start));

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
                      const _SectionTitle('Predstojeće'),
                      for (final reservation in upcoming) ...[
                        _ReservationCard(
                          reservation: reservation,
                          onCancel: _canCancel(reservation, now) ? () => _cancel(reservation) : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                    if (past.isNotEmpty) ...[
                      const _SectionTitle('Prethodne'),
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

  String? _statusDetail(ReservationStatus status) => switch (status) {
    Pending() || Confirmed() => null,
    Cancelled(:final reason) => reason.isEmpty ? null : reason,
    Arrived(:final arrivedAt) => 'Dolazak u ${formatTime(arrivedAt)}.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final note = reservation.note;
    final detail = _statusDetail(reservation.status);
    final cancel = onCancel;
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
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
                            Text(formatTime(reservation.slot.start), style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 2),
                            Text(capitalize(formatInstantDate(reservation.slot.start)), style: mutedStyle),
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
                      Text(peopleLabel(reservation.partySize.value), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 8),
                    Text(note.text, style: mutedStyle?.copyWith(fontStyle: FontStyle.italic)),
                  ],
                  if (detail != null) ...[const SizedBox(height: 8), Text(detail, style: mutedStyle)],
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
                      label: 'Otkaži rezervaciju, ${capitalize(formatDateAndTime(reservation.slot.start))}',
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
