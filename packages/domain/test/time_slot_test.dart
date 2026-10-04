import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  initializeDomainTimeZones();

  final hours = standardOpeningHours();
  final now = belgrade(2026, 10, 9, 12, 0);

  group('R3 · TimeSlot.parse', () {
    test('rejects a start that is not in the future', () {
      expect(TimeSlot.parse(now, now: now, openingHours: hours), const Failure<TimeSlot>(SlotInPast()));
    });

    test('accepts the last slot that ends at closing time and rejects the next half hour', () {
      final lastOnSunday = belgrade(2026, 10, 11, 20, 0);
      final halfHourLater = belgrade(2026, 10, 11, 20, 30);
      expect(TimeSlot.parse(lastOnSunday, now: now, openingHours: hours).isSuccess, isTrue);
      expect(
        TimeSlot.parse(halfHourLater, now: now, openingHours: hours),
        const Failure<TimeSlot>(OutsideOpeningHours()),
      );
    });
  });
}
