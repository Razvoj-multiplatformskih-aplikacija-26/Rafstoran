import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:test/test.dart';

Map<String, Object?> overTheWire(Map<String, Object?> json) => jsonDecode(jsonEncode(json)) as Map<String, Object?>;

void main() {
  test('a reservation survives the trip through the contract unchanged', () {
    final start = DateTime.utc(2026, 10, 30, 18);
    final reservation = Reservation(
      id: const ReservationId('r-1'),
      guest: ContactGuest.parse(name: 'Ana Petrović', phone: '064 123 4567').valueOrNull!,
      slot: TimeSlot.existing(start),
      partySize: PartySize.parse(4).valueOrNull!,
      createdAt: DateTime.utc(2026, 10, 28, 9, 15),
      note: ReservationNote.parse('Sto pored prozora 🪟').valueOrNull,
      tableId: const DiningTableId('t-03'),
      enteredBy: const UserId('u-waiter'),
    );

    for (final status in [
      Cancelled(reason: 'Promena plana.', cancelledBy: const UserId('u-waiter'), at: DateTime.utc(2026, 10, 29)),
      NoShow(recordedBy: const UserId('u-waiter'), at: start.add(const Duration(minutes: 30))),
    ]) {
      final sent = reservation.copyWith(status: status);
      expect(ReservationDto.fromJson(overTheWire(sent.toDto().toJson())).toDomain(), sent);
    }
  });

  test('every domain error has a code and comes back as the same error', () {
    final errors = <DomainError>[
      const NoteTooLong(201, max: 200),
      const InvalidPartySize(13, min: 1, max: 12),
      const SlotInPast(),
      const SlotNotOnHalfHour(),
      const OutsideOpeningHours(),
      const CancellationTooLate(notice: Duration(hours: 2)),
      InvalidTransition(
        from: Arrived(arrivedAt: DateTime.utc(2026, 10, 1)),
        to: const Pending(),
      ),
      const TooSoonToBook(notice: Duration(hours: 2)),
      const ReservationStarted(),
      const ReservationNotStarted(),
      const ArrivalOutsideSlot(early: Duration(hours: 1)),
      const NoTableAvailable(),
      const GuestAlreadyBooked(),
      const InvalidGuestName(61, max: 60),
      const InvalidPhoneNumber(min: 6, max: 15),
      const NotAllowed(),
      const NotFound(),
    ];

    for (final error in errors) {
      final problem = ProblemDto.fromJson(overTheWire(error.toProblem().toJson()));
      expect(problem.toDomainError(), error, reason: problem.code);
    }
  });
}
