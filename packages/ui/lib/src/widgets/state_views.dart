import 'package:flutter/material.dart';

import 'illustrations.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Učitavanje',
      liveRegion: true,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween(begin: 0.45, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
          child: widget.child,
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.width, required this.height, this.radius = 8});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SlotSkeleton extends StatelessWidget {
  const SlotSkeleton({super.key, this.cards = 6});

  final int cards;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 480 ? 3 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < cards; i++)
                SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SkeletonBox(width: 64, height: 24),
                          SizedBox(height: 10),
                          SkeletonBox(width: 110, height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ReservationListSkeleton extends StatelessWidget {
  const ReservationListSkeleton({super.key, this.cards = 3});

  final int cards;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        children: [
          for (var i = 0; i < cards; i++) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [SkeletonBox(width: 90, height: 28), SkeletonBox(width: 80, height: 24, radius: 999)],
                    ),
                    SizedBox(height: 10),
                    SkeletonBox(width: 180, height: 14),
                    SizedBox(height: 14),
                    SkeletonBox(width: 120, height: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PlateIllustration(),
          const SizedBox(height: 20),
          Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class FailureView extends StatelessWidget {
  const FailureView({super.key, required this.onRetry, this.title = 'Podaci trenutno nisu dostupni.'});

  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PlateIllustration(cracked: true),
          const SizedBox(height: 20),
          Semantics(
            liveRegion: true,
            child: Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Pokušaj ponovo'),
          ),
        ],
      ),
    );
  }
}
