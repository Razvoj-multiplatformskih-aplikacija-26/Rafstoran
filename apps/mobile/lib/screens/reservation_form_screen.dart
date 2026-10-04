import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../models/slot_selection.dart';
import '../text/domain_errors.dart';
import '../text/serbian.dart';
import '../widgets/party_size_stepper.dart';
import 'my_reservations_screen.dart';
import 'slots_screen.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key, required this.selection});

  final SlotSelection selection;

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  late PartySize _partySize = widget.selection.partySize;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String? _validateNote(String? value) => ReservationNote.parse(value ?? '').errorOrNull?.message;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final note = ReservationNote.parse(_noteController.text).valueOrNull!;
    final slot = widget.selection.availability.slot;
    final table = assignTable(tables: fakeTables, reservations: fakeReservations, slot: slot, partySize: _partySize);
    switch (table) {
      case Failure(:final error):
        _showMessage(error.message);
      case Success(:final value):
        final now = DateTime.now().toUtc();
        fakeReservations.add(
          Reservation(
            id: ReservationId('r-${now.microsecondsSinceEpoch}'),
            guestId: currentUser.id,
            slot: slot,
            partySize: _partySize,
            note: note.isEmpty ? null : note,
            tableId: value.id,
            createdAt: now,
          ),
        );
        HapticFeedback.mediumImpact();
        _showMessage('Rezervacija je poslata. Čeka potvrdu osoblja.');
        context.go('/reservations');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slot = widget.selection.availability.slot;
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervacija')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Semantics(header: true, child: Text(formatTime(slot.start), style: theme.textTheme.displaySmall)),
                const SizedBox(height: 4),
                Text(
                  capitalize(formatInstantDate(slot.start)),
                  style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ExcludeSemantics(child: Text('Broj osoba', style: theme.textTheme.titleMedium)),
                        PartySizeStepper(value: _partySize, onChanged: (value) => setState(() => _partySize = value)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLength: ReservationNote.maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Napomena',
                    hintText: 'Nije obavezna. Na primer alergije ili proslava.',
                    alignLabelWithHint: true,
                  ),
                  validator: _validateNote,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: FilledButton(onPressed: _submit, child: const Text('Potvrdi rezervaciju')),
          ),
        ),
      ),
    );
  }
}
