import 'package:flutter/material.dart';

import '../text/serbian.dart';

class PartySizeStepper extends StatelessWidget {
  const PartySizeStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.max = 12});

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Broj osoba',
      value: peopleLabel(value),
      increasedValue: value < max ? peopleLabel(value + 1) : null,
      decreasedValue: value > min ? peopleLabel(value - 1) : null,
      onIncrease: value < max ? () => onChanged(value + 1) : null,
      onDecrease: value > min ? () => onChanged(value - 1) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            tooltip: 'Manje osoba',
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 64,
            child: ExcludeSemantics(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  '$value',
                  key: ValueKey(value),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Više osoba',
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
