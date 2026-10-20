import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'reservation_mapping.dart';

extension DomainErrorMapping on DomainError {
  ProblemDto toProblem() => switch (this) {
    NoteTooLong(:final length, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.noteTooLong,
      title: 'Note too long',
      value: length,
      max: max,
    ),
    InvalidPartySize(:final size, :final min, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.invalidPartySize,
      title: 'Invalid party size',
      value: size,
      min: min,
      max: max,
    ),
    SlotInPast() => const ProblemDto(status: 422, code: ErrorCodes.slotInPast, title: 'Slot in the past'),
    SlotNotOnHalfHour() => const ProblemDto(
      status: 422,
      code: ErrorCodes.slotNotOnHalfHour,
      title: 'Slot not on a half hour',
    ),
    OutsideOpeningHours() => const ProblemDto(
      status: 422,
      code: ErrorCodes.outsideOpeningHours,
      title: 'Outside opening hours',
    ),
    CancellationTooLate(:final notice) => ProblemDto(
      status: 422,
      code: ErrorCodes.cancellationTooLate,
      title: 'Cancellation too late',
      min: notice.inMinutes,
    ),
    TooSoonToBook(:final notice) => ProblemDto(
      status: 422,
      code: ErrorCodes.tooSoonToBook,
      title: 'Too soon to book',
      min: notice.inMinutes,
    ),
    ReservationStarted() => const ProblemDto(
      status: 422,
      code: ErrorCodes.reservationStarted,
      title: 'Reservation started',
    ),
    ReservationNotStarted() => const ProblemDto(
      status: 422,
      code: ErrorCodes.reservationNotStarted,
      title: 'Reservation not started',
    ),
    ArrivalOutsideSlot(:final early) => ProblemDto(
      status: 422,
      code: ErrorCodes.arrivalOutsideSlot,
      title: 'Arrival outside the slot',
      min: early.inMinutes,
    ),
    InvalidTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidTransition,
      title: 'Invalid transition',
      from: from.toDto(),
      to: to.toDto(),
    ),
    NoTableAvailable() => const ProblemDto(status: 409, code: ErrorCodes.noTableAvailable, title: 'No table available'),
    GuestAlreadyBooked() => const ProblemDto(
      status: 409,
      code: ErrorCodes.guestAlreadyBooked,
      title: 'Guest already booked',
    ),
    InvalidGuestName(:final length, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.invalidGuestName,
      title: 'Invalid guest name',
      value: length,
      max: max,
    ),
    InvalidPhoneNumber(:final min, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.invalidPhoneNumber,
      title: 'Invalid phone number',
      min: min,
      max: max,
    ),
    NotAllowed() => const ProblemDto(status: 403, code: ErrorCodes.notAllowed, title: 'Not allowed'),
    NotFound() => const ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'Not found'),
  };
}

extension ProblemMapping on ProblemDto {
  DomainError? toDomainError() => switch (this) {
    ProblemDto(code: ErrorCodes.noteTooLong, :final value?, :final max?) => NoteTooLong(value, max: max),
    ProblemDto(code: ErrorCodes.invalidPartySize, :final value?, :final min?, :final max?) => InvalidPartySize(
      value,
      min: min,
      max: max,
    ),
    ProblemDto(code: ErrorCodes.slotInPast) => const SlotInPast(),
    ProblemDto(code: ErrorCodes.slotNotOnHalfHour) => const SlotNotOnHalfHour(),
    ProblemDto(code: ErrorCodes.outsideOpeningHours) => const OutsideOpeningHours(),
    ProblemDto(code: ErrorCodes.cancellationTooLate, :final min?) => CancellationTooLate(
      notice: Duration(minutes: min),
    ),
    ProblemDto(code: ErrorCodes.tooSoonToBook, :final min?) => TooSoonToBook(notice: Duration(minutes: min)),
    ProblemDto(code: ErrorCodes.reservationStarted) => const ReservationStarted(),
    ProblemDto(code: ErrorCodes.reservationNotStarted) => const ReservationNotStarted(),
    ProblemDto(code: ErrorCodes.arrivalOutsideSlot, :final min?) => ArrivalOutsideSlot(early: Duration(minutes: min)),
    ProblemDto(code: ErrorCodes.invalidTransition, :final from?, :final to?) => InvalidTransition(
      from: from.toDomain(),
      to: to.toDomain(),
    ),
    ProblemDto(code: ErrorCodes.noTableAvailable) => const NoTableAvailable(),
    ProblemDto(code: ErrorCodes.guestAlreadyBooked) => const GuestAlreadyBooked(),
    ProblemDto(code: ErrorCodes.invalidGuestName, :final value?, :final max?) => InvalidGuestName(value, max: max),
    ProblemDto(code: ErrorCodes.invalidPhoneNumber, :final min?, :final max?) => InvalidPhoneNumber(min: min, max: max),
    ProblemDto(code: ErrorCodes.notAllowed) => const NotAllowed(),
    ProblemDto(code: ErrorCodes.notFound) => const NotFound(),
    _ => null,
  };
}
