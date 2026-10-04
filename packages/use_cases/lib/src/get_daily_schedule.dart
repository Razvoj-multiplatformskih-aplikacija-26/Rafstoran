import 'daily_schedule.dart';
import 'ports/schedule_repository.dart';

final class GetDailySchedule {
  const GetDailySchedule({required this.schedules});

  final ScheduleRepository schedules;

  Future<DailySchedule> call(DateTime localDay) => schedules.scheduleFor(localDay);
}
