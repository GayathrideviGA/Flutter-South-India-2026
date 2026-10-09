// Exercise 02 - ShapeRing
//
// GOAL
//   One progress ring that works on a round watch AND a square watch.
//   The widget never asks "which shape am I?" while painting. Instead we
//   build an OUTLINE (a Path) per shape and trace it with one routine.
//
// THREE IDEAS
//   1. Outline  : a Path that describes the shape of the ring.
//   2. Metrics  : Path.computeMetrics() lets us measure that path and cut a
//                 piece out of it, whatever its shape.
//   3. Start    : progress must begin at 12 o'clock. Rather than rotating the
//                 canvas afterwards, we build each outline starting at 12.
//
//        12 o'clock = (centre x, top)
//
//          round                     square
//        .---*---.                 .---*---.
//       /         \               (         )     * = where every outline
//      |           |              |         |         begins, and where
//       \         /               (         )         progress starts
//        '-------'                 '-------'

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';

enum WearShape { round, square }

/// Builds the closed outline of [shape] inside [rect].
///
/// The path always starts at the top centre and runs clockwise.
Path ringOutline(Rect rect, WearShape shape, {double cornerRadius = 48}) {
  switch (shape) {
    case WearShape.round:
      // Two half circles. An ellipse added with addOval() starts at 3 o'clock,
      // so we draw it ourselves from 12 o'clock (-pi/2).
      return Path()
        ..arcTo(rect, -math.pi / 2, math.pi, true) // 12 -> 6, right side
        ..arcTo(rect, math.pi / 2, math.pi, false) // 6 -> 12, left side
        ..close();

    case WearShape.square:
      // A rounded rectangle, walked corner by corner, clockwise.
      // Each corner is a quarter circle (sweep of pi/2) inside a 2r x 2r box.
      final r = math.min(cornerRadius, math.min(rect.width, rect.height) / 2);
      final d = r * 2;
      return Path()
        ..moveTo(rect.center.dx, rect.top) // start: 12 o'clock
        ..lineTo(rect.right - r, rect.top)
        ..arcTo(Rect.fromLTWH(rect.right - d, rect.top, d, d), -math.pi / 2, math.pi / 2, false) // top-right
        ..lineTo(rect.right, rect.bottom - r)
        ..arcTo(Rect.fromLTWH(rect.right - d, rect.bottom - d, d, d), 0, math.pi / 2, false) // bottom-right
        ..lineTo(rect.left + r, rect.bottom)
        ..arcTo(Rect.fromLTWH(rect.left, rect.bottom - d, d, d), math.pi / 2, math.pi / 2, false) // bottom-left
        ..lineTo(rect.left, rect.top + r)
        ..arcTo(Rect.fromLTWH(rect.left, rect.top, d, d), math.pi, math.pi / 2, false) // top-left
        ..close();
  }
}

/// Returns the first [progress] (0.0 to 1.0) of [outline], measured along its
/// length. This is the whole trick: it does not care what shape the path is.
Path progressPath(Path outline, double progress) {
  final p = progress.clamp(0.0, 1.0).toDouble();
  final result = Path();
  for (final metric in outline.computeMetrics()) {
    result.addPath(metric.extractPath(0, metric.length * p), Offset.zero);
  }
  return result;
}

class ShapeRingPainter extends CustomPainter {
  const ShapeRingPainter({
    required this.progress,
    required this.shape,
    required this.color,
    this.strokeWidth = 12,
  });

  final double progress;
  final WearShape shape;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // A stroke is centred on the path, so pull the path in by half the stroke
    // width or the outer half of the ring would be cut off at the edge.
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final outline = ringOutline(rect, shape);

    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 1) the faint full track, 2) the bright progress on top.
    canvas.drawPath(outline, pen..color = color.withValues(alpha: 0.15));
    canvas.drawPath(progressPath(outline, progress), pen..color = color);
  }

  @override
  bool shouldRepaint(ShapeRingPainter old) =>
      old.progress != progress ||
      old.shape != shape ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

/// Drop-in widget. Give it a size (or wrap it in AspectRatio).
class ShapeRing extends StatelessWidget {
  const ShapeRing({
    super.key,
    required this.progress,
    required this.shape,
    this.color = const Color(0xFF5CC8FF),
    this.strokeWidth = 12,
    this.child,
  });

  final double progress;
  final WearShape shape;
  final Color color;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShapeRingPainter(
        progress: progress,
        shape: shape,
        color: color,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}
