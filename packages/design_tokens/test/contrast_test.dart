import 'dart:math' as math;

import 'package:design_tokens/design_tokens.dart';
import 'package:test/test.dart';

double _channel(int value) {
  final c = value / 255;
  return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(int argb) =>
    0.2126 * _channel((argb >> 16) & 0xFF) + 0.7152 * _channel((argb >> 8) & 0xFF) + 0.0722 * _channel(argb & 0xFF);

double contrast(int a, int b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('every text and status colour pair meets WCAG AA in both schemes', () {
    for (final (scheme, c, s) in [
      ('light', ColorTokens.light, StatusColorTokens.light),
      ('dark', ColorTokens.dark, StatusColorTokens.dark),
    ]) {
      final textPairs = <String, (int, int)>{
        'onSurface on surface': (c.onSurface, c.surface),
        'onSurfaceVariant on surface': (c.onSurfaceVariant, c.surface),
        'onSurface on surfaceContainer': (c.onSurface, c.surfaceContainer),
        'onSurfaceVariant on surfaceContainerHighest': (c.onSurfaceVariant, c.surfaceContainerHighest),
        'primary on surface': (c.primary, c.surface),
        'onPrimary on primary': (c.onPrimary, c.primary),
        'onPrimaryContainer on primaryContainer': (c.onPrimaryContainer, c.primaryContainer),
        'onSecondaryContainer on secondaryContainer': (c.onSecondaryContainer, c.secondaryContainer),
        'onTertiaryContainer on tertiaryContainer': (c.onTertiaryContainer, c.tertiaryContainer),
        'error on surface': (c.error, c.surface),
        'onError on error': (c.onError, c.error),
        'pending': (s.onPending, s.pending),
        'confirmed': (s.onConfirmed, s.confirmed),
        'cancelled': (s.onCancelled, s.cancelled),
        'arrived': (s.onArrived, s.arrived),
      };
      for (final MapEntry(key: name, value: (foreground, background)) in textPairs.entries) {
        expect(contrast(foreground, background), greaterThanOrEqualTo(4.5), reason: '$scheme: $name');
      }
      expect(contrast(c.outline, c.surface), greaterThanOrEqualTo(3), reason: '$scheme: outline on surface');
    }
  });
}
