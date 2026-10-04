import 'package:meta/meta.dart';

import '../errors.dart';
import '../result.dart';
import 'opening_hours.dart';

@immutable
final class TimeSlot {
  const TimeSlot._(this.start);

  TimeSlot.existing(DateTime start) : this._(start.toUtc());

  static const duration = Duration(hours: 2);
  static const step = Duration(minutes: 30);

  final DateTime start;

  DateTime get end => start.add(duration);

  bool overlaps(TimeSlot other) => start.isBefore(other.end) && other.start.isBefore(end);

  static Result<TimeSlot> parse(DateTime start, {required DateTime now, required OpeningHours openingHours}) {
    final startUtc = start.toUtc();
    if (!startUtc.isAfter(now.toUtc())) return const Failure(SlotInPast());
    final onHalfHour = startUtc.minute % step.inMinutes == 0 && startUtc.second == 0 && startUtc.millisecond == 0;
    if (!onHalfHour) return const Failure(SlotNotOnHalfHour());
    if (!openingHours.covers(startUtc, duration)) return const Failure(OutsideOpeningHours());
    return Success(TimeSlot._(startUtc));
  }

  @override
  bool operator ==(Object other) => other is TimeSlot && other.start == start;

  @override
  int get hashCode => start.hashCode;

  @override
  String toString() => 'TimeSlot(${start.toIso8601String()})';
}
