import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:domain/domain.dart' as domain;
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'daily_schedule_event.dart';
part 'daily_schedule_state.dart';

final class DailyScheduleBloc extends Bloc<DailyScheduleEvent, DailyScheduleState> {
  DailyScheduleBloc({
    required this.watchDailySchedule,
    required this.refreshDailySchedule,
    required this.confirmReservation,
    required this.recordArrival,
    required this.recordNoShow,
    required this.cancelReservation,
    required this.clock,
    required this.staff,
    this.refreshEvery,
  }) : super(DailyScheduleLoading(day: restaurantDay(clock.now()))) {
    on<DailyScheduleRequested>(_onRequested);
    on<_DailyScheduleArrived>(_onArrived);
    on<DailyScheduleRefreshed>((event, emit) => _refresh(emit, state.day));
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

  final WatchDailySchedule watchDailySchedule;
  final RefreshDailySchedule refreshDailySchedule;
  final ConfirmReservation confirmReservation;
  final RecordArrival recordArrival;
  final RecordNoShow recordNoShow;
  final CancelReservation cancelReservation;
  final Clock clock;
  final User staff;
  final Duration? refreshEvery;
  StreamSubscription<ScheduleSnapshot?>? _feed;
  Timer? _poll;

  DateTime get today => restaurantDay(clock.now());

  Future<void> _onRequested(DailyScheduleRequested event, Emitter<DailyScheduleState> emit) async {
    await _feed?.cancel();
    final day = event.day;
    emit(DailyScheduleLoading(day: day));
    _feed = watchDailySchedule(day).listen((snapshot) => add(_DailyScheduleArrived(day, snapshot)));
    _poll?.cancel();
    if (refreshEvery case final every?) _poll = Timer.periodic(every, (_) => add(const DailyScheduleRefreshed()));
    await _refresh(emit, day);
  }

  void _onArrived(_DailyScheduleArrived event, Emitter<DailyScheduleState> emit) {
    final current = state;
    final snapshot = event.snapshot;
    if (event.day != current.day || snapshot == null) return;
    final schedule = snapshot.schedule;
    final next = switch (current) {
      DailyScheduleLoaded() => current.copyWith(
        schedule: schedule,
        actions: _actionsFor(schedule),
        refreshedAt: snapshot.refreshedAt,
      ),
      _ => DailyScheduleLoaded(
        day: current.day,
        schedule: schedule,
        actions: _actionsFor(schedule),
        cursor: (row: 0, column: _currentHalfHour(schedule)),
        refreshedAt: snapshot.refreshedAt,
        refreshFailure: current is DailyScheduleFailure ? current.cause : null,
      ),
    };
    emit(next.copyWith(cursor: next.clamp(next.cursor)));
  }

  Future<void> _refresh(Emitter<DailyScheduleState> emit, DateTime day) async {
    try {
      await refreshDailySchedule(day);
      final current = state;
      if (current is DailyScheduleLoaded && current.day == day && current.refreshFailure != null) {
        emit(current.copyWith(clearRefreshFailure: true));
      }
    } on Exception catch (cause) {
      final current = state;
      if (current.day != day) return;
      emit(switch (current) {
        DailyScheduleLoaded() => current.copyWith(refreshFailure: cause),
        _ => DailyScheduleFailure(day: day, cause: cause),
      });
    }
  }

  Future<void> _act(
    Emitter<DailyScheduleState> emit,
    ReservationId id,
    Future<Result<Reservation>> Function() action,
  ) async {
    final current = state;
    if (current is! DailyScheduleLoaded || current.isBusy) return;
    emit(current.copyWith(inFlightId: id, clearNotice: true));
    final ScheduleNotice notice;
    try {
      notice = switch (await action()) {
        Failure(:final error) => ScheduleActionRejected(error),
        Success(:final value) => ScheduleActionSucceeded(value),
      };
    } on Exception catch (cause) {
      final latest = state;
      if (latest is DailyScheduleLoaded && latest.day == current.day) {
        emit(latest.copyWith(notice: ScheduleActionFailed(cause), clearInFlight: true));
      }
      return;
    }
    final latest = state;
    if (latest is! DailyScheduleLoaded || latest.day != current.day) return;
    emit(latest.copyWith(notice: notice, clearInFlight: true));
    await _refresh(emit, current.day);
  }

  void _select(Emitter<DailyScheduleState> emit, ReservationId? id) {
    final current = state;
    if (current is! DailyScheduleLoaded) return;
    emit(current.copyWith(selectedId: id, clearSelection: id == null, actions: _actionsFor(current.schedule)));
  }

  @override
  Future<void> close() async {
    _poll?.cancel();
    await _feed?.cancel();
    return super.close();
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
          if (domain.cancelReservation(reservation, by: staff, now: now).isSuccess)
            ScheduleAction.cancel
          else if (domain.onlyManagerMayCancel(reservation, now: now))
            ScheduleAction.managerOnlyCancel,
        },
    };
  }
}
