// Demo for exercise 05: both faces on a round "watch", side by side.
// The left one is the bug. The tests in test/ prove we can detect it.
//
// Run:  flutter create --platforms=android .   (once)
//       flutter run
// Test: flutter test

import 'package:flutter/material.dart';

import 'watch_faces.dart';

void main() => runApp(const CircleTestDemo());

class CircleTestDemo extends StatelessWidget {
  const CircleTestDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              Expanded(child: _Watch(label: 'ClippedFace (bug)', face: ClippedFace())),
              Expanded(child: _Watch(label: 'SafeFace', face: SafeFace())),
            ],
          ),
        ),
      ),
    );
  }
}

class _Watch extends StatelessWidget {
  const _Watch({required this.label, required this.face});
  final String label;
  final Widget face;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DecoratedBox(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              // Scale the 454 px face down so it fits on a phone.
              child: ClipOval(
                child: FittedBox(
                  child: SizedBox(width: 454, height: 454, child: face),
                ),
              ),
            ),
          ),
        ),
        Text(label),
      ],
    );
  }
}
