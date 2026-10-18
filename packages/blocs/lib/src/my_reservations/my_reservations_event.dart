part of 'my_reservations_bloc.dart';

sealed class MyReservationsEvent {
  const MyReservationsEvent();
}

final class MyReservationsRequested extends MyReservationsEvent {
  const MyReservationsRequested();
}

final class MyReservationsRefreshed extends MyReservationsEvent {
  MyReservationsRefreshed();

  final _handled = Completer<void>();

  Future<void> get handled => _handled.future;
}

final class ReservationCancellationRequested extends MyReservationsEvent {
  const ReservationCancellationRequested(this.id, {this.reason = ''});

  final ReservationId id;
  final String reason;
}

final class MyReservationsNoticeAcknowledged extends MyReservationsEvent {
  const MyReservationsNoticeAcknowledged();
}
