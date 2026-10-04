import 'dart:math' as math;

import 'package:flutter/material.dart';

class TableIllustration extends StatelessWidget {
  const TableIllustration({super.key, this.size = 160});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _TablePainter(scheme)),
    );
  }
}

class _TablePainter extends CustomPainter {
  _TablePainter(this.scheme);

  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final tableRadius = radius * 0.46;
    final plateRadius = radius * 0.17;
    final plateDistance = radius * 0.76;

    final shadow = Paint()..color = scheme.shadow.withValues(alpha: 0.08);
    canvas.drawCircle(center.translate(0, radius * 0.04), tableRadius * 1.04, shadow);

    final tableFill = Paint()..color = scheme.primaryContainer;
    final tableEdge = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035;
    canvas.drawCircle(center, tableRadius, tableFill);
    canvas.drawCircle(center, tableRadius, tableEdge);

    final napkin = Paint()..color = scheme.secondaryContainer;
    final napkinRect = Rect.fromCenter(center: center, width: tableRadius * 0.9, height: tableRadius * 0.9);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(napkinRect, Radius.circular(tableRadius * 0.12)), napkin);
    canvas.restore();

    final candle = Paint()..color = scheme.tertiary;
    canvas.drawCircle(center, tableRadius * 0.14, candle);

    final plateFill = Paint()..color = scheme.surfaceContainerLowest;
    final plateEdge = Paint()
      ..color = scheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02;
    final cutlery = Paint()
      ..color = scheme.onSurfaceVariant
      ..strokeWidth = radius * 0.025
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2;
      final plateCenter = center + Offset(math.cos(angle), math.sin(angle)) * plateDistance;
      canvas.drawCircle(plateCenter, plateRadius, plateFill);
      canvas.drawCircle(plateCenter, plateRadius, plateEdge);
      canvas.drawCircle(plateCenter, plateRadius * 0.62, plateEdge);

      final tangent = Offset(-math.sin(angle), math.cos(angle));
      final normal = Offset(math.cos(angle), math.sin(angle));
      final left = plateCenter - tangent * (plateRadius * 1.45);
      final right = plateCenter + tangent * (plateRadius * 1.45);
      final half = normal * (plateRadius * 0.9);
      canvas.drawLine(left - half, left + half, cutlery);
      canvas.drawLine(right - half, right + half, cutlery);
    }
  }

  @override
  bool shouldRepaint(_TablePainter oldDelegate) => oldDelegate.scheme != scheme;
}
