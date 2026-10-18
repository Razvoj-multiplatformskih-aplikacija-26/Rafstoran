import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

extension ReservationStatusMapping on ReservationStatus {
  ReservationStatusDto toDto() => switch (this) {
    Pending() => const ReservationStatusDto(kind: ReservationStatusDto.pending),
    Confirmed(:final confirmedBy, :final at) => ReservationStatusDto(
      kind: ReservationStatusDto.confirmed,
      by: confirmedBy.value,
      at: at,
    ),
    Cancelled(:final reason, :final cancelledBy, :final at) => ReservationStatusDto(
      kind: ReservationStatusDto.cancelled,
      by: cancelledBy.value,
      at: at,
      reason: reason,
    ),
    Arrived(:final arrivedAt) => ReservationStatusDto(kind: ReservationStatusDto.arrived, at: arrivedAt),
  };
}

extension ReservationStatusDtoMapping on ReservationStatusDto {
  ReservationStatus toDomain() => switch (this) {
    ReservationStatusDto(kind: ReservationStatusDto.pending) => const Pending(),
    ReservationStatusDto(kind: ReservationStatusDto.confirmed, :final by?, :final at?) => Confirmed(
      confirmedBy: UserId(by),
      at: at,
    ),
    ReservationStatusDto(kind: ReservationStatusDto.cancelled, :final by?, :final at?, :final reason) => Cancelled(
      reason: reason ?? '',
      cancelledBy: UserId(by),
      at: at,
    ),
    ReservationStatusDto(kind: ReservationStatusDto.arrived, :final at?) => Arrived(arrivedAt: at),
    _ => throw FormatException('Unknown reservation status', kind),
  };
}

extension ReservationMapping on Reservation {
  ReservationDto toDto() => ReservationDto(
    id: id.value,
    guestId: guestId.value,
    start: slot.start,
    partySize: partySize.value,
    status: status.toDto(),
    createdAt: createdAt,
    note: note?.text,
    tableId: tableId?.value,
    enteredBy: enteredBy?.value,
  );
}

extension ReservationDtoMapping on ReservationDto {
  Reservation toDomain() => Reservation(
    id: ReservationId(id),
    guestId: UserId(guestId),
    slot: TimeSlot.existing(start),
    partySize: _accepted(PartySize.parse(partySize)),
    status: status.toDomain(),
    createdAt: createdAt,
    note: note == null ? null : _accepted(ReservationNote.parse(note!)),
    tableId: tableId == null ? null : DiningTableId(tableId!),
    enteredBy: enteredBy == null ? null : UserId(enteredBy!),
  );
}

T _accepted<T>(Result<T> result) => switch (result) {
  Success(:final value) => value,
  Failure(:final error) => throw FormatException('The contract carried a value the domain rejects', error),
};
