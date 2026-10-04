import 'access_policy.dart';
import 'errors.dart';
import 'reservation.dart';
import 'reservation_status.dart';
import 'result.dart';
import 'user.dart';

const cancellationNotice = Duration(hours: 2);

DateTime cancellationDeadline(Reservation reservation) => reservation.slot.start.subtract(cancellationNotice);

bool guestMayStillCancel(Reservation reservation, {required DateTime now}) =>
    !now.toUtc().isAfter(cancellationDeadline(reservation));

Result<Reservation> confirmReservation(Reservation reservation, {required User by, required DateTime now}) {
  if (!AccessPolicy.canConfirm(by)) return const Failure(NotAllowed());
  final next = Confirmed(confirmedBy: by.id, at: now.toUtc());
  return _transition(reservation, next);
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
  return Success(reservation.copyWith(status: next));
}

Result<Reservation> recordArrival(Reservation reservation, {required User by, required DateTime now}) {
  if (!AccessPolicy.canRecordArrival(by)) return const Failure(NotAllowed());
  return _transition(reservation, Arrived(arrivedAt: now.toUtc()));
}

Result<Reservation> _transition(Reservation reservation, ReservationStatus next) {
  if (!canTransition(reservation.status, next)) {
    return Failure(InvalidTransition(from: reservation.status, to: next));
  }
  return Success(reservation.copyWith(status: next));
}
