import 'package:meta/meta.dart';

import 'reservation/reservation_status.dart';

sealed class DomainError {
  const DomainError();
}

@immutable
final class NoteTooLong extends DomainError {
  const NoteTooLong(this.length, {required this.max});

  final int length;
  final int max;

  @override
  bool operator ==(Object other) => other is NoteTooLong && other.length == length && other.max == max;

  @override
  int get hashCode => Object.hash(NoteTooLong, length, max);

  @override
  String toString() => 'NoteTooLong($length, max: $max)';
}

@immutable
final class InvalidPartySize extends DomainError {
  const InvalidPartySize(this.size, {required this.min, required this.max});

  final int size;
  final int min;
  final int max;

  @override
  bool operator ==(Object other) =>
      other is InvalidPartySize && other.size == size && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(InvalidPartySize, size, min, max);

  @override
  String toString() => 'InvalidPartySize($size, min: $min, max: $max)';
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

@immutable
final class CancellationTooLate extends DomainError {
  const CancellationTooLate({required this.notice});

  final Duration notice;

  @override
  bool operator ==(Object other) => other is CancellationTooLate && other.notice == notice;

  @override
  int get hashCode => Object.hash(CancellationTooLate, notice);

  @override
  String toString() => 'CancellationTooLate(notice: $notice)';
}

@immutable
final class TooSoonToBook extends DomainError {
  const TooSoonToBook({required this.notice});

  final Duration notice;

  @override
  bool operator ==(Object other) => other is TooSoonToBook && other.notice == notice;

  @override
  int get hashCode => Object.hash(TooSoonToBook, notice);

  @override
  String toString() => 'TooSoonToBook(notice: $notice)';
}

final class ReservationStarted extends DomainError {
  const ReservationStarted();
}

final class ReservationNotStarted extends DomainError {
  const ReservationNotStarted();
}

@immutable
final class ArrivalOutsideSlot extends DomainError {
  const ArrivalOutsideSlot({required this.early});

  final Duration early;

  @override
  bool operator ==(Object other) => other is ArrivalOutsideSlot && other.early == early;

  @override
  int get hashCode => Object.hash(ArrivalOutsideSlot, early);

  @override
  String toString() => 'ArrivalOutsideSlot(early: $early)';
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

final class GuestAlreadyBooked extends DomainError {
  const GuestAlreadyBooked();
}

@immutable
final class InvalidGuestName extends DomainError {
  const InvalidGuestName(this.length, {required this.max});

  final int length;
  final int max;

  @override
  bool operator ==(Object other) => other is InvalidGuestName && other.length == length && other.max == max;

  @override
  int get hashCode => Object.hash(InvalidGuestName, length, max);

  @override
  String toString() => 'InvalidGuestName($length, max: $max)';
}

@immutable
final class InvalidPhoneNumber extends DomainError {
  const InvalidPhoneNumber({required this.min, required this.max});

  final int min;
  final int max;

  @override
  bool operator ==(Object other) => other is InvalidPhoneNumber && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(InvalidPhoneNumber, min, max);

  @override
  String toString() => 'InvalidPhoneNumber(min: $min, max: $max)';
}

final class NotAllowed extends DomainError {
  const NotAllowed();
}

final class NotFound extends DomainError {
  const NotFound();
}
