import 'package:flutter/material.dart';

import '../shortcuts.dart';

Future<void> showShortcutsOverview(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Prečice'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final shortcut in shortcutDescriptions())
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: MergeSemantics(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(shortcut.keys, style: theme.textTheme.labelLarge, textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(shortcut.description, style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Zatvori'))],
      );
    },
  );
}
