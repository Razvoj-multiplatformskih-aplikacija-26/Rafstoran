import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

@immutable
class ReservationStatusColors extends ThemeExtension<ReservationStatusColors> {
  const ReservationStatusColors({
    required this.pending,
    required this.onPending,
    required this.confirmed,
    required this.onConfirmed,
    required this.cancelled,
    required this.onCancelled,
    required this.arrived,
    required this.onArrived,
  });

  factory ReservationStatusColors.fromTokens(StatusColorTokens t) => ReservationStatusColors(
    pending: Color(t.pending),
    onPending: Color(t.onPending),
    confirmed: Color(t.confirmed),
    onConfirmed: Color(t.onConfirmed),
    cancelled: Color(t.cancelled),
    onCancelled: Color(t.onCancelled),
    arrived: Color(t.arrived),
    onArrived: Color(t.onArrived),
  );

  static final light = ReservationStatusColors.fromTokens(StatusColorTokens.light);
  static final dark = ReservationStatusColors.fromTokens(StatusColorTokens.dark);

  final Color pending;
  final Color onPending;
  final Color confirmed;
  final Color onConfirmed;
  final Color cancelled;
  final Color onCancelled;
  final Color arrived;
  final Color onArrived;

  @override
  ReservationStatusColors copyWith({
    Color? pending,
    Color? onPending,
    Color? confirmed,
    Color? onConfirmed,
    Color? cancelled,
    Color? onCancelled,
    Color? arrived,
    Color? onArrived,
  }) {
    return ReservationStatusColors(
      pending: pending ?? this.pending,
      onPending: onPending ?? this.onPending,
      confirmed: confirmed ?? this.confirmed,
      onConfirmed: onConfirmed ?? this.onConfirmed,
      cancelled: cancelled ?? this.cancelled,
      onCancelled: onCancelled ?? this.onCancelled,
      arrived: arrived ?? this.arrived,
      onArrived: onArrived ?? this.onArrived,
    );
  }

  @override
  ReservationStatusColors lerp(ReservationStatusColors? other, double t) {
    if (other == null) return this;
    return ReservationStatusColors(
      pending: Color.lerp(pending, other.pending, t)!,
      onPending: Color.lerp(onPending, other.onPending, t)!,
      confirmed: Color.lerp(confirmed, other.confirmed, t)!,
      onConfirmed: Color.lerp(onConfirmed, other.onConfirmed, t)!,
      cancelled: Color.lerp(cancelled, other.cancelled, t)!,
      onCancelled: Color.lerp(onCancelled, other.onCancelled, t)!,
      arrived: Color.lerp(arrived, other.arrived, t)!,
      onArrived: Color.lerp(onArrived, other.onArrived, t)!,
    );
  }
}

extension ReservationStatusColorsX on ThemeData {
  ReservationStatusColors get statusColors => extension<ReservationStatusColors>() ?? ReservationStatusColors.light;
}
