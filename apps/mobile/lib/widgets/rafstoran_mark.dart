import 'package:flutter/material.dart';

class RafstoranMark extends StatelessWidget {
  const RafstoranMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Rafstoran',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Image.asset(
          'assets/brand/raf_mark.png',
          color: scheme.primary,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class RafstoranWordmark extends StatelessWidget {
  const RafstoranWordmark({super.key, this.markSize = 36});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: RafstoranMark(size: markSize)),
        const SizedBox(width: 10),
        Semantics(header: true, child: Text('Rafstoran', style: textTheme.headlineSmall)),
      ],
    );
  }
}
