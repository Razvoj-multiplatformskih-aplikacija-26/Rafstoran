part of 'my_reservations_bloc.dart';

sealed class MyReservationsState extends Equatable {
  const MyReservationsState();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => '$runtimeType';
}

final class MyReservationsLoading extends MyReservationsState {
  const MyReservationsLoading();
}

final class MyReservationsFailure extends MyReservationsState {
  const MyReservationsFailure(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];

  @override
  String toString() => 'MyReservationsFailure($cause)';
}

final class MyReservationsEmpty extends MyReservationsState {
  const MyReservationsEmpty();
}

final class MyReservationsLoaded extends MyReservationsState {
  const MyReservationsLoaded({
    required this.upcoming,
    required this.past,
    required this.cancellable,
    this.notice,
    this.cancellingId,
  });

  final List<Reservation> upcoming;
  final List<Reservation> past;
  final Set<ReservationId> cancellable;
  final MyReservationsNotice? notice;
  final ReservationId? cancellingId;

  @override
  List<Object?> get props => [upcoming, past, cancellable, notice, cancellingId];

  @override
  String toString() => [
    'MyReservationsLoaded(${upcoming.length} upcoming, ${past.length} past',
    if (cancellingId case final id?) ', cancelling ${id.value}',
    if (notice case final notice?) ', ${notice.runtimeType}',
    ')',
  ].join();

  bool canCancel(Reservation reservation) => cancellable.contains(reservation.id);

  bool get isBusy => cancellingId != null;

  bool isCancelling(Reservation reservation) => cancellingId == reservation.id;

  MyReservationsLoaded withNotice(MyReservationsNotice? notice) =>
      MyReservationsLoaded(upcoming: upcoming, past: past, cancellable: cancellable, notice: notice);

  MyReservationsLoaded withCancelling(ReservationId id) =>
      MyReservationsLoaded(upcoming: upcoming, past: past, cancellable: cancellable, cancellingId: id);
}

sealed class MyReservationsNotice extends Equatable {
  const MyReservationsNotice();

  @override
  List<Object?> get props => const [];
}

final class ReservationCancelled extends MyReservationsNotice {
  const ReservationCancelled(this.reservation);

  final Reservation reservation;

  @override
  List<Object?> get props => [reservation];
}

final class CancellationRejected extends MyReservationsNotice {
  const CancellationRejected(this.error);

  final DomainError error;

  @override
  List<Object?> get props => [error];
}

final class CancellationFailed extends MyReservationsNotice {
  const CancellationFailed(this.cause);

  final Object cause;

  @override
  List<Object?> get props => [cause];
}
