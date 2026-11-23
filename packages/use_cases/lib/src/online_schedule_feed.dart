import 'dart:async';

import 'clock.dart';
import 'ports/schedule_feed.dart';
import 'ports/schedule_repository.dart';

final class OnlineScheduleFeed implements ScheduleFeed {
  OnlineScheduleFeed({required this.schedules, required this.clock});

  final ScheduleRepository schedules;
  final Clock clock;
  final _latest = <(int, int, int), ScheduleSnapshot>{};
  final _changes = StreamController<((int, int, int), ScheduleSnapshot)>.broadcast();

  @override
  Stream<ScheduleSnapshot?> watch(DateTime localDay) => Stream.multi((listener) {
    final day = _key(localDay);
    listener.add(_latest[day]);
    final changes = _changes.stream.where((change) => change.$1 == day).listen((change) => listener.add(change.$2));
    listener.onCancel = changes.cancel;
  });

  @override
  Future<void> refresh(DateTime localDay) async {
    final snapshot = ScheduleSnapshot(await schedules.scheduleFor(localDay), refreshedAt: clock.now());
    final day = _key(localDay);
    _latest[day] = snapshot;
    _changes.add((day, snapshot));
  }

  static (int, int, int) _key(DateTime day) => (day.year, day.month, day.day);
}
