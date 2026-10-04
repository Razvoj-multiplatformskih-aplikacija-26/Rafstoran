import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../models/reservation.dart';
import '../models/slot_selection.dart';
import '../text/serbian.dart';
import '../widgets/party_size_stepper.dart';
import 'my_reservations_screen.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key, required this.selection});

  final SlotSelection selection;

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  static const maxNoteLength = 200;
  static const minPartySize = 1;
  static const maxPartySize = 12;

  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  late int _partySize = widget.selection.partySize;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String? _validateNote(String? value) {
    final length = (value ?? '').characters.length;
    if (length > maxNoteLength) return 'Napomena može imati najviše $maxNoteLength znakova.';
    return null;
  }

  String? _validatePartySize(int value) {
    if (value < minPartySize || value > maxPartySize) return 'Broj osoba je od $minPartySize do $maxPartySize.';
    return null;
  }

  void _submit() {
    final partySizeError = _validatePartySize(_partySize);
    if (!_formKey.currentState!.validate() || partySizeError != null) {
      if (partySizeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(partySizeError)));
      }
      return;
    }
    HapticFeedback.mediumImpact();
    final note = _noteController.text.trim();
    final now = DateTime.now();
    fakeReservations.add(
      Reservation(
        id: 'r-${now.microsecondsSinceEpoch}',
        start: widget.selection.slot.start,
        partySize: _partySize,
        note: note.isEmpty ? null : note,
        createdAt: now,
      ),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Rezervacija je poslata. Čeka potvrdu osoblja.')));
    context.go('/reservations');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slot = widget.selection.slot;
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
                  capitalize(formatLongDate(slot.start)),
                  style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Broj osoba', style: theme.textTheme.titleMedium),
                        PartySizeStepper(
                          value: _partySize,
                          min: minPartySize,
                          max: maxPartySize,
                          onChanged: (value) => setState(() => _partySize = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLength: maxNoteLength,
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
