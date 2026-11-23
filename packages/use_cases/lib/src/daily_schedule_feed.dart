import 'ports/schedule_feed.dart';

final class WatchDailySchedule {
  const WatchDailySchedule({required this.feed});

  final ScheduleFeed feed;

  Stream<ScheduleSnapshot?> call(DateTime localDay) => feed.watch(localDay);
}

final class RefreshDailySchedule {
  const RefreshDailySchedule({required this.feed});

  final ScheduleFeed feed;

  Future<void> call(DateTime localDay) => feed.refresh(localDay);
}
