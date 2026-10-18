part of 'reservation_form_bloc.dart';

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
