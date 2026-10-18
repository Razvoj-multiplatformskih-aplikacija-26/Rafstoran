import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:use_cases/use_cases.dart';

part 'my_reservations_event.dart';
part 'my_reservations_state.dart';

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
