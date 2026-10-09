// Exercise 01 - RoundSafe
//
// THE PROBLEM
//   Flutter lays out rectangles. A round watch shows a circle.
//   Anything near a corner of the screen rectangle is cut off by the bezel.
//
// THE FIX
//   Find the biggest square that fits inside the circle, then keep the UI
//   inside it. That square is our "safe area".
//
// THE MATHS (the only formula in this file)
//
//        diameter d
//     <------------->
//       .---------.        The diagonal of the safe square is the diameter:
//     /  +-------+  \          side * sqrt(2) = d
//    |   | safe  |   |         side           = d / sqrt(2)  (about 70.7% of d)
//    |   | square|   |
//     \  +-------+  /       So each side of the screen loses:
//       '---------'            (d - side) / 2 = d * (1 - 1/sqrt(2)) / 2
//                                             = about 14.6% of d

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The two screen shapes we care about.
///
/// The `wear` plugin has an equivalent enum. We keep our own here so this
/// exercise needs nothing but the Flutter SDK.
enum WearShape { round, square }

/// Margin used on square watches. Their corners are usable, so we only
/// keep a small breathing space.
const double kSquareMargin = 8.0;

/// How many logical pixels to leave free on EACH side of the screen.
///
/// This is a pure function on purpose: no widgets, no context, so it is
/// trivial to unit test (see test/round_safe_test.dart).
double roundSafeInset(double diameter, WearShape shape) {
  switch (shape) {
    case WearShape.round:
      return diameter * (1 - 1 / math.sqrt2) / 2;
    case WearShape.square:
      return kSquareMargin;
  }
}

/// Wraps [child] so it stays inside the part of the screen a round bezel
/// cannot clip.
///
/// Put it once near the top of every watch screen:
///
/// ```dart
/// Scaffold(body: RoundSafe(child: MyWatchFace()))
/// ```
class RoundSafe extends StatelessWidget {
  const RoundSafe({
    super.key,
    required this.child,
    this.shape = WearShape.round,
  });

  final Widget child;

  /// Normally you read this from the device (the `wear` plugin's
  /// `WatchShape` widget does that). It is a parameter here so tests and the
  /// demo can force either shape.
  final WearShape shape;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gives us the size we were offered, not the size of the
    // whole screen. That keeps RoundSafe correct when it is nested.
    return LayoutBuilder(
      builder: (context, constraints) {
        // On a watch the screen is a square box, so shortestSide is the
        // diameter. (Constraints must be bounded: do not put this inside an
        // unbounded scroll view.)
        final diameter = constraints.biggest.shortestSide;
        return Padding(
          padding: EdgeInsets.all(roundSafeInset(diameter, shape)),
          child: child,
        );
      },
    );
  }
}
