import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';
import 'package:use_cases/use_cases.dart';

import '../dependencies.dart';

Future<Reservation?> showNewReservationDialog(
  BuildContext context, {
  required DateTime day,
  required List<User> guests,
}) {
  final dependencies = context.read<BackofficeDependencies>();
  return showDialog<Reservation>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) =>
          AvailableSlotsBloc(getAvailableSlots: dependencies.getAvailableSlots, clock: dependencies.clock)
            ..add(AvailableSlotsDaySelected(day)),
      child: _NewReservationDialog(day: day, guests: guests, createReservation: dependencies.createReservation),
    ),
  );
}

class _NewReservationDialog extends StatefulWidget {
  const _NewReservationDialog({required this.day, required this.guests, required this.createReservation});

  final DateTime day;
  final List<User> guests;
  final CreateReservation createReservation;

  @override
  State<_NewReservationDialog> createState() => _NewReservationDialogState();
}

class _NewReservationDialogState extends State<_NewReservationDialog> {
  User? _guest;
  TimeSlot? _slot;
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    final slots = context.watch<AvailableSlotsBloc>().state;
    final guest = _guest;
    final slot = _slot;
    if (_confirming && guest != null && slot != null) {
      return BlocProvider(
        create: (_) => ReservationFormBloc(
          createReservation: widget.createReservation,
          guest: guest,
          slot: slot,
          partySize: slots.partySize,
        ),
        child: _ConfirmStep(guest: guest, slot: slot, onBack: () => setState(() => _confirming = false)),
      );
    }
    return AlertDialog(
      title: const Text('Nova rezervacija'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(capitalize(formatLongDate(widget.day))),
            const SizedBox(height: 16),
            DropdownMenu<User>(
              label: const Text('Gost'),
              expandedInsets: EdgeInsets.zero,
              initialSelection: _guest,
              onSelected: (guest) => setState(() => _guest = guest),
              dropdownMenuEntries: [
                for (final guest in widget.guests) DropdownMenuEntry(value: guest, label: guest.username),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Broj osoba')),
                PartySizeStepper(
                  value: slots.partySize,
                  onChanged: (size) {
                    setState(() => _slot = null);
                    context.read<AvailableSlotsBloc>().add(AvailableSlotsPartySizeSelected(size));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: switch (slots) {
                AvailableSlotsLoading() => const Center(child: CircularProgressIndicator()),
                AvailableSlotsFailure() => Center(
                  child: FailureView(
                    onRetry: () => context.read<AvailableSlotsBloc>().add(const AvailableSlotsRefreshed()),
                  ),
                ),
                AvailableSlotsEmpty() => const Center(child: Text('Nema termina za izabrani dan.')),
                AvailableSlotsLoaded(:final slots) => SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final availability in slots)
                        Tooltip(
                          message: availability.freeTables > 0 ? freeTablesLabel(availability.freeTables) : 'Popunjeno',
                          child: ChoiceChip(
                            label: Text(formatTime(availability.slot.start)),
                            selected: availability.slot == _slot,
                            onSelected: availability.freeTables > 0
                                ? (_) => setState(() => _slot = availability.slot)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Odustani')),
        FilledButton(
          onPressed: guest != null && slot != null ? () => setState(() => _confirming = true) : null,
          child: const Text('Dalje'),
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatefulWidget {
  const _ConfirmStep({required this.guest, required this.slot, required this.onBack});

  final User guest;
  final TimeSlot slot;
  final VoidCallback onBack;

  @override
  State<_ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends State<_ConfirmStep> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationFormBloc, ReservationFormState>(
      listenWhen: (previous, current) => current is ReservationFormSucceeded,
      listener: (context, state) => Navigator.pop(context, (state as ReservationFormSucceeded).reservation),
      builder: (context, state) {
        final bloc = context.read<ReservationFormBloc>();
        final submitting = state is ReservationFormSubmitting;
        final noteError = switch (state) {
          ReservationFormEditing(:final noteError) => noteError?.message,
          _ => null,
        };
        final problem = switch (state) {
          ReservationFormRejected(:final error) => error.message,
          ReservationFormFailed() => 'Rezervacija nije sačuvana.',
          _ => null,
        };
        return AlertDialog(
          title: const Text('Nova rezervacija'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.guest.username}, ${formatDateAndTime(widget.slot.start)}, '
                  '${peopleLabel(state.partySize.value)}.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _note,
                  autofocus: true,
                  maxLength: ReservationNote.maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  decoration: InputDecoration(labelText: 'Napomena', errorText: noteError),
                  onChanged: (text) => bloc.add(ReservationFormNoteChanged(text)),
                ),
                if (problem != null) Semantics(liveRegion: true, child: Text(problem)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: submitting ? null : widget.onBack, child: const Text('Nazad')),
            FilledButton(
              onPressed: submitting || noteError != null ? null : () => bloc.add(const ReservationFormSubmitted()),
              child: const Text('Sačuvaj'),
            ),
          ],
        );
      },
    );
  }
}
