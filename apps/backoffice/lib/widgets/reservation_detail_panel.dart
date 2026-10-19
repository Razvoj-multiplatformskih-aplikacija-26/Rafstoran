import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class ReservationDetailPanel extends StatelessWidget {
  const ReservationDetailPanel({
    super.key,
    required this.reservation,
    required this.guestName,
    required this.table,
    this.enteredBy,
    this.onConfirm,
    this.onArrival,
    this.onNoShow,
    this.onCancel,
    required this.onClose,
    this.busy = false,
  });

  final Reservation reservation;
  final bool busy;
  final String? guestName;
  final DiningTable? table;
  final User? enteredBy;
  final VoidCallback? onConfirm;
  final VoidCallback? onArrival;
  final VoidCallback? onNoShow;
  final VoidCallback? onCancel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final status = reservation.status;
    final statusDetail = switch (status) {
      Pending() => 'Čeka potvrdu osoblja.',
      Confirmed(:final at) => 'Potvrđena ${formatDateAndTime(at)}.',
      Cancelled(:final reason, :final at) => 'Otkazana ${formatDateAndTime(at)}.${reason.isEmpty ? '' : ' $reason'}',
      Arrived(:final arrivedAt) => 'Gost je stigao u ${formatTime(arrivedAt)}.',
      NoShow(:final at) => 'Zabeleženo ${formatDateAndTime(at)}.',
    };
    final confirm = onConfirm;
    final arrival = onArrival;
    final noShow = onNoShow;
    final cancel = onCancel;
    return Semantics(
      container: true,
      label: 'Detalj rezervacije',
      child: Material(
        color: scheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(formatTime(reservation.slot.start), style: theme.textTheme.displaySmall),
                    ),
                  ),
                  IconButton(tooltip: 'Zatvori detalj (Esc)', onPressed: onClose, icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(capitalize(formatInstantDate(reservation.slot.start)), style: muted),
            ),
            Expanded(
              child: SelectionArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    StatusBadge(status: status),
                    const SizedBox(height: 8),
                    Text(statusDetail, style: muted),
                    const SizedBox(height: 20),
                    _Field(label: 'Gost', value: guestName ?? 'Nepoznat gost'),
                    if (reservation.guest case ContactGuest(:final phone)) _Field(label: 'Telefon', value: phone.value),
                    _Field(label: 'Broj osoba', value: peopleLabel(reservation.partySize.value)),
                    _Field(
                      label: 'Sto',
                      value: table == null ? 'Nije dodeljen' : '${table!.label} · ${seatsLabel(table!.capacity)}',
                    ),
                    _Field(
                      label: 'Vreme',
                      value: '${formatTime(reservation.slot.start)}–${formatTime(reservation.slot.end)}',
                    ),
                    if (reservation.note case final note?) _Field(label: 'Napomena', value: note.text),
                    if (reservation.enteredBy != null) _Field(label: 'Uneo', value: enteredBy?.username ?? 'Osoblje'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (confirm != null)
                    _ActionButton(label: 'Potvrdi', shortcut: 'C', icon: Icons.check, onPressed: busy ? null : confirm),
                  if (arrival != null)
                    _ActionButton(
                      label: 'Gost stigao',
                      shortcut: 'A',
                      icon: Icons.login,
                      onPressed: busy ? null : arrival,
                    ),
                  if (noShow != null) ...[
                    const SizedBox(height: 8),
                    _ActionButton(
                      label: 'Gost nije došao',
                      shortcut: 'D',
                      icon: Icons.person_off_outlined,
                      onPressed: busy ? null : noShow,
                      tonal: true,
                    ),
                  ],
                  if (cancel != null) ...[
                    const SizedBox(height: 8),
                    _ActionButton(
                      label: 'Otkaži',
                      shortcut: 'X',
                      icon: Icons.close,
                      onPressed: busy ? null : cancel,
                      tonal: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.shortcut,
    required this.icon,
    required this.onPressed,
    this.tonal = false,
  });

  final String label;
  final String shortcut;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
        const SizedBox(width: 10),
        ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.6)),
            ),
            child: Text(shortcut, style: theme.textTheme.labelSmall),
          ),
        ),
      ],
    );
    return MergeSemantics(
      child: Semantics(
        hint: 'Prečica $shortcut',
        child: tonal
            ? FilledButton.tonal(onPressed: onPressed, child: child)
            : FilledButton(onPressed: onPressed, child: child),
      ),
    );
  }
}
