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
      guestId: const UserId('u-ana'),
      slot: TimeSlot.existing(start),
      partySize: PartySize.parse(4).valueOrNull!,
      createdAt: DateTime.utc(2026, 10, 28, 9, 15),
      note: ReservationNote.parse('Sto pored prozora 🪟').valueOrNull,
      tableId: const DiningTableId('t-03'),
      status: Cancelled(reason: 'Promena plana.', cancelledBy: const UserId('u-ana'), at: DateTime.utc(2026, 10, 29)),
      enteredBy: const UserId('u-waiter'),
    );

    final received = ReservationDto.fromJson(overTheWire(reservation.toDto().toJson())).toDomain();

    expect(received, reservation);
  });

  test('every domain error has a code and comes back as the same error', () {
    final errors = <DomainError>[
      const NoteTooLong(201),
      const InvalidPartySize(13),
      const SlotInPast(),
      const SlotNotOnHalfHour(),
      const OutsideOpeningHours(),
      const CancellationTooLate(),
      InvalidTransition(
        from: Arrived(arrivedAt: DateTime.utc(2026, 10, 1)),
        to: const Pending(),
      ),
      const NoTableAvailable(),
      const NotAllowed(),
      const NotFound(),
    ];

    for (final error in errors) {
      final problem = ProblemDto.fromJson(overTheWire(error.toProblem().toJson()));
      expect(problem.toDomainError(), error, reason: problem.code);
    }
  });
}
