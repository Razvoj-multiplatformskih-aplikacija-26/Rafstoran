import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

sealed class DailyScheduleEvent {
  const DailyScheduleEvent();
}

final class DailyScheduleRequested extends DailyScheduleEvent {
  const DailyScheduleRequested(this.day);

  final DateTime day;
}

final class DailyScheduleRefreshed extends DailyScheduleEvent {
  const DailyScheduleRefreshed();
}

final class ScheduleReservationSelected extends DailyScheduleEvent {
  const ScheduleReservationSelected(this.id);

  final ReservationId? id;
}

final class ScheduleConfirmationRequested extends DailyScheduleEvent {
  const ScheduleConfirmationRequested(this.id);

  final ReservationId id;
}

final class ScheduleArrivalRequested extends DailyScheduleEvent {
  const ScheduleArrivalRequested(this.id);

  final ReservationId id;
}

final class ScheduleCancellationRequested extends DailyScheduleEvent {
  const ScheduleCancellationRequested(this.id, {this.reason = ''});

  final ReservationId id;
  final String reason;
}

final class DailyScheduleNoticeAcknowledged extends DailyScheduleEvent {
  const DailyScheduleNoticeAcknowledged();
}

sealed class DailyScheduleState extends Equatable {
  const DailyScheduleState({required this.day});

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

final class DailyScheduleLoading extends DailyScheduleState {
  const DailyScheduleLoading({required super.day});
}

final class DailyScheduleFailure extends DailyScheduleState {
  const DailyScheduleFailure({required super.day, required this.cause});

  final Object cause;

  @override
  List<Object?> get props => [...super.props, cause];
}

final class DailyScheduleLoaded extends DailyScheduleState {
  const DailyScheduleLoaded({
    required super.day,
    required this.schedule,
    this.selectedId,
    this.notice,
    this.inFlightId,
  });

  final DailySchedule schedule;
  final ReservationId? selectedId;
  final ScheduleNotice? notice;
  final ReservationId? inFlightId;

  @override
  List<Object?> get props => [...super.props, schedule, selectedId, notice, inFlightId];

  bool get isBusy => inFlightId != null;

  Reservation? get selected =>
      selectedId == null ? null : schedule.reservations.where((r) => r.id == selectedId).firstOrNull;

  bool get isEmpty => schedule.reservations.isEmpty;

  DailyScheduleLoaded copyWith({
    DailySchedule? schedule,
    ReservationId? selectedId,
    bool clearSelection = false,
    ScheduleNotice? notice,
    bool clearNotice = false,
    ReservationId? inFlightId,
  }) {
    return DailyScheduleLoaded(
      day: day,
      schedule: schedule ?? this.schedule,
      selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
      notice: clearNotice ? null : (notice ?? this.notice),
      inFlightId: inFlightId,
    );
  }
}

sealed class ScheduleNotice extends Equatable {
  const ScheduleNotice();

  @override
  List<Object?> get props => const [];
}

final class ScheduleActionSucceeded extends ScheduleNotice {
  const ScheduleActionSucceeded(this.reservation);

  final Reservation reservation;

  @override
  List<Object?> get props => [reservation];
}

final class ScheduleActionRejected extends ScheduleNotice {
  const ScheduleActionRejected(this.error);

  final DomainError error;

  @override
  List<Object?> get props => [error];
}

final class ScheduleActionFailed extends ScheduleNotice {
  const ScheduleActionFailed(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];
}

final class DailyScheduleBloc extends Bloc<DailyScheduleEvent, DailyScheduleState> {
  DailyScheduleBloc({
    required this.getDailySchedule,
    required this.confirmReservation,
    required this.recordArrival,
    required this.cancelReservation,
    required this.clock,
    required this.staff,
  }) : super(DailyScheduleLoading(day: restaurantDay(clock.now()))) {
    on<DailyScheduleRequested>((event, emit) => _load(emit, day: event.day));
    on<DailyScheduleRefreshed>((event, emit) => _load(emit, day: state.day, keepSelection: true));
    on<ScheduleReservationSelected>((event, emit) {
      final current = state;
      if (current is DailyScheduleLoaded) {
        emit(current.copyWith(selectedId: event.id, clearSelection: event.id == null));
      }
    });
    on<ScheduleConfirmationRequested>(
      (event, emit) => _act(emit, event.id, () => confirmReservation(id: event.id, by: staff)),
    );
    on<ScheduleArrivalRequested>((event, emit) => _act(emit, event.id, () => recordArrival(id: event.id, by: staff)));
    on<ScheduleCancellationRequested>(
      (event, emit) => _act(emit, event.id, () => cancelReservation(id: event.id, by: staff, reason: event.reason)),
    );
    on<DailyScheduleNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is DailyScheduleLoaded && current.notice != null) emit(current.copyWith(clearNotice: true));
    });
  }

  final GetDailySchedule getDailySchedule;
  final ConfirmReservation confirmReservation;
  final RecordArrival recordArrival;
  final CancelReservation cancelReservation;
  final Clock clock;
  final User staff;
  int _request = 0;

  DateTime get today => restaurantDay(clock.now());

  Future<void> _load(Emitter<DailyScheduleState> emit, {required DateTime day, bool keepSelection = false}) async {
    final request = ++_request;
    final previous = state;
    final selectedId = keepSelection && previous is DailyScheduleLoaded ? previous.selectedId : null;
    if (!keepSelection) emit(DailyScheduleLoading(day: day));
    try {
      final schedule = await getDailySchedule(day);
      if (request != _request) return;
      emit(DailyScheduleLoaded(day: day, schedule: schedule, selectedId: selectedId));
    } on Exception catch (cause) {
      if (request != _request) return;
      emit(DailyScheduleFailure(day: day, cause: cause));
    }
  }

  Future<void> _act(
    Emitter<DailyScheduleState> emit,
    ReservationId id,
    Future<Result<Reservation>> Function() action,
  ) async {
    final current = state;
    if (current is! DailyScheduleLoaded) return;
    emit(current.copyWith(inFlightId: id, clearNotice: true));
    final Result<Reservation> result;
    try {
      result = await action();
    } on Exception catch (cause) {
      emit(current.copyWith(notice: ScheduleActionFailed(cause)));
      return;
    }
    switch (result) {
      case Failure(:final error):
        emit(current.copyWith(notice: ScheduleActionRejected(error)));
      case Success(:final value):
        final schedule = await getDailySchedule(current.day);
        emit(
          DailyScheduleLoaded(
            day: current.day,
            schedule: schedule,
            selectedId: current.selectedId,
            notice: ScheduleActionSucceeded(value),
          ),
        );
    }
  }
}
