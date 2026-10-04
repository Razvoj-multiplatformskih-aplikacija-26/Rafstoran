import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';

import 'status_colors.dart';

abstract final class RafTheme {
  static ThemeData light() => _build(_scheme(ColorTokens.light, Brightness.light), ReservationStatusColors.light);

  static ThemeData dark() => _build(_scheme(ColorTokens.dark, Brightness.dark), ReservationStatusColors.dark);

  static ThemeData _build(ColorScheme scheme, ReservationStatusColors statusColors) {
    final textTheme = RafTypography.textTheme(scheme);
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg));
    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.lg),
      borderSide: BorderSide(color: color, width: width),
    );
    return ThemeData(
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(64, 52), shape: rounded, textStyle: textTheme.labelLarge),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: rounded,
          side: BorderSide(color: scheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48), shape: rounded, textStyle: textTheme.labelLarge),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.lg),
        border: inputBorder(scheme.outlineVariant),
        enabledBorder: inputBorder(scheme.outlineVariant),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
        labelStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 10),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xxl)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      focusColor: scheme.primary.withValues(alpha: 0.12),
      extensions: [statusColors],
    );
  }

  static ColorScheme _scheme(ColorTokens t, Brightness brightness) => ColorScheme(
    brightness: brightness,
    primary: Color(t.primary),
    onPrimary: Color(t.onPrimary),
    primaryContainer: Color(t.primaryContainer),
    onPrimaryContainer: Color(t.onPrimaryContainer),
    secondary: Color(t.secondary),
    onSecondary: Color(t.onSecondary),
    secondaryContainer: Color(t.secondaryContainer),
    onSecondaryContainer: Color(t.onSecondaryContainer),
    tertiary: Color(t.tertiary),
    onTertiary: Color(t.onTertiary),
    tertiaryContainer: Color(t.tertiaryContainer),
    onTertiaryContainer: Color(t.onTertiaryContainer),
    error: Color(t.error),
    onError: Color(t.onError),
    errorContainer: Color(t.errorContainer),
    onErrorContainer: Color(t.onErrorContainer),
    surface: Color(t.surface),
    onSurface: Color(t.onSurface),
    surfaceDim: Color(t.surfaceDim),
    surfaceBright: Color(t.surfaceBright),
    surfaceContainerLowest: Color(t.surfaceContainerLowest),
    surfaceContainerLow: Color(t.surfaceContainerLow),
    surfaceContainer: Color(t.surfaceContainer),
    surfaceContainerHigh: Color(t.surfaceContainerHigh),
    surfaceContainerHighest: Color(t.surfaceContainerHighest),
    onSurfaceVariant: Color(t.onSurfaceVariant),
    outline: Color(t.outline),
    outlineVariant: Color(t.outlineVariant),
    inverseSurface: Color(t.inverseSurface),
    onInverseSurface: Color(t.onInverseSurface),
    inversePrimary: Color(t.inversePrimary),
    shadow: Color(t.shadow),
    scrim: Color(t.scrim),
  );
}

abstract final class RafTypography {
  static TextStyle style(TypeStyleTokens tokens) => TextStyle(
    fontFamily: tokens.family,
    package: 'ui',
    fontSize: tokens.size,
    fontWeight: FontWeight.values[tokens.weight ~/ 100 - 1],
    height: tokens.height,
    letterSpacing: tokens.letterSpacing,
  );

  static TextTheme textTheme(ColorScheme scheme) => TextTheme(
    displayLarge: style(TypeScale.displayLarge),
    displayMedium: style(TypeScale.displayMedium),
    displaySmall: style(TypeScale.displaySmall),
    headlineLarge: style(TypeScale.headlineLarge),
    headlineMedium: style(TypeScale.headlineMedium),
    headlineSmall: style(TypeScale.headlineSmall),
    titleLarge: style(TypeScale.titleLarge),
    titleMedium: style(TypeScale.titleMedium),
    titleSmall: style(TypeScale.titleSmall),
    bodyLarge: style(TypeScale.bodyLarge),
    bodyMedium: style(TypeScale.bodyMedium),
    bodySmall: style(TypeScale.bodySmall),
    labelLarge: style(TypeScale.labelLarge),
    labelMedium: style(TypeScale.labelMedium),
    labelSmall: style(TypeScale.labelSmall),
  ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}
