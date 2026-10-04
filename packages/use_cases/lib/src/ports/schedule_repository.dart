import '../daily_schedule.dart';

abstract interface class ScheduleRepository {
  Future<DailySchedule> scheduleFor(DateTime localDay);
}
