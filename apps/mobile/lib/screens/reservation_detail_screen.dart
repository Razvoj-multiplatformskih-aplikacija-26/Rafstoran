import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import 'my_reservations_screen.dart';

class ReservationDetailScreen extends StatelessWidget {
  const ReservationDetailScreen({super.key, required this.id});

  final ReservationId id;

  Reservation? _find(MyReservationsLoaded state) {
    for (final reservation in state.upcoming.followedBy(state.past)) {
      if (reservation.id == id) return reservation;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyReservationsBloc, MyReservationsState>(
      builder: (context, state) {
        if (state is! MyReservationsLoaded) return const _NotFound();
        final reservation = _find(state);
        if (reservation == null) return const _NotFound();
        return _DetailBody(
          reservation: reservation,
          busy: state.isCancelling(reservation),
          onCancel: state.canCancel(reservation) && !state.isBusy
              ? () => confirmCancellation(context, reservation)
              : null,
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.reservation, required this.onCancel, this.busy = false});

  final Reservation reservation;
  final VoidCallback? onCancel;
  final bool busy;

  List<Widget> _statusRows(ReservationStatus status) => switch (status) {
    Pending() || NoShow() => const [],
    Confirmed(:final at) => [
      const Divider(indent: 16, endIndent: 16),
      _DetailRow(icon: Icons.check_circle_outline, label: 'Potvrđena', value: capitalize(formatDateAndTime(at))),
    ],
    Cancelled(:final reason, :final at) => [
      const Divider(indent: 16, endIndent: 16),
      _DetailRow(
        icon: Icons.cancel_outlined,
        label: 'Otkazana',
        value: reason.isEmpty ? capitalize(formatDateAndTime(at)) : reason,
      ),
    ],
    Arrived(:final arrivedAt) => [
      const Divider(indent: 16, endIndent: 16),
      _DetailRow(icon: Icons.login_outlined, label: 'Dolazak', value: 'U ${formatTime(arrivedAt)}'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slot = reservation.slot;
    final note = reservation.note;
    final cancel = onCancel;
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervacija')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(formatTime(slot.start), style: theme.textTheme.displayLarge),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          capitalize(formatInstantDate(slot.start)),
                          style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: StatusBadge(status: reservation.status),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.group_outlined,
                      label: 'Broj osoba',
                      value: peopleLabel(reservation.partySize.value),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _DetailRow(
                      icon: Icons.schedule_outlined,
                      label: 'Trajanje',
                      value: '2 sata, do ${formatTime(slot.end)}',
                    ),
                    if (note != null) ...[
                      const Divider(indent: 16, endIndent: 16),
                      _DetailRow(icon: Icons.notes_outlined, label: 'Napomena', value: note.text),
                    ],
                    ..._statusRows(reservation.status),
                    const Divider(indent: 16, endIndent: 16),
                    _DetailRow(
                      icon: Icons.event_available_outlined,
                      label: 'Rezervisano',
                      value: capitalize(formatDateAndTime(reservation.createdAt)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: cancel == null && !busy
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: busy
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          label: const Text('Otkazivanje…'),
                        )
                      : OutlinedButton.icon(
                          onPressed: cancel,
                          icon: const Icon(Icons.close),
                          label: const Text('Otkaži rezervaciju'),
                        ),
                ),
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      subtitle: Text(value, style: theme.textTheme.titleMedium),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervacija')),
      body: Center(child: Text('Rezervacija nije pronađena.', style: Theme.of(context).textTheme.titleLarge)),
    );
  }
}
