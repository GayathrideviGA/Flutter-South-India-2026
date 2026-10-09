// Demo for exercise 04: drag the sliders and watch the letters re-flow.
//
// Run:  flutter create --platforms=android .   (once)
//       flutter run

import 'package:flutter/material.dart';

import 'arc_text.dart';

void main() => runApp(const ArcTextDemo());

class ArcTextDemo extends StatefulWidget {
  const ArcTextDemo({super.key});

  @override
  State<ArcTextDemo> createState() => _ArcTextDemoState();
}

class _ArcTextDemoState extends State<ArcTextDemo> {
  static const _label = 'FOCUS SESSION';
  static const _style = TextStyle(
    color: Color(0xFFFFC857),
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  double _radius = 150;
  double _mid = 0; // radians

  @override
  Widget build(BuildContext context) {
    final span = radiansToDegrees(arcSpan(_label, _style, _radius));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                      child: Stack(
                        children: [
                          // NOTE: this demo box is about 300 px wide, so a radius
                          // above ~150 pushes the text outside the circle.
                          ArcText(_label, radius: _radius, style: _style, midAngle: _mid),
                          const Center(
                            child: Text('16', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Text('Span ${span.toStringAsFixed(0)}° at radius ${_radius.toStringAsFixed(0)} px'),
              Slider(min: 60, max: 150, value: _radius, onChanged: (v) => setState(() => _radius = v)),
              Slider(min: -3.14, max: 3.14, value: _mid, onChanged: (v) => setState(() => _mid = v)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
