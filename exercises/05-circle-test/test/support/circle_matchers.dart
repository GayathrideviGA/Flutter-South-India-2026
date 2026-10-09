// The reusable part of this exercise. Copy this file into any watch project.
//
// RULE IT ENFORCES
//   All four corners of every piece of text must be inside the watch circle.
//
//   If a corner is further from the centre than the radius, the bezel hides
//   it, and the test fails with the exact rectangle that is clipped.

import 'dart:ui';

import 'package:flutter/rendering.dart'; // RenderBox
import 'package:flutter/widgets.dart'; // RichText
import 'package:flutter_test/flutter_test.dart';

/// A real watch is not exactly on the circle edge. Allow half a pixel of
/// rounding noise so a perfectly placed corner does not fail the test.
const double kTolerance = 0.5;

/// Resize the test screen to a square watch of [size] logical pixels.
/// Call this BEFORE pumpWidget. It restores itself when the test ends.
void useWatchScreen(WidgetTester tester, {double size = 454}) {
  tester.view
    ..physicalSize = Size(size, size)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Fails if any text on screen pokes outside the watch circle.
void expectInsideCircle(WidgetTester tester) {
  // Screen size in logical pixels.
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final center = size.center(Offset.zero);
  final radius = size.shortestSide / 2;

  // Every Text widget draws through a RichText, whose render object is a box.
  final paragraphs = tester.renderObjectList<RenderBox>(find.byType(RichText));

  for (final box in paragraphs) {
    // Where is this text on screen?
    final rect = box.localToGlobal(Offset.zero) & box.size;

    for (final corner in [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight]) {
      expect(
        (corner - center).distance,
        lessThanOrEqualTo(radius + kTolerance),
        reason: 'text clipped by the bezel at $rect',
      );
    }
  }
}
