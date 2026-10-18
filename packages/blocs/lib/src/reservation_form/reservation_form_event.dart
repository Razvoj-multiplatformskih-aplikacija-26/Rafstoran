part of 'reservation_form_bloc.dart';

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
