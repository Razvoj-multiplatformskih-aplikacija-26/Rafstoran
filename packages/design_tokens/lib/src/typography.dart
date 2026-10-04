abstract final class FontFamilies {
  static const headline = 'Fraunces';
  static const body = 'Inter';
}

final class TypeStyleTokens {
  const TypeStyleTokens({
    required this.family,
    required this.size,
    required this.weight,
    required this.height,
    this.letterSpacing = 0,
  });

  final String family;
  final double size;
  final int weight;
  final double height;
  final double letterSpacing;
}

abstract final class TypeScale {
  static const displayLarge = TypeStyleTokens(
    family: FontFamilies.headline,
    size: 52,
    weight: 600,
    height: 1.1,
    letterSpacing: -1,
  );
  static const displayMedium = TypeStyleTokens(
    family: FontFamilies.headline,
    size: 42,
    weight: 600,
    height: 1.1,
    letterSpacing: -0.5,
  );
  static const displaySmall = TypeStyleTokens(family: FontFamilies.headline, size: 34, weight: 600, height: 1.1);
  static const headlineLarge = TypeStyleTokens(family: FontFamilies.headline, size: 30, weight: 600, height: 1.1);
  static const headlineMedium = TypeStyleTokens(family: FontFamilies.headline, size: 26, weight: 600, height: 1.1);
  static const headlineSmall = TypeStyleTokens(family: FontFamilies.headline, size: 22, weight: 600, height: 1.1);
  static const titleLarge = TypeStyleTokens(family: FontFamilies.body, size: 20, weight: 600, height: 1.2);
  static const titleMedium = TypeStyleTokens(family: FontFamilies.body, size: 16, weight: 600, height: 1.2);
  static const titleSmall = TypeStyleTokens(family: FontFamilies.body, size: 14, weight: 600, height: 1.2);
  static const bodyLarge = TypeStyleTokens(family: FontFamilies.body, size: 16, weight: 400, height: 1.4);
  static const bodyMedium = TypeStyleTokens(family: FontFamilies.body, size: 14, weight: 400, height: 1.4);
  static const bodySmall = TypeStyleTokens(family: FontFamilies.body, size: 12, weight: 400, height: 1.4);
  static const labelLarge = TypeStyleTokens(
    family: FontFamilies.body,
    size: 14,
    weight: 600,
    height: 1.2,
    letterSpacing: 0.1,
  );
  static const labelMedium = TypeStyleTokens(
    family: FontFamilies.body,
    size: 12,
    weight: 600,
    height: 1.2,
    letterSpacing: 0.3,
  );
  static const labelSmall = TypeStyleTokens(
    family: FontFamilies.body,
    size: 11,
    weight: 600,
    height: 1.2,
    letterSpacing: 0.4,
  );
}
