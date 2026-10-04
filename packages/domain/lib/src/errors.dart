import 'package:meta/meta.dart';

import 'reservation_status.dart';

sealed class DomainError {
  const DomainError();
}

@immutable
final class NoteTooLong extends DomainError {
  const NoteTooLong(this.length);

  final int length;

  @override
  bool operator ==(Object other) => other is NoteTooLong && other.length == length;

  @override
  int get hashCode => Object.hash(NoteTooLong, length);

  @override
  String toString() => 'NoteTooLong($length)';
}

@immutable
final class InvalidPartySize extends DomainError {
  const InvalidPartySize(this.size);

  final int size;

  @override
  bool operator ==(Object other) => other is InvalidPartySize && other.size == size;

  @override
  int get hashCode => Object.hash(InvalidPartySize, size);

  @override
  String toString() => 'InvalidPartySize($size)';
}

final class SlotInPast extends DomainError {
  const SlotInPast();
}

final class SlotNotOnHalfHour extends DomainError {
  const SlotNotOnHalfHour();
}

final class OutsideOpeningHours extends DomainError {
  const OutsideOpeningHours();
}

final class CancellationTooLate extends DomainError {
  const CancellationTooLate();
}

@immutable
final class InvalidTransition extends DomainError {
  const InvalidTransition({required this.from, required this.to});

  final ReservationStatus from;
  final ReservationStatus to;

  @override
  bool operator ==(Object other) =>
      other is InvalidTransition &&
      other.from.runtimeType == from.runtimeType &&
      other.to.runtimeType == to.runtimeType;

  @override
  int get hashCode => Object.hash(InvalidTransition, from.runtimeType, to.runtimeType);

  @override
  String toString() => 'InvalidTransition(${from.runtimeType} -> ${to.runtimeType})';
}

final class NoTableAvailable extends DomainError {
  const NoTableAvailable();
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class NotFound extends DomainError {
  const NotFound();
}
