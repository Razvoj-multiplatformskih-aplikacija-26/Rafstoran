import 'package:flutter/material.dart';

abstract final class RafColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2E6BB8),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC6D6EA),
    onPrimaryContainer: Color(0xFF14233B),
    secondary: Color(0xFF4F5D6E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE3ECF7),
    onSecondaryContainer: Color(0xFF26313F),
    tertiary: Color(0xFFA65E1E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF6E3C4),
    onTertiaryContainer: Color(0xFF4A2A08),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFF6F8FB),
    onSurface: Color(0xFF14233B),
    surfaceDim: Color(0xFFD6DEE8),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEEF3F9),
    surfaceContainer: Color(0xFFE3ECF7),
    surfaceContainerHigh: Color(0xFFD6E2F0),
    surfaceContainerHighest: Color(0xFFC6D5E6),
    onSurfaceVariant: Color(0xFF4F5D6E),
    outline: Color(0xFF7A8899),
    outlineVariant: Color(0xFFC6D5E6),
    inverseSurface: Color(0xFF14233B),
    onInverseSurface: Color(0xFFE3ECF7),
    inversePrimary: Color(0xFF9DBDE8),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9DBDE8),
    onPrimary: Color(0xFF14233B),
    primaryContainer: Color(0xFF2E6BB8),
    onPrimaryContainer: Color(0xFFE3ECF7),
    secondary: Color(0xFFC6D5E6),
    onSecondary: Color(0xFF26313F),
    secondaryContainer: Color(0xFF3A4D66),
    onSecondaryContainer: Color(0xFFE3ECF7),
    tertiary: Color(0xFFF0B27A),
    onTertiary: Color(0xFF4A2A08),
    tertiaryContainer: Color(0xFF6B3F12),
    onTertiaryContainer: Color(0xFFFFE2C4),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF14233B),
    onSurface: Color(0xFFE3ECF7),
    surfaceDim: Color(0xFF0F1B2E),
    surfaceBright: Color(0xFF3A4D66),
    surfaceContainerLowest: Color(0xFF0F1B2E),
    surfaceContainerLow: Color(0xFF1B2C47),
    surfaceContainer: Color(0xFF223556),
    surfaceContainerHigh: Color(0xFF2A3F63),
    surfaceContainerHighest: Color(0xFF33496F),
    onSurfaceVariant: Color(0xFFC6D5E6),
    outline: Color(0xFF9AA8B8),
    outlineVariant: Color(0xFF3A4D66),
    inverseSurface: Color(0xFFE3ECF7),
    onInverseSurface: Color(0xFF14233B),
    inversePrimary: Color(0xFF2E6BB8),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}

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

  final Color pending;
  final Color onPending;
  final Color confirmed;
  final Color onConfirmed;
  final Color cancelled;
  final Color onCancelled;
  final Color arrived;
  final Color onArrived;

  static const light = ReservationStatusColors(
    pending: Color(0xFFF6E3C4),
    onPending: Color(0xFF7D5313),
    confirmed: Color(0xFFD5E8DA),
    onConfirmed: Color(0xFF2E6B45),
    cancelled: Color(0xFFECD6D6),
    onCancelled: Color(0xFF8A4A4A),
    arrived: Color(0xFFC6D6EA),
    onArrived: Color(0xFF245693),
  );

  static const dark = ReservationStatusColors(
    pending: Color(0xFF4F3A10),
    onPending: Color(0xFFF0C27A),
    confirmed: Color(0xFF1F4A30),
    onConfirmed: Color(0xFF8FD1A5),
    cancelled: Color(0xFF4E2626),
    onCancelled: Color(0xFFE3A3A3),
    arrived: Color(0xFF24436B),
    onArrived: Color(0xFFA9CBF0),
  );

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
