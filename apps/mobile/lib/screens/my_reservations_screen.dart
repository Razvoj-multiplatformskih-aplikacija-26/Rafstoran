import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ui/ui.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  Future<void> _refresh(MyReservationsBloc bloc) {
    bloc.add(const MyReservationsRefreshed());
    return bloc.stream.first;
  }

  void _showNotice(BuildContext context, MyReservationsNotice notice) {
    final message = switch (notice) {
      ReservationCancelled() => 'Rezervacija je otkazana.',
      CancellationRejected(:final error) => error.message,
      CancellationFailed() => 'Otkazivanje nije uspelo.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    context.read<MyReservationsBloc>().add(const MyReservationsNoticeAcknowledged());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MyReservationsBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Moje rezervacije')),
      body: BlocConsumer<MyReservationsBloc, MyReservationsState>(
        listenWhen: (previous, current) => current is MyReservationsLoaded && current.notice != null,
        listener: (context, state) => _showNotice(context, (state as MyReservationsLoaded).notice!),
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => _refresh(bloc),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: switch (state) {
                  MyReservationsLoading() => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: const [ReservationListSkeleton()],
                  ),
                  MyReservationsFailure() => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [FailureView(onRetry: () => bloc.add(const MyReservationsRequested()))],
                  ),
                  MyReservationsEmpty() => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      EmptyView(
                        title: 'Nemate rezervacija.',
                        action: FilledButton.tonal(
                          onPressed: () => context.go('/'),
                          child: const Text('Pogledaj termine'),
                        ),
                      ),
                    ],
                  ),
                  MyReservationsLoaded() => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (state.upcoming.isNotEmpty) ...[
                        const _SectionTitle('Predstojeće'),
                        for (final reservation in state.upcoming) ...[
                          _ReservationCard(
                            reservation: reservation,
                            onOpen: () => context.push('/reservations/${reservation.id.value}'),
                            busy: state.isCancelling(reservation),
                            onCancel: state.canCancel(reservation) && !state.isBusy
                                ? () => confirmCancellation(context, reservation)
                                : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (state.past.isNotEmpty) ...[
                        const _SectionTitle('Prethodne'),
                        for (final reservation in state.past) ...[
                          _ReservationCard(
                            reservation: reservation,
                            onOpen: () => context.push('/reservations/${reservation.id.value}'),
                            onCancel: null,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],
                  ),
                },
              ),
            ),
          );
        },
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
  const _ReservationCard({required this.reservation, required this.onOpen, required this.onCancel, this.busy = false});

  final Reservation reservation;
  final VoidCallback onOpen;
  final VoidCallback? onCancel;
  final bool busy;

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
      child: InkWell(
        onTap: onOpen,
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
                child: busy
                    ? const _CancellationProgress()
                    : cancel == null
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
      ),
    );
  }
}

class _CancellationProgress extends StatelessWidget {
  const _CancellationProgress();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      label: 'Otkazivanje u toku',
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
            const SizedBox(width: 10),
            ExcludeSemantics(
              child: Text(
                'Otkazivanje…',
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

Future<void> confirmCancellation(BuildContext context, Reservation reservation) async {
  final bloc = context.read<MyReservationsBloc>();
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
  if (confirmed != true) return;
  bloc.add(ReservationCancellationRequested(reservation.id, reason: 'Otkazao gost.'));
}
