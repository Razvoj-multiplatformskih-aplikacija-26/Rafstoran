part of 'new_reservation_bloc.dart';

sealed class NewReservationEvent {
  const NewReservationEvent();
}

final class NewReservationAccountChosen extends NewReservationEvent {
  const NewReservationAccountChosen(this.account);

  final User account;
}

final class NewReservationNameChanged extends NewReservationEvent {
  const NewReservationNameChanged(this.text);

  final String text;
}

final class NewReservationPhoneChanged extends NewReservationEvent {
  const NewReservationPhoneChanged(this.text);

  final String text;
}

final class NewReservationSlotChosen extends NewReservationEvent {
  const NewReservationSlotChosen(this.slot);

  final TimeSlot? slot;
}

final class NewReservationContinued extends NewReservationEvent {
  const NewReservationContinued();
}

final class NewReservationBackRequested extends NewReservationEvent {
  const NewReservationBackRequested();
}
