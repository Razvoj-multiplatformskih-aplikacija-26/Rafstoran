import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

sealed class ReservationFormEvent {
  const ReservationFormEvent();
}

final class ReservationFormPartySizeChanged extends ReservationFormEvent {
  const ReservationFormPartySizeChanged(this.partySize);

  final PartySize partySize;
}

final class ReservationFormNoteChanged extends ReservationFormEvent {
  const ReservationFormNoteChanged(this.text);

  final String text;
}

final class ReservationFormSubmitted extends ReservationFormEvent {
  const ReservationFormSubmitted();
}

sealed class ReservationFormState extends Equatable {
  const ReservationFormState({required this.partySize, required this.noteText});

  final PartySize partySize;
  final String noteText;

  @override
  List<Object?> get props => [partySize, noteText];

  @override
  String toString() => '$runtimeType';
}

final class ReservationFormEditing extends ReservationFormState {
  const ReservationFormEditing({required super.partySize, required super.noteText, this.noteError});

  final DomainError? noteError;

  @override
  List<Object?> get props => [...super.props, noteError];

  bool get canSubmit => noteError == null;
}

final class ReservationFormSubmitting extends ReservationFormState {
  const ReservationFormSubmitting({required super.partySize, required super.noteText});
}

final class ReservationFormSucceeded extends ReservationFormState {
  const ReservationFormSucceeded({required super.partySize, required super.noteText, required this.reservation});

  final Reservation reservation;

  @override
  List<Object?> get props => [...super.props, reservation];
}

final class ReservationFormRejected extends ReservationFormState {
  const ReservationFormRejected({required super.partySize, required super.noteText, required this.error});

  final DomainError error;

  @override
  List<Object?> get props => [...super.props, error];
}

final class ReservationFormFailed extends ReservationFormState {
  const ReservationFormFailed({required super.partySize, required super.noteText, required this.cause});

  final Object cause;

  @override
  List<Object?> get props => [...super.props, cause];
}

final class ReservationFormBloc extends Bloc<ReservationFormEvent, ReservationFormState> {
  ReservationFormBloc({
    required this.createReservation,
    required this.guest,
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
  final User guest;
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
        guest: guest,
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
