// Exercise 05 - two faces to test
//
// ClippedFace : text pushed into the corners. On a round watch the bezel
//               hides part of it. This is the BUG our test must catch.
// SafeFace    : the same content kept inside the safe square (exercise 01).
//
// Why not just wrap the app in ClipOval? Because ClipOval hides the problem
// instead of reporting it: the text would silently lose its corners.

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Text hugging the top-left and bottom-right corners. Looks fine on a
/// phone, broken on a round watch.
class ClippedFace extends StatelessWidget {
  const ClippedFace({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Standup moved', style: TextStyle(fontSize: 20)),
          Align(
            alignment: Alignment.centerRight,
            child: Text('3:40 PM', style: TextStyle(fontSize: 40)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text('Reply', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

/// Same message, centred inside the biggest square that fits the circle.
class SafeFace extends StatelessWidget {
  const SafeFace({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = constraints.biggest.shortestSide;
        // Same maths as exercise 01: 14.6% of the diameter on every side.
        final inset = diameter * (1 - 1 / math.sqrt2) / 2;

        return Padding(
          padding: EdgeInsets.all(inset),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Standup moved', style: TextStyle(fontSize: 20)),
              Text('3:40 PM', style: TextStyle(fontSize: 40)),
              Text('Reply', style: TextStyle(fontSize: 20)),
            ],
          ),
        );
      },
    );
  }
}
