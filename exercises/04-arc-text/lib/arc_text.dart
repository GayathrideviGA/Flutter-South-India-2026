// Exercise 04 - ArcText
//
// GOAL
//   Draw a label that bends around the circle, like "FOCUS SESSION" along the
//   top of a watch face. Flutter has no curved text widget, so we place each
//   letter ourselves.
//
// THE WHOLE IDEA (three lines)
//   1. Measure every letter:                 width w
//   2. Turn width into an angle:             angle = w / radius
//   3. Rotate the canvas by that angle, draw the letter, repeat.
//
// WHY  angle = w / radius ?
//   Arc length = radius * angle (in radians). We know the arc length we want
//   a letter to cover (its width), so angle = width / radius.
//
// ANGLES USED HERE
//   0 rad          = 12 o'clock (straight up)
//   positive       = clockwise
//   pi / 2 rad     = 3 o'clock
//
//                 12 (0 rad)
//            F O C U S . S E S S
//         .'                       '.
//        /                           \
//   9 (-pi/2)         .             3 (+pi/2)
//        \                           /
//         '.                       .'
//                 6 (pi)

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Lays out one [TextPainter] per character.
List<TextPainter> _glyphs(String text, TextStyle style) {
  return [
    for (final character in text.split(''))
      TextPainter(
        text: TextSpan(text: character, style: style),
        textDirection: TextDirection.ltr,
      )..layout(),
  ];
}

/// How much of the circle the whole text covers, in radians.
///
/// Pure maths, so it is easy to test and handy for centring or for checking
/// that a label does not wrap all the way round.
double arcSpan(String text, TextStyle style, double radius) {
  final glyphs = _glyphs(text, style);
  final totalWidth = glyphs.fold<double>(0, (sum, g) => sum + g.width);
  for (final g in glyphs) {
    g.dispose();
  }
  return totalWidth / radius;
}

/// Paints [text] on a circle of [radius] around [center].
///
/// [mid] is the angle (radians, 0 = 12 o'clock) of the MIDDLE of the text.
/// Leave it at 0 for a label centred on top.
void paintArcText(
  Canvas canvas,
  Offset center,
  double radius,
  String text,
  TextStyle style, {
  double mid = 0,
}) {
  final glyphs = _glyphs(text, style);
  final totalWidth = glyphs.fold<double>(0, (sum, g) => sum + g.width);

  // Start half the text's span before `mid`, so the text is centred on it.
  var angle = mid - totalWidth / radius / 2;

  for (final glyph in glyphs) {
    final step = glyph.width / radius; // this letter's angle

    canvas
      ..save()
      // Move the origin to the middle of the watch...
      ..translate(center.dx, center.dy)
      // ...turn to the middle of this letter (start + half its own step)...
      ..rotate(angle + step / 2)
      // ...then slide up so the letter stands on the circle: half its width to
      // the left (to centre it) and its full height above radius `r`.
      ..translate(-glyph.width / 2, -radius - glyph.height);

    glyph.paint(canvas, Offset.zero);
    canvas.restore();

    angle += step; // next letter starts where this one ended
  }

  for (final g in glyphs) {
    g.dispose();
  }
}

class _ArcTextPainter extends CustomPainter {
  const _ArcTextPainter(this.text, this.radius, this.style, this.mid);

  final String text;
  final double radius;
  final TextStyle style;
  final double mid;

  @override
  void paint(Canvas canvas, Size size) {
    paintArcText(canvas, size.center(Offset.zero), radius, text, style, mid: mid);
  }

  @override
  bool shouldRepaint(_ArcTextPainter old) =>
      old.text != text || old.radius != radius || old.style != style || old.mid != mid;
}

/// Curved text, centred on the widget. Size it to the watch, e.g. with
/// `SizedBox.expand()` inside a `Stack`.
///
/// ```dart
/// ArcText('FOCUS SESSION', radius: 150, style: TextStyle(fontSize: 14))
/// ```
class ArcText extends StatelessWidget {
  const ArcText(
    this.text, {
    super.key,
    required this.radius,
    required this.style,
    this.midAngle = 0,
  });

  final String text;

  /// Distance from the watch centre to the BASELINE of the text.
  final double radius;
  final TextStyle style;

  /// Angle of the middle of the text, in radians (0 = top, positive = clockwise).
  final double midAngle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ArcTextPainter(text, radius, style, midAngle),
    );
  }
}

/// Handy for sliders and docs: degrees from radians.
double radiansToDegrees(double radians) => radians * 180 / math.pi;
