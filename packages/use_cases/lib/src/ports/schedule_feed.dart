import '../daily_schedule.dart';

abstract interface class ScheduleFeed {
  Stream<ScheduleSnapshot?> watch(DateTime localDay);

  Future<void> refresh(DateTime localDay);
}

final class ScheduleSnapshot {
  const ScheduleSnapshot(this.schedule, {required this.refreshedAt});

  final DailySchedule schedule;
  final DateTime refreshedAt;
}
