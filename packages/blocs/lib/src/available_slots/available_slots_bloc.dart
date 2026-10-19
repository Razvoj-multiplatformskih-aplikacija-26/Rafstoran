import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'available_slots_event.dart';
part 'available_slots_state.dart';

final class AvailableSlotsBloc extends Bloc<AvailableSlotsEvent, AvailableSlotsState> {
  AvailableSlotsBloc({
    required this.getAvailableSlots,
    required this.clock,
    required this.user,
    PartySize? initialPartySize,
  }) : super(
         AvailableSlotsLoading(
           day: restaurantDay(clock.now()),
           partySize: initialPartySize ?? PartySize.parse(2).valueOrNull!,
         ),
       ) {
    on<AvailableSlotsRequested>((event, emit) => _load(emit, day: state.day, partySize: state.partySize));
    on<AvailableSlotsRefreshed>((event, emit) => _load(emit, day: state.day, partySize: state.partySize));
    on<AvailableSlotsDaySelected>((event, emit) => _load(emit, day: event.day, partySize: state.partySize));
    on<AvailableSlotsPartySizeSelected>((event, emit) => _load(emit, day: state.day, partySize: event.partySize));
  }

  final GetAvailableSlots getAvailableSlots;
  final Clock clock;
  final User user;
  int _request = 0;

  DateTime get today => restaurantDay(clock.now());

  Future<void> _load(Emitter<AvailableSlotsState> emit, {required DateTime day, required PartySize partySize}) async {
    final request = ++_request;
    emit(AvailableSlotsLoading(day: day, partySize: partySize));
    try {
      final slots = await getAvailableSlots(by: user, localDay: day, partySize: partySize);
      if (request != _request) return;
      emit(
        slots.isEmpty
            ? AvailableSlotsEmpty(day: day, partySize: partySize)
            : AvailableSlotsLoaded(day: day, partySize: partySize, slots: slots),
      );
    } on Exception catch (cause) {
      if (request != _request) return;
      emit(AvailableSlotsFailure(day: day, partySize: partySize, cause: cause));
    }
  }
}
