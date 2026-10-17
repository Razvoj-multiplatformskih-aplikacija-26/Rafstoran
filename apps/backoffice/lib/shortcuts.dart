import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool get usesCommandKey => defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;

String get commandKeyLabel => usesCommandKey ? '⌘' : 'Ctrl';

String get optionKeyLabel => usesCommandKey ? '⌥' : 'Alt';

class GuardedCallbackAction<T extends Intent> extends CallbackAction<T> {
  GuardedCallbackAction({required this.enabled, required super.onInvoke});

  final bool Function() enabled;

  @override
  bool isEnabled(T intent) => enabled();
}

class ConfirmSelectedIntent extends Intent {
  const ConfirmSelectedIntent();
}

class RecordArrivalIntent extends Intent {
  const RecordArrivalIntent();
}

class CancelSelectedIntent extends Intent {
  const CancelSelectedIntent();
}

class ClearSelectionIntent extends Intent {
  const ClearSelectionIntent();
}

class PreviousDayIntent extends Intent {
  const PreviousDayIntent();
}

class NextDayIntent extends Intent {
  const NextDayIntent();
}

class TodayIntent extends Intent {
  const TodayIntent();
}

class ShowShortcutsIntent extends Intent {
  const ShowShortcutsIntent();
}

class CommandPaletteIntent extends Intent {
  const CommandPaletteIntent();
}

Map<ShortcutActivator, Intent> scheduleShortcuts() => {
  const SingleActivator(LogicalKeyboardKey.keyC): const ConfirmSelectedIntent(),
  const SingleActivator(LogicalKeyboardKey.keyA): const RecordArrivalIntent(),
  const SingleActivator(LogicalKeyboardKey.keyX): const CancelSelectedIntent(),
  const SingleActivator(LogicalKeyboardKey.escape): const ClearSelectionIntent(),
  const SingleActivator(LogicalKeyboardKey.keyT): const TodayIntent(),
  const SingleActivator(LogicalKeyboardKey.keyP): const PreviousDayIntent(),
  const SingleActivator(LogicalKeyboardKey.keyN): const NextDayIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): const PreviousDayIntent(),
  const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): const NextDayIntent(),
  const CharacterActivator('?'): const ShowShortcutsIntent(),
  SingleActivator(LogicalKeyboardKey.keyK, meta: usesCommandKey, control: !usesCommandKey):
      const CommandPaletteIntent(),
};

final class ShortcutDescription {
  const ShortcutDescription(this.keys, this.description);

  final String keys;
  final String description;
}

List<ShortcutDescription> shortcutDescriptions() => [
  const ShortcutDescription('↑ ↓ ← →', 'Kretanje po rasporedu'),
  const ShortcutDescription('Enter', 'Otvori rezervaciju pod kursorom'),
  const ShortcutDescription('Esc', 'Zatvori detalj'),
  const ShortcutDescription('C', 'Potvrdi izabranu rezervaciju'),
  const ShortcutDescription('A', 'Zabeleži dolazak gosta'),
  const ShortcutDescription('X', 'Otkaži izabranu rezervaciju'),
  const ShortcutDescription('P  /  N', 'Prethodni / naredni dan'),
  ShortcutDescription('$optionKeyLabel ←  /  $optionKeyLabel →', 'Prethodni / naredni dan'),
  const ShortcutDescription('T', 'Današnji dan'),
  ShortcutDescription('$commandKeyLabel K', 'Paleta komandi'),
  const ShortcutDescription('?', 'Pregled prečica'),
];
