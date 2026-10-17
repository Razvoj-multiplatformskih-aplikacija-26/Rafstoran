import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

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

final class AvailableSlotsBloc extends Bloc<AvailableSlotsEvent, AvailableSlotsState> {
  AvailableSlotsBloc({required this.getAvailableSlots, required this.clock, PartySize? initialPartySize})
    : super(
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
  int _request = 0;

  DateTime get today => restaurantDay(clock.now());

  Future<void> _load(Emitter<AvailableSlotsState> emit, {required DateTime day, required PartySize partySize}) async {
    final request = ++_request;
    emit(AvailableSlotsLoading(day: day, partySize: partySize));
    try {
      final slots = await getAvailableSlots(localDay: day, partySize: partySize);
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
