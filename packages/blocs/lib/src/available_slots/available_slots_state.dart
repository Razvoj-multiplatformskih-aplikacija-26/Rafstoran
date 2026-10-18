part of 'available_slots_bloc.dart';

sealed class AvailableSlotsState extends Equatable {
  const AvailableSlotsState({required this.day, required this.partySize});

  final DateTime day;
  final PartySize partySize;

  @override
  List<Object?> get props => [day, partySize];

  @override
  String toString() => '$runtimeType';
}

final class AvailableSlotsLoading extends AvailableSlotsState {
  const AvailableSlotsLoading({required super.day, required super.partySize});
}

final class AvailableSlotsFailure extends AvailableSlotsState {
  const AvailableSlotsFailure({required super.day, required super.partySize, required this.cause});

  final Object cause;

  @override
  List<Object?> get props => [...super.props, cause];

  @override
  String toString() => 'AvailableSlotsFailure($cause)';
}

final class AvailableSlotsEmpty extends AvailableSlotsState {
  const AvailableSlotsEmpty({required super.day, required super.partySize});
}

final class AvailableSlotsLoaded extends AvailableSlotsState {
  const AvailableSlotsLoaded({required super.day, required super.partySize, required this.slots});

  final List<SlotAvailability> slots;

  @override
  List<Object?> get props => [...super.props, slots];

  @override
  String toString() => 'AvailableSlotsLoaded(${slots.length} slots)';
}
