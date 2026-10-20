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

final class ScheduleNoShowRequested extends DailyScheduleEvent {
  const ScheduleNoShowRequested(this.id);

  final ReservationId id;
}

final class ScheduleCancellationRequested extends DailyScheduleEvent {
  const ScheduleCancellationRequested(this.id, {this.reason = ''});

  final ReservationId id;
  final String reason;
}

final class ScheduleCursorMoved extends DailyScheduleEvent {
  const ScheduleCursorMoved({this.rows = 0, this.columns = 0});

  final int rows;
  final int columns;
}

final class ScheduleCursorPlaced extends DailyScheduleEvent {
  const ScheduleCursorPlaced(this.cursor);

  final ScheduleCursor cursor;
}

final class ScheduleCursorActivated extends DailyScheduleEvent {
  const ScheduleCursorActivated();
}

final class DailyScheduleNoticeAcknowledged extends DailyScheduleEvent {
  const DailyScheduleNoticeAcknowledged();
}
