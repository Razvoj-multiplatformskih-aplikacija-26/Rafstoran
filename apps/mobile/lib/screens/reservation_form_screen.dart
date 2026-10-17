import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../models/slot_selection.dart';

import 'package:ui/ui.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key, required this.selection});

  final SlotSelection selection;

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showMessage(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _onStateChanged(BuildContext context, ReservationFormState state) {
    final bloc = context.read<ReservationFormBloc>();
    switch (state) {
      case ReservationFormSucceeded():
        HapticFeedback.mediumImpact();
        context.read<MyReservationsBloc>().add(MyReservationsRefreshed());
        context.read<AvailableSlotsBloc>().add(const AvailableSlotsRefreshed());
        _showMessage(context, 'Rezervacija je poslata. Čeka potvrdu osoblja.');
        context.go('/reservations');
      case ReservationFormRejected(:final error):
        _showMessage(context, error.message);
      case ReservationFormFailed():
        _showMessage(
          context,
          'Rezervacija nije poslata.',
          action: SnackBarAction(label: 'Pokušaj ponovo', onPressed: () => bloc.add(const ReservationFormSubmitted())),
        );
      case ReservationFormEditing() || ReservationFormSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final slot = widget.selection.availability.slot;
    final bloc = context.read<ReservationFormBloc>();
    return BlocConsumer<ReservationFormBloc, ReservationFormState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final submitting = state is ReservationFormSubmitting;
        final noteError = switch (state) {
          ReservationFormEditing(:final noteError) => noteError?.message,
          _ => null,
        };
        return Scaffold(
          appBar: AppBar(title: const Text('Rezervacija')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
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
                          PartySizeStepper(
                            value: state.partySize,
                            onChanged: (size) => bloc.add(ReservationFormPartySizeChanged(size)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    enabled: !submitting,
                    maxLength: ReservationNote.maxLength,
                    maxLengthEnforcement: MaxLengthEnforcement.none,
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Napomena',
                      hintText: 'Nije obavezna. Na primer alergije ili proslava.',
                      alignLabelWithHint: true,
                      errorText: noteError,
                    ),
                    onChanged: (text) => bloc.add(ReservationFormNoteChanged(text)),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: FilledButton(
                  onPressed: submitting ? null : () => bloc.add(const ReservationFormSubmitted()),
                  child: submitting
                      ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Potvrdi rezervaciju'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
