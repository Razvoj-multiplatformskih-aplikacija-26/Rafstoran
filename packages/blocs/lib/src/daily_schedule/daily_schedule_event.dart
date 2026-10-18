part of 'daily_schedule_bloc.dart';

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
