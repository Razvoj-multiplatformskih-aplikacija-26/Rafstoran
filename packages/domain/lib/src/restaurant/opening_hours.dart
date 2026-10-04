import 'package:meta/meta.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'local_time.dart';

const restaurantTimeZone = 'Europe/Belgrade';

void initializeDomainTimeZones() => tzdata.initializeTimeZones();

@immutable
final class DayHours {
  const DayHours({required this.open, required this.close});

  final LocalTime open;
  final LocalTime close;

  @override
  bool operator ==(Object other) => other is DayHours && other.open == open && other.close == close;

  @override
  int get hashCode => Object.hash(open, close);

  @override
  String toString() => '$open–$close';
}

final class OpeningHours {
  OpeningHours(Map<int, DayHours> byWeekday, {String timeZone = restaurantTimeZone})
    : _byWeekday = Map.unmodifiable(byWeekday),
      location = tz.getLocation(timeZone);

  final Map<int, DayHours> _byWeekday;
  final tz.Location location;

  DayHours? forWeekday(int weekday) => _byWeekday[weekday];

  bool isOpenOn(int weekday) => _byWeekday.containsKey(weekday);

  tz.TZDateTime toLocal(DateTime instant) => tz.TZDateTime.from(instant, location);

  DateTime localToUtc(int year, int month, int day, LocalTime time) =>
      tz.TZDateTime(location, year, month, day, time.hour, time.minute).toUtc();

  bool covers(DateTime start, Duration duration) {
    final local = toLocal(start);
    final hours = forWeekday(local.weekday);
    if (hours == null) return false;
    final startMinutes = local.hour * 60 + local.minute;
    final endMinutes = startMinutes + duration.inMinutes;
    return startMinutes >= hours.open.minutesSinceMidnight && endMinutes <= hours.close.minutesSinceMidnight;
  }

  List<DateTime> slotStartsOn(DateTime localDay, {required Duration slotLength, required Duration step}) {
    final hours = forWeekday(localDay.weekday);
    if (hours == null) return const [];
    final lastStart = hours.close.minutesSinceMidnight - slotLength.inMinutes;
    final starts = <DateTime>[];
    for (var minutes = hours.open.minutesSinceMidnight; minutes <= lastStart; minutes += step.inMinutes) {
      final time = LocalTime(minutes ~/ 60, minutes % 60);
      starts.add(localToUtc(localDay.year, localDay.month, localDay.day, time));
    }
    return starts;
  }
}

DateTime restaurantTime(DateTime instant) => tz.TZDateTime.from(instant, tz.getLocation(restaurantTimeZone));

DateTime restaurantDay(DateTime instant) {
  final local = restaurantTime(instant);
  return DateTime(local.year, local.month, local.day);
}
