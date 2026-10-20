import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;
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
    on<ScheduleReservationSelected>((event, emit) => _select(emit, event.id));
    on<ScheduleConfirmationRequested>(
      (event, emit) => _act(emit, event.id, () => confirmReservation(id: event.id, by: staff)),
    );
    on<ScheduleArrivalRequested>((event, emit) => _act(emit, event.id, () => recordArrival(id: event.id, by: staff)));
    on<ScheduleNoShowRequested>((event, emit) => _act(emit, event.id, () => recordNoShow(id: event.id, by: staff)));
    on<ScheduleCancellationRequested>(
      (event, emit) => _act(emit, event.id, () => cancelReservation(id: event.id, by: staff, reason: event.reason)),
    );
    on<ScheduleCursorMoved>((event, emit) {
      final current = state;
      if (current is! DailyScheduleLoaded) return;
      final cursor = current.cursor;
      emit(
        current.copyWith(cursor: current.clamp((row: cursor.row + event.rows, column: cursor.column + event.columns))),
      );
    });
    on<ScheduleCursorPlaced>((event, emit) {
      final current = state;
      if (current is DailyScheduleLoaded) emit(current.copyWith(cursor: current.clamp(event.cursor)));
    });
    on<ScheduleCursorActivated>((event, emit) {
      final current = state;
      if (current is DailyScheduleLoaded) _select(emit, current.reservationAtCursor?.id);
    });
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
    final cursor = keepSelection && previous is DailyScheduleLoaded ? previous.cursor : null;
    if (!keepSelection) emit(DailyScheduleLoading(day: day));
    try {
      final schedule = await getDailySchedule(day);
      if (request != _request) return;
      final loaded = DailyScheduleLoaded(
        day: day,
        schedule: schedule,
        actions: _actionsFor(schedule),
        cursor: cursor ?? (row: 0, column: _currentHalfHour(schedule)),
        selectedId: selectedId,
      );
      emit(loaded.copyWith(cursor: loaded.clamp(loaded.cursor)));
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
    emit(latest.copyWith(schedule: schedule, actions: _actionsFor(schedule ?? latest.schedule), notice: notice));
  }

  void _select(Emitter<DailyScheduleState> emit, ReservationId? id) {
    final current = state;
    if (current is! DailyScheduleLoaded) return;
    emit(current.copyWith(selectedId: id, clearSelection: id == null, actions: _actionsFor(current.schedule)));
  }

  int _currentHalfHour(DailySchedule schedule) {
    final now = clock.now();
    final column = schedule.halfHours.lastIndexWhere((start) => !start.isAfter(now));
    return restaurantDay(now) == schedule.day && column > 0 ? column : 0;
  }

  Map<ReservationId, Set<ScheduleAction>> _actionsFor(DailySchedule schedule) {
    final now = clock.now();
    return {
      for (final reservation in schedule.reservations)
        reservation.id: {
          if (domain.confirmReservation(reservation, by: staff, now: now).isSuccess) ScheduleAction.confirm,
          if (domain.recordArrival(reservation, by: staff, now: now).isSuccess) ScheduleAction.recordArrival,
          if (domain.recordNoShow(reservation, by: staff, now: now).isSuccess) ScheduleAction.recordNoShow,
          if (domain.cancelReservation(reservation, by: staff, now: now).isSuccess) ScheduleAction.cancel,
        },
    };
  }
}
