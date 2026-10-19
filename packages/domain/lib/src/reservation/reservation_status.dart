import 'package:meta/meta.dart';

import '../identifiers.dart';

sealed class ReservationStatus {
  const ReservationStatus();

  bool get isActive => switch (this) {
    Pending() || Confirmed() || Arrived() => true,
    Cancelled() || NoShow() => false,
  };

  bool get isFinal => switch (this) {
    Cancelled() || Arrived() || NoShow() => true,
    Pending() || Confirmed() => false,
  };
}

final class Pending extends ReservationStatus {
  const Pending();

  @override
  String toString() => 'Pending';
}

@immutable
final class Confirmed extends ReservationStatus {
  const Confirmed({required this.confirmedBy, required this.at});

  final UserId confirmedBy;
  final DateTime at;

  @override
  bool operator ==(Object other) => other is Confirmed && other.confirmedBy == confirmedBy && other.at == at;

  @override
  int get hashCode => Object.hash(confirmedBy, at);

  @override
  String toString() => 'Confirmed(by $confirmedBy at $at)';
}

@immutable
final class Cancelled extends ReservationStatus {
  const Cancelled({required this.reason, required this.cancelledBy, required this.at});

  final String reason;
  final UserId cancelledBy;
  final DateTime at;

  @override
  bool operator ==(Object other) =>
      other is Cancelled && other.reason == reason && other.cancelledBy == cancelledBy && other.at == at;

  @override
  int get hashCode => Object.hash(reason, cancelledBy, at);

  @override
  String toString() => 'Cancelled("$reason" by $cancelledBy at $at)';
}

@immutable
final class Arrived extends ReservationStatus {
  const Arrived({required this.arrivedAt});

  final DateTime arrivedAt;

  @override
  bool operator ==(Object other) => other is Arrived && other.arrivedAt == arrivedAt;

  @override
  int get hashCode => arrivedAt.hashCode;

  @override
  String toString() => 'Arrived(at $arrivedAt)';
}

@immutable
final class NoShow extends ReservationStatus {
  const NoShow({required this.recordedBy, required this.at});

  final UserId recordedBy;
  final DateTime at;

  @override
  bool operator ==(Object other) => other is NoShow && other.recordedBy == recordedBy && other.at == at;

  @override
  int get hashCode => Object.hash(recordedBy, at);

  @override
  String toString() => 'NoShow(by $recordedBy at $at)';
}

bool canTransition(ReservationStatus from, ReservationStatus to) => switch ((from, to)) {
  (Pending(), Confirmed()) => true,
  (Pending() || Confirmed(), Cancelled()) => true,
  (Pending() || Confirmed(), Arrived()) => true,
  (Pending() || Confirmed(), NoShow()) => true,
  _ => false,
};
