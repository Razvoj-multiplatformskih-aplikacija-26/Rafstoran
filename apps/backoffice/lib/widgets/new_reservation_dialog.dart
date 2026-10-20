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
  required List<User> accounts,
}) {
  final dependencies = context.read<BackofficeDependencies>();
  return showDialog<Reservation>(
    context: context,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AvailableSlotsBloc(
            getAvailableSlots: dependencies.getAvailableSlots,
            clock: dependencies.clock,
            user: dependencies.staff,
          )..add(AvailableSlotsDaySelected(day)),
        ),
        BlocProvider(create: (_) => NewReservationBloc(accounts: accounts)),
      ],
      child: _NewReservationDialog(
        day: day,
        staff: dependencies.staff,
        createReservation: dependencies.createReservation,
      ),
    ),
  );
}

class _NewReservationDialog extends StatelessWidget {
  const _NewReservationDialog({required this.day, required this.staff, required this.createReservation});

  final DateTime day;
  final User staff;
  final CreateReservation createReservation;

  String _guestLabel(NewReservationConfirming entry) => switch (entry.guest) {
    AccountGuest() => entry.name,
    ContactGuest(:final name, :final phone) => '${name.text}, ${phone.value}',
  };

  @override
  Widget build(BuildContext context) {
    final entry = context.watch<NewReservationBloc>().state;
    return switch (entry) {
      NewReservationEntering() => _GuestStep(day: day, entry: entry),
      NewReservationConfirming(:final guest, :final slot) => BlocProvider(
        create: (_) => ReservationFormBloc(
          createReservation: createReservation,
          user: staff,
          guest: guest,
          slot: slot,
          partySize: context.read<AvailableSlotsBloc>().state.partySize,
        ),
        child: _ConfirmStep(guestLabel: _guestLabel(entry), slot: slot),
      ),
    };
  }
}

class _GuestStep extends StatelessWidget {
  const _GuestStep({required this.day, required this.entry});

  final DateTime day;
  final NewReservationEntering entry;

  @override
  Widget build(BuildContext context) {
    final slots = context.watch<AvailableSlotsBloc>().state;
    final bloc = context.read<NewReservationBloc>();
    return AlertDialog(
      title: const Text('Nova rezervacija'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(capitalize(formatLongDate(day))),
            const SizedBox(height: 16),
            Autocomplete<User>(
              initialValue: TextEditingValue(text: entry.name),
              displayStringForOption: (account) => account.username,
              optionsBuilder: (value) => bloc.state.suggestionsFor(value.text),
              onSelected: (account) => bloc.add(NewReservationAccountChosen(account)),
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Gost',
                  helperText: entry.account == null ? null : 'Ima nalog u aplikaciji.',
                  errorText: entry.nameError?.message,
                ),
                onChanged: (text) => bloc.add(NewReservationNameChanged(text)),
              ),
            ),
            if (entry.account == null) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: entry.phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Telefon', errorText: entry.phoneError?.message),
                onChanged: (text) => bloc.add(NewReservationPhoneChanged(text)),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Broj osoba')),
                PartySizeStepper(
                  value: slots.partySize,
                  onChanged: (size) {
                    bloc.add(const NewReservationSlotChosen(null));
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
                            selected: availability.slot == entry.slot,
                            onSelected: availability.freeTables > 0
                                ? (_) => bloc.add(NewReservationSlotChosen(availability.slot))
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
          onPressed: entry.canContinue ? () => bloc.add(const NewReservationContinued()) : null,
          child: const Text('Dalje'),
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatefulWidget {
  const _ConfirmStep({required this.guestLabel, required this.slot});

  final String guestLabel;
  final TimeSlot slot;

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
                  '${widget.guestLabel}, ${formatDateAndTime(widget.slot.start)}, '
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
            TextButton(
              onPressed: submitting
                  ? null
                  : () => context.read<NewReservationBloc>().add(const NewReservationBackRequested()),
              child: const Text('Nazad'),
            ),
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
