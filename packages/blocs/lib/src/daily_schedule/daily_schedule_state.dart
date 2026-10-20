part of 'daily_schedule_bloc.dart';

enum ScheduleAction { confirm, recordArrival, recordNoShow, cancel }

sealed class DailyScheduleState extends Equatable {
  const DailyScheduleState({required this.day});

  final DateTime day;

  @override
  List<Object?> get props => [day];

  @override
  String toString() => '$runtimeType';
}

final class DailyScheduleLoading extends DailyScheduleState {
  const DailyScheduleLoading({required super.day});
}

final class DailyScheduleFailure extends DailyScheduleState {
  const DailyScheduleFailure({required super.day, required this.cause});

  final Object cause;

  @override
  List<Object?> get props => [...super.props, cause];

  @override
  String toString() => 'DailyScheduleFailure($cause)';
}

final class DailyScheduleLoaded extends DailyScheduleState {
  const DailyScheduleLoaded({
    required super.day,
    required this.schedule,
    this.actions = const {},
    this.selectedId,
    this.notice,
    this.inFlightId,
  });

  final DailySchedule schedule;
  final Map<ReservationId, Set<ScheduleAction>> actions;
  final ReservationId? selectedId;
  final ScheduleNotice? notice;
  final ReservationId? inFlightId;

  @override
  List<Object?> get props => [...super.props, schedule, actions, selectedId, notice, inFlightId];

  Set<ScheduleAction> actionsFor(Reservation reservation) => actions[reservation.id] ?? const {};

  bool get isBusy => inFlightId != null;

  @override
  String toString() => [
    'DailyScheduleLoaded(${schedule.reservations.length} reservations',
    if (selectedId case final id?) ', selected ${id.value}',
    if (inFlightId case final id?) ', in flight ${id.value}',
    if (notice case final notice?) ', ${notice.runtimeType}',
    ')',
  ].join();

  Reservation? get selected =>
      selectedId == null ? null : schedule.reservations.where((r) => r.id == selectedId).firstOrNull;

  bool get isEmpty => schedule.reservations.isEmpty;

  DailyScheduleLoaded copyWith({
    DailySchedule? schedule,
    Map<ReservationId, Set<ScheduleAction>>? actions,
    ReservationId? selectedId,
    bool clearSelection = false,
    ScheduleNotice? notice,
    bool clearNotice = false,
    ReservationId? inFlightId,
  }) {
    return DailyScheduleLoaded(
      day: day,
      schedule: schedule ?? this.schedule,
      actions: actions ?? this.actions,
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
