import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  test('a week of days stays seven calendar days across the end of summer time', () {
    final days = [for (var n = 0; n < 7; n++) addDays(DateTime(2026, 10, 22), n)];
    expect(days.map((day) => day.day), [22, 23, 24, 25, 26, 27, 28]);
    expect(days.every((day) => day.hour == 0), isTrue);
  });
}
