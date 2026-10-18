import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'reservation_form_event.dart';
part 'reservation_form_state.dart';

final class ReservationFormBloc extends Bloc<ReservationFormEvent, ReservationFormState> {
  ReservationFormBloc({
    required this.createReservation,
    required this.user,
    this.forGuest,
    required this.slot,
    required PartySize partySize,
  }) : super(ReservationFormEditing(partySize: partySize, noteText: '')) {
    on<ReservationFormPartySizeChanged>((event, emit) {
      emit(
        ReservationFormEditing(
          partySize: event.partySize,
          noteText: state.noteText,
          noteError: _noteError(state.noteText),
        ),
      );
    });
    on<ReservationFormNoteChanged>((event, emit) {
      emit(ReservationFormEditing(partySize: state.partySize, noteText: event.text, noteError: _noteError(event.text)));
    });
    on<ReservationFormSubmitted>(_onSubmitted);
  }

  final CreateReservation createReservation;
  final User user;
  final UserId? forGuest;
  final TimeSlot slot;

  Future<void> _onSubmitted(ReservationFormSubmitted event, Emitter<ReservationFormState> emit) async {
    final current = state;
    final note = ReservationNote.parse(current.noteText);
    if (note case Failure(:final error)) {
      emit(ReservationFormEditing(partySize: current.partySize, noteText: current.noteText, noteError: error));
      return;
    }
    emit(ReservationFormSubmitting(partySize: current.partySize, noteText: current.noteText));
    final parsedNote = note.valueOrNull!;
    try {
      final result = await createReservation(
        by: user,
        forGuest: forGuest,
        start: slot.start,
        partySize: current.partySize,
        note: parsedNote.isEmpty ? null : parsedNote,
      );
      emit(switch (result) {
        Success(:final value) => ReservationFormSucceeded(
          partySize: current.partySize,
          noteText: current.noteText,
          reservation: value,
        ),
        Failure(:final error) => ReservationFormRejected(
          partySize: current.partySize,
          noteText: current.noteText,
          error: error,
        ),
      });
    } on Exception catch (cause) {
      emit(ReservationFormFailed(partySize: current.partySize, noteText: current.noteText, cause: cause));
    }
  }

  DomainError? _noteError(String text) => ReservationNote.parse(text).errorOrNull;
}
