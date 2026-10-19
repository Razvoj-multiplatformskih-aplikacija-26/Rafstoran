import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'daily_schedule_event.dart';
part 'daily_schedule_state.dart';

final class DailyScheduleBloc extends Bloc<DailyScheduleEvent, DailyScheduleState> {
  DailyScheduleBloc({
    required this.getDailySchedule,
    required this.confirmReservation,
    required this.recordArrival,
    required this.recordNoShow,
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
    on<ScheduleNoShowRequested>((event, emit) => _act(emit, event.id, () => recordNoShow(id: event.id, by: staff)));
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
  final RecordNoShow recordNoShow;
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
    if (current is! DailyScheduleLoaded || current.isBusy) return;
    final request = ++_request;
    emit(current.copyWith(inFlightId: id, clearNotice: true));
    try {
      switch (await action()) {
        case Failure(:final error):
          _finish(emit, request, notice: ScheduleActionRejected(error));
        case Success(:final value):
          final schedule = await getDailySchedule(current.day);
          _finish(emit, request, schedule: schedule, notice: ScheduleActionSucceeded(value));
      }
    } on Exception catch (cause) {
      _finish(emit, request, notice: ScheduleActionFailed(cause));
    }
  }

  void _finish(
    Emitter<DailyScheduleState> emit,
    int request, {
    DailySchedule? schedule,
    required ScheduleNotice notice,
  }) {
    final latest = state;
    if (request != _request || latest is! DailyScheduleLoaded) return;
    emit(latest.copyWith(schedule: schedule, notice: notice));
  }
}
