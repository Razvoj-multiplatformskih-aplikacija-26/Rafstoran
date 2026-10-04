import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../text/serbian.dart';

class PartySizeStepper extends StatelessWidget {
  const PartySizeStepper({super.key, required this.value, required this.onChanged});

  final PartySize value;
  final ValueChanged<PartySize> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final smaller = PartySize.parse(value.value - 1).valueOrNull;
    final larger = PartySize.parse(value.value + 1).valueOrNull;
    return Semantics(
      label: 'Broj osoba',
      value: peopleLabel(value.value),
      increasedValue: larger == null ? null : peopleLabel(larger.value),
      decreasedValue: smaller == null ? null : peopleLabel(smaller.value),
      onIncrease: larger == null ? null : () => onChanged(larger),
      onDecrease: smaller == null ? null : () => onChanged(smaller),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            tooltip: 'Manje osoba',
            onPressed: smaller == null ? null : () => onChanged(smaller),
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 64,
            child: ExcludeSemantics(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${value.value}',
                  key: ValueKey(value),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Više osoba',
            onPressed: larger == null ? null : () => onChanged(larger),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
