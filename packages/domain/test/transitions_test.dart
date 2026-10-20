import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  initializeDomainTimeZones();

  final start = belgrade(2026, 10, 9, 20, 0);
  final confirmed = Confirmed(confirmedBy: waiter.id, at: start.subtract(const Duration(hours: 5)));

  group('R5 · status transitions', () {
    test('allows exactly seven transitions out of twenty-five', () {
      final statuses = <ReservationStatus>[
        const Pending(),
        confirmed,
        Cancelled(reason: 'test', cancelledBy: waiter.id, at: start),
        Arrived(arrivedAt: start),
        NoShow(recordedBy: waiter.id, at: start),
      ];
      final allowed = <(Type, Type)>[];
      for (final from in statuses) {
        for (final to in statuses) {
          if (canTransition(from, to)) allowed.add((from.runtimeType, to.runtimeType));
        }
      }
      expect(allowed, [
        (Pending, Confirmed),
        (Pending, Cancelled),
        (Pending, Arrived),
        (Pending, NoShow),
        (Confirmed, Cancelled),
        (Confirmed, Arrived),
        (Confirmed, NoShow),
      ]);
    });

    test('confirmation, arrival and no-show follow the start of the slot', () {
      final pending = reservationAt(start);
      DateTime at(Duration offset) => start.add(offset);
      expect(confirmReservation(pending, by: waiter, now: at(-const Duration(minutes: 1))).isSuccess, isTrue);
      expect(confirmReservation(pending, by: waiter, now: start), const Failure<Reservation>(ReservationStarted()));
      expect(recordArrival(pending, by: waiter, now: at(-earlyArrival)).isSuccess, isTrue);
      expect(
        recordArrival(pending, by: waiter, now: at(-earlyArrival - const Duration(minutes: 1))),
        const Failure<Reservation>(ArrivalOutsideSlot(early: earlyArrival)),
      );
      expect(
        recordArrival(pending, by: waiter, now: at(TimeSlot.duration)),
        const Failure<Reservation>(ArrivalOutsideSlot(early: earlyArrival)),
      );
      expect(
        recordNoShow(pending, by: waiter, now: at(-const Duration(minutes: 1))),
        const Failure<Reservation>(ReservationNotStarted()),
      );
      expect(recordNoShow(pending, by: waiter, now: start).valueOrNull?.status, isA<NoShow>());
    });
  });

  group('R6 · booking notice', () {
    test('a guest books at least two hours ahead, staff at any time', () {
      final slot = TimeSlot.existing(start);
      expect(mayBook(slot, by: guest, now: start.subtract(cancellationNotice)), isTrue);
      expect(mayBook(slot, by: guest, now: start.subtract(const Duration(hours: 1, minutes: 59))), isFalse);
      expect(mayBook(slot, by: waiter, now: start.subtract(const Duration(minutes: 1))), isTrue);
      expect(initialStatus(by: waiter, now: start), isA<Confirmed>());
      expect(initialStatus(by: guest, now: start), const Pending());
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
        const Failure<Reservation>(CancellationTooLate(notice: Duration(hours: 2))),
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
