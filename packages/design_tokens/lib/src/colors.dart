abstract final class BrandColors {
  static const navy = 0xFF14233B;
  static const blue = 0xFF2E6BB8;
  static const lightBlue = 0xFFC6D6EA;
  static const paleBlue = 0xFFE3ECF7;
  static const slate = 0xFF63707F;
  static const ink = 0xFF26313F;
  static const mist = 0xFF9AA8B8;
  static const warmAccent = 0xFFA65E1E;
}

final class ColorTokens {
  const ColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.shadow,
    required this.scrim,
  });

  final int primary;
  final int onPrimary;
  final int primaryContainer;
  final int onPrimaryContainer;
  final int secondary;
  final int onSecondary;
  final int secondaryContainer;
  final int onSecondaryContainer;
  final int tertiary;
  final int onTertiary;
  final int tertiaryContainer;
  final int onTertiaryContainer;
  final int error;
  final int onError;
  final int errorContainer;
  final int onErrorContainer;
  final int surface;
  final int onSurface;
  final int surfaceDim;
  final int surfaceBright;
  final int surfaceContainerLowest;
  final int surfaceContainerLow;
  final int surfaceContainer;
  final int surfaceContainerHigh;
  final int surfaceContainerHighest;
  final int onSurfaceVariant;
  final int outline;
  final int outlineVariant;
  final int inverseSurface;
  final int onInverseSurface;
  final int inversePrimary;
  final int shadow;
  final int scrim;

  static const light = ColorTokens(
    primary: 0xFF2E6BB8,
    onPrimary: 0xFFFFFFFF,
    primaryContainer: 0xFFC6D6EA,
    onPrimaryContainer: 0xFF14233B,
    secondary: 0xFF4F5D6E,
    onSecondary: 0xFFFFFFFF,
    secondaryContainer: 0xFFE3ECF7,
    onSecondaryContainer: 0xFF26313F,
    tertiary: 0xFFA65E1E,
    onTertiary: 0xFFFFFFFF,
    tertiaryContainer: 0xFFF6E3C4,
    onTertiaryContainer: 0xFF4A2A08,
    error: 0xFFB3261E,
    onError: 0xFFFFFFFF,
    errorContainer: 0xFFF9DEDC,
    onErrorContainer: 0xFF410E0B,
    surface: 0xFFF6F8FB,
    onSurface: 0xFF14233B,
    surfaceDim: 0xFFD6DEE8,
    surfaceBright: 0xFFFFFFFF,
    surfaceContainerLowest: 0xFFFFFFFF,
    surfaceContainerLow: 0xFFEEF3F9,
    surfaceContainer: 0xFFE3ECF7,
    surfaceContainerHigh: 0xFFD6E2F0,
    surfaceContainerHighest: 0xFFC6D5E6,
    onSurfaceVariant: 0xFF4F5D6E,
    outline: 0xFF7A8899,
    outlineVariant: 0xFFC6D5E6,
    inverseSurface: 0xFF14233B,
    onInverseSurface: 0xFFE3ECF7,
    inversePrimary: 0xFF9DBDE8,
    shadow: 0xFF000000,
    scrim: 0xFF000000,
  );

  static const dark = ColorTokens(
    primary: 0xFF9DBDE8,
    onPrimary: 0xFF14233B,
    primaryContainer: 0xFF2E6BB8,
    onPrimaryContainer: 0xFFE3ECF7,
    secondary: 0xFFC6D5E6,
    onSecondary: 0xFF26313F,
    secondaryContainer: 0xFF3A4D66,
    onSecondaryContainer: 0xFFE3ECF7,
    tertiary: 0xFFF0B27A,
    onTertiary: 0xFF4A2A08,
    tertiaryContainer: 0xFF6B3F12,
    onTertiaryContainer: 0xFFFFE2C4,
    error: 0xFFF2B8B5,
    onError: 0xFF601410,
    errorContainer: 0xFF8C1D18,
    onErrorContainer: 0xFFF9DEDC,
    surface: 0xFF14233B,
    onSurface: 0xFFE3ECF7,
    surfaceDim: 0xFF0F1B2E,
    surfaceBright: 0xFF3A4D66,
    surfaceContainerLowest: 0xFF0F1B2E,
    surfaceContainerLow: 0xFF1B2C47,
    surfaceContainer: 0xFF223556,
    surfaceContainerHigh: 0xFF2A3F63,
    surfaceContainerHighest: 0xFF33496F,
    onSurfaceVariant: 0xFFC6D5E6,
    outline: 0xFF9AA8B8,
    outlineVariant: 0xFF3A4D66,
    inverseSurface: 0xFFE3ECF7,
    onInverseSurface: 0xFF14233B,
    inversePrimary: 0xFF2E6BB8,
    shadow: 0xFF000000,
    scrim: 0xFF000000,
  );
}

final class StatusColorTokens {
  const StatusColorTokens({
    required this.pending,
    required this.onPending,
    required this.confirmed,
    required this.onConfirmed,
    required this.cancelled,
    required this.onCancelled,
    required this.arrived,
    required this.onArrived,
  });

  final int pending;
  final int onPending;
  final int confirmed;
  final int onConfirmed;
  final int cancelled;
  final int onCancelled;
  final int arrived;
  final int onArrived;

  static const light = StatusColorTokens(
    pending: 0xFFF6E3C4,
    onPending: 0xFF7D5313,
    confirmed: 0xFFD5E8DA,
    onConfirmed: 0xFF2E6B45,
    cancelled: 0xFFECD6D6,
    onCancelled: 0xFF8A4A4A,
    arrived: 0xFFC6D6EA,
    onArrived: 0xFF245693,
  );

  static const dark = StatusColorTokens(
    pending: 0xFF4F3A10,
    onPending: 0xFFF0C27A,
    confirmed: 0xFF1F4A30,
    onConfirmed: 0xFF8FD1A5,
    cancelled: 0xFF4E2626,
    onCancelled: 0xFFE3A3A3,
    arrived: 0xFF24436B,
    onArrived: 0xFFA9CBF0,
  );
}
