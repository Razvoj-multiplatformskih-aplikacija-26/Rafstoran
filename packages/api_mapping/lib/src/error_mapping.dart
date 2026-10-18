import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'reservation_mapping.dart';

extension DomainErrorMapping on DomainError {
  ProblemDto toProblem() => switch (this) {
    NoteTooLong(:final length) => ProblemDto(
      status: 422,
      code: ErrorCodes.noteTooLong,
      title: 'Note too long',
      value: length,
    ),
    InvalidPartySize(:final size) => ProblemDto(
      status: 422,
      code: ErrorCodes.invalidPartySize,
      title: 'Invalid party size',
      value: size,
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
    CancellationTooLate() => const ProblemDto(
      status: 422,
      code: ErrorCodes.cancellationTooLate,
      title: 'Cancellation too late',
    ),
    InvalidTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidTransition,
      title: 'Invalid transition',
      from: from.toDto(),
      to: to.toDto(),
    ),
    NoTableAvailable() => const ProblemDto(status: 409, code: ErrorCodes.noTableAvailable, title: 'No table available'),
    NotAllowed() => const ProblemDto(status: 403, code: ErrorCodes.notAllowed, title: 'Not allowed'),
    NotFound() => const ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'Not found'),
  };
}

extension ProblemMapping on ProblemDto {
  DomainError? toDomainError() => switch (this) {
    ProblemDto(code: ErrorCodes.noteTooLong, :final value?) => NoteTooLong(value),
    ProblemDto(code: ErrorCodes.invalidPartySize, :final value?) => InvalidPartySize(value),
    ProblemDto(code: ErrorCodes.slotInPast) => const SlotInPast(),
    ProblemDto(code: ErrorCodes.slotNotOnHalfHour) => const SlotNotOnHalfHour(),
    ProblemDto(code: ErrorCodes.outsideOpeningHours) => const OutsideOpeningHours(),
    ProblemDto(code: ErrorCodes.cancellationTooLate) => const CancellationTooLate(),
    ProblemDto(code: ErrorCodes.invalidTransition, :final from?, :final to?) => InvalidTransition(
      from: from.toDomain(),
      to: to.toDomain(),
    ),
    ProblemDto(code: ErrorCodes.noTableAvailable) => const NoTableAvailable(),
    ProblemDto(code: ErrorCodes.notAllowed) => const NotAllowed(),
    ProblemDto(code: ErrorCodes.notFound) => const NotFound(),
    _ => null,
  };
}
