import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  initializeDomainTimeZones();

  final start = belgrade(2026, 10, 9, 20, 0);
  final confirmed = Confirmed(confirmedBy: waiter.id, at: start.subtract(const Duration(hours: 5)));

  group('R5 · status transitions', () {
    test('allows exactly four transitions out of sixteen', () {
      final statuses = <ReservationStatus>[
        const Pending(),
        confirmed,
        Cancelled(reason: 'test', cancelledBy: waiter.id, at: start),
        Arrived(arrivedAt: start),
      ];
      final allowed = <(Type, Type)>[];
      for (final from in statuses) {
        for (final to in statuses) {
          if (canTransition(from, to)) allowed.add((from.runtimeType, to.runtimeType));
        }
      }
      expect(allowed, [(Pending, Confirmed), (Pending, Cancelled), (Confirmed, Cancelled), (Confirmed, Arrived)]);
    });
  });

  group('R4 · cancelReservation', () {
    test('lets the guest cancel exactly two hours before the start', () {
      final result = cancelReservation(reservationAt(start), by: guest, now: start.subtract(const Duration(hours: 2)));
      expect(result.valueOrNull?.status, isA<Cancelled>());
    });

    test('refuses the guest one minute after the deadline', () {
      final now = start.subtract(const Duration(hours: 1, minutes: 59));
      expect(
        cancelReservation(reservationAt(start), by: guest, now: now),
        const Failure<Reservation>(CancellationTooLate()),
      );
    });

    test('lets staff cancel ten minutes before the start', () {
      final result = cancelReservation(
        reservationAt(start, status: confirmed),
        by: waiter,
        now: start.subtract(const Duration(minutes: 10)),
        reason: 'gost se nije javio',
      );
      expect(result.valueOrNull?.status, isA<Cancelled>());
    });
  });
}
