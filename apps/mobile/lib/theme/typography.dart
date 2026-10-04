import 'package:flutter/material.dart';

abstract final class RafTypography {
  static const headlineFamily = 'Fraunces';
  static const bodyFamily = 'Inter';

  static TextTheme textTheme(ColorScheme scheme) {
    const headline = TextStyle(fontFamily: headlineFamily, fontWeight: FontWeight.w600, height: 1.1);
    const body = TextStyle(fontFamily: bodyFamily, fontWeight: FontWeight.w400, height: 1.4);
    const label = TextStyle(fontFamily: bodyFamily, fontWeight: FontWeight.w600, height: 1.2);
    return TextTheme(
      displayLarge: headline.copyWith(fontSize: 52, letterSpacing: -1),
      displayMedium: headline.copyWith(fontSize: 42, letterSpacing: -0.5),
      displaySmall: headline.copyWith(fontSize: 34),
      headlineLarge: headline.copyWith(fontSize: 30),
      headlineMedium: headline.copyWith(fontSize: 26),
      headlineSmall: headline.copyWith(fontSize: 22),
      titleLarge: label.copyWith(fontSize: 20),
      titleMedium: label.copyWith(fontSize: 16),
      titleSmall: label.copyWith(fontSize: 14),
      bodyLarge: body.copyWith(fontSize: 16),
      bodyMedium: body.copyWith(fontSize: 14),
      bodySmall: body.copyWith(fontSize: 12),
      labelLarge: label.copyWith(fontSize: 14, letterSpacing: 0.1),
      labelMedium: label.copyWith(fontSize: 12, letterSpacing: 0.3),
      labelSmall: label.copyWith(fontSize: 11, letterSpacing: 0.4),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}
