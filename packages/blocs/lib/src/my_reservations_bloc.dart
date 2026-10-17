import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

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

final class MyReservationsBloc extends Bloc<MyReservationsEvent, MyReservationsState> {
  MyReservationsBloc({
    required this.getMyReservations,
    required this.cancelReservation,
    required this.clock,
    required this.guest,
  }) : super(const MyReservationsLoading()) {
    on<MyReservationsRequested>((event, emit) async {
      emit(const MyReservationsLoading());
      await _reload(emit);
    });
    on<MyReservationsRefreshed>((event, emit) async {
      try {
        await _reload(emit);
      } finally {
        event._handled.complete();
      }
    });
    on<ReservationCancellationRequested>(_onCancellationRequested);
    on<MyReservationsNoticeAcknowledged>((event, emit) {
      final current = state;
      if (current is MyReservationsLoaded && current.notice != null) emit(current.withNotice(null));
    });
  }

  final GetMyReservations getMyReservations;
  final CancelReservation cancelReservation;
  final Clock clock;
  final User guest;

  Future<void> _onCancellationRequested(
    ReservationCancellationRequested event,
    Emitter<MyReservationsState> emit,
  ) async {
    final current = state;
    if (current is! MyReservationsLoaded) return;
    emit(current.withCancelling(event.id));
    final Result<Reservation> result;
    try {
      result = await cancelReservation(id: event.id, by: guest, reason: event.reason);
    } on Exception catch (cause) {
      emit(current.withNotice(CancellationFailed(cause)));
      return;
    }
    switch (result) {
      case Success(:final value):
        await _reload(emit, notice: ReservationCancelled(value));
      case Failure(:final error):
        emit(current.withNotice(CancellationRejected(error)));
    }
  }

  Future<void> _reload(Emitter<MyReservationsState> emit, {MyReservationsNotice? notice}) async {
    try {
      final reservations = await getMyReservations(guest);
      if (reservations.isEmpty) {
        emit(const MyReservationsEmpty());
        return;
      }
      final now = clock.now();
      final upcoming = reservations.where((r) => r.slot.end.isAfter(now)).toList();
      final past = reservations.where((r) => !r.slot.end.isAfter(now)).toList().reversed.toList();
      final cancellable = {
        for (final r in upcoming)
          if (!r.status.isFinal && AccessPolicy.canCancel(guest, r) && guestMayStillCancel(r, now: now)) r.id,
      };
      emit(MyReservationsLoaded(upcoming: upcoming, past: past, cancellable: cancellable, notice: notice));
    } on Exception catch (cause) {
      emit(MyReservationsFailure(cause));
    }
  }
}
