import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  test('a waiter cancels until two hours before the start, the manager until the start, a guest only their own', () {
    final start = DateTime.utc(2026, 10, 30, 18);
    final reservation = reservationAt(start);
    const otherGuest = User(id: UserId('u-ana'), username: 'guest2', role: Role.guest);
    final threeHoursBefore = start.subtract(const Duration(hours: 3));
    final oneHourBefore = start.subtract(const Duration(hours: 1));

    expect(AccessPolicy.canCancel(guest, reservation, now: threeHoursBefore), isTrue);
    expect(AccessPolicy.canCancel(otherGuest, reservation, now: threeHoursBefore), isFalse);
    expect(AccessPolicy.canCancel(waiter, reservation, now: threeHoursBefore), isTrue);
    expect(AccessPolicy.canCancel(waiter, reservation, now: oneHourBefore), isFalse);
    expect(AccessPolicy.canCancel(manager, reservation, now: oneHourBefore), isTrue);
  });
}
