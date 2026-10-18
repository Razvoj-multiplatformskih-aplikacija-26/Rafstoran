part of 'available_slots_bloc.dart';

sealed class AvailableSlotsEvent {
  const AvailableSlotsEvent();
}

final class AvailableSlotsRequested extends AvailableSlotsEvent {
  const AvailableSlotsRequested();
}

final class AvailableSlotsRefreshed extends AvailableSlotsEvent {
  const AvailableSlotsRefreshed();
}

final class AvailableSlotsDaySelected extends AvailableSlotsEvent {
  const AvailableSlotsDaySelected(this.day);

  final DateTime day;
}

final class AvailableSlotsPartySizeSelected extends AvailableSlotsEvent {
  const AvailableSlotsPartySizeSelected(this.partySize);

  final PartySize partySize;
}
