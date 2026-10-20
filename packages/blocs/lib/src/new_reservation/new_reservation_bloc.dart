import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

part 'new_reservation_event.dart';
part 'new_reservation_state.dart';

final class NewReservationBloc extends Bloc<NewReservationEvent, NewReservationState> {
  NewReservationBloc({required List<User> accounts}) : super(NewReservationEntering(accounts: accounts)) {
    on<NewReservationAccountChosen>((event, emit) {
      emit(state.entering(account: event.account, name: event.account.username));
    });
    on<NewReservationNameChanged>((event, emit) {
      emit(state.entering(name: event.text, clearAccount: state.account?.username != event.text));
    });
    on<NewReservationPhoneChanged>((event, emit) => emit(state.entering(phone: event.text)));
    on<NewReservationSlotChosen>(
      (event, emit) => emit(state.entering(slot: event.slot, clearSlot: event.slot == null)),
    );
    on<NewReservationContinued>((event, emit) {
      final current = state;
      if (current is NewReservationEntering && current.canContinue) {
        emit(
          NewReservationConfirming(
            accounts: current.accounts,
            account: current.account,
            name: current.name,
            phone: current.phone,
            slot: current.slot!,
          ),
        );
      }
    });
    on<NewReservationBackRequested>((event, emit) => emit(state.entering()));
  }
}
