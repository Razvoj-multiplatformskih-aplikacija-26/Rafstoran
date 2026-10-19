import '../errors.dart';
import '../restaurant/time_slot.dart';
import '../result.dart';
import '../user.dart';
import 'access_policy.dart';
import 'reservation.dart';
import 'reservation_status.dart';

const cancellationNotice = Duration(hours: 2);
const earlyArrival = Duration(hours: 1);

DateTime cancellationDeadline(Reservation reservation) => reservation.slot.start.subtract(cancellationNotice);

bool guestMayStillCancel(Reservation reservation, {required DateTime now}) =>
    !now.toUtc().isAfter(cancellationDeadline(reservation));

Duration bookingNoticeFor(User user) => user.role.isStaff ? Duration.zero : cancellationNotice;

bool mayBook(TimeSlot slot, {required User by, required DateTime now}) =>
    !slot.start.isBefore(now.toUtc().add(bookingNoticeFor(by)));

ReservationStatus initialStatus({required User by, required DateTime now}) =>
    by.role.isStaff ? Confirmed(confirmedBy: by.id, at: now.toUtc()) : const Pending();

bool hasStarted(Reservation reservation, {required DateTime now}) => !now.toUtc().isBefore(reservation.slot.start);

bool isArrivalTime(Reservation reservation, {required DateTime now}) {
  final instant = now.toUtc();
  return !instant.isBefore(reservation.slot.start.subtract(earlyArrival)) && instant.isBefore(reservation.slot.end);
}

Result<Reservation> confirmReservation(Reservation reservation, {required User by, required DateTime now}) {
  if (!AccessPolicy.canConfirm(by)) return const Failure(NotAllowed());
  final next = Confirmed(confirmedBy: by.id, at: now.toUtc());
  if (!canTransition(reservation.status, next)) {
    return Failure(InvalidTransition(from: reservation.status, to: next));
  }
  if (hasStarted(reservation, now: now)) return const Failure(ReservationStarted());
  return Success(reservation.copyWith(status: next));
}

Result<Reservation> cancelReservation(
  Reservation reservation, {
  required User by,
  required DateTime now,
  String reason = '',
}) {
  if (!AccessPolicy.canCancel(by, reservation)) return const Failure(NotAllowed());
  final next = Cancelled(reason: reason, cancelledBy: by.id, at: now.toUtc());
  if (!canTransition(reservation.status, next)) {
    return Failure(InvalidTransition(from: reservation.status, to: next));
  }
  if (by.role == Role.guest && !guestMayStillCancel(reservation, now: now)) {
    return const Failure(CancellationTooLate());
  }
  if (hasStarted(reservation, now: now)) return const Failure(ReservationStarted());
  return Success(reservation.copyWith(status: next));
}

Result<Reservation> recordArrival(Reservation reservation, {required User by, required DateTime now}) {
  if (!AccessPolicy.canRecordArrival(by)) return const Failure(NotAllowed());
  final next = Arrived(arrivedAt: now.toUtc());
  if (!canTransition(reservation.status, next)) {
    return Failure(InvalidTransition(from: reservation.status, to: next));
  }
  if (!isArrivalTime(reservation, now: now)) return const Failure(ArrivalOutsideSlot());
  return Success(reservation.copyWith(status: next));
}

Result<Reservation> recordNoShow(Reservation reservation, {required User by, required DateTime now}) {
  if (!AccessPolicy.canRecordArrival(by)) return const Failure(NotAllowed());
  final next = NoShow(recordedBy: by.id, at: now.toUtc());
  if (!canTransition(reservation.status, next)) {
    return Failure(InvalidTransition(from: reservation.status, to: next));
  }
  if (!hasStarted(reservation, now: now)) return const Failure(ReservationNotStarted());
  return Success(reservation.copyWith(status: next));
}
