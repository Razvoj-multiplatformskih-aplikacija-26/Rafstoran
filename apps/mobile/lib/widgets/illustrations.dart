import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlateIllustration extends StatelessWidget {
  const PlateIllustration({super.key, this.size = 140, this.cracked = false});

  final double size;
  final bool cracked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _PlatePainter(scheme, cracked: cracked),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  _PlatePainter(this.scheme, {required this.cracked});

  final ColorScheme scheme;
  final bool cracked;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final plateRadius = radius * 0.62;

    canvas.drawCircle(
      center.translate(0, radius * 0.05),
      plateRadius * 1.02,
      Paint()..color = scheme.shadow.withValues(alpha: 0.08),
    );
    canvas.drawCircle(center, plateRadius, Paint()..color = scheme.surfaceContainerLowest);
    final rim = Paint()
      ..color = scheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.025;
    canvas.drawCircle(center, plateRadius, rim);
    canvas.drawCircle(center, plateRadius * 0.68, rim..color = scheme.outlineVariant);

    final cutlery = Paint()
      ..color = scheme.onSurfaceVariant
      ..strokeWidth = radius * 0.035
      ..strokeCap = StrokeCap.round;
    final forkX = center.dx - plateRadius * 1.3;
    canvas.drawLine(
      Offset(forkX, center.dy - plateRadius * 0.9),
      Offset(forkX, center.dy + plateRadius * 0.9),
      cutlery,
    );
    for (var i = -1; i <= 1; i++) {
      final x = forkX + i * radius * 0.07;
      canvas.drawLine(Offset(x, center.dy - plateRadius * 0.9), Offset(x, center.dy - plateRadius * 0.45), cutlery);
    }
    final knifeX = center.dx + plateRadius * 1.3;
    canvas.drawLine(
      Offset(knifeX, center.dy - plateRadius * 0.9),
      Offset(knifeX, center.dy + plateRadius * 0.9),
      cutlery,
    );
    final blade = Path()
      ..moveTo(knifeX - radius * 0.03, center.dy - plateRadius * 0.9)
      ..quadraticBezierTo(
        knifeX + radius * 0.12,
        center.dy - plateRadius * 0.5,
        knifeX + radius * 0.03,
        center.dy - plateRadius * 0.05,
      )
      ..close();
    canvas.drawPath(blade, Paint()..color = scheme.onSurfaceVariant);

    if (cracked) {
      final crack = Paint()
        ..color = scheme.error
        ..strokeWidth = radius * 0.03
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(center.dx - plateRadius * 0.2, center.dy - plateRadius);
      var point = Offset(center.dx - plateRadius * 0.2, center.dy - plateRadius);
      for (final step in [(0.25, 0.35), (-0.15, 0.3), (0.2, 0.3), (-0.05, 0.35)]) {
        point = point.translate(plateRadius * step.$1, plateRadius * step.$2);
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, crack);
      final branch = Path()
        ..moveTo(center.dx + plateRadius * 0.05, center.dy - plateRadius * 0.35)
        ..lineTo(center.dx + plateRadius * 0.45, center.dy - plateRadius * 0.55);
      canvas.drawPath(branch, crack);
    } else {
      final napkin = Paint()..color = scheme.primaryContainer;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-math.pi / 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: plateRadius * 0.9, height: plateRadius * 0.55),
          Radius.circular(radius * 0.05),
        ),
        napkin,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PlatePainter oldDelegate) => oldDelegate.scheme != scheme || oldDelegate.cracked != cracked;
}
