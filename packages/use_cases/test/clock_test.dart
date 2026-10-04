import 'package:test/test.dart';
import 'package:use_cases/use_cases.dart';

void main() {
  test('a fixed clock always returns the same instant in UTC', () {
    final clock = FixedClock(DateTime(2026, 10, 9, 20));
    expect(clock.now(), DateTime(2026, 10, 9, 20).toUtc());
    expect(clock.now().isUtc, isTrue);
  });
}
