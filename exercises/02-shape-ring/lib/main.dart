// Demo for exercise 02: drag the slider, flip the shape.
//
// Run:  flutter create --platforms=android .   (once)
//       flutter run

import 'package:flutter/material.dart';

import 'shape_ring.dart';

void main() => runApp(const ShapeRingDemo());

class ShapeRingDemo extends StatefulWidget {
  const ShapeRingDemo({super.key});

  @override
  State<ShapeRingDemo> createState() => _ShapeRingDemoState();
}

class _ShapeRingDemoState extends State<ShapeRingDemo> {
  double _progress = 0.64;
  WearShape _shape = WearShape.round;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ShapeRing(
                        progress: _progress,
                        shape: _shape,
                        child: Center(
                          child: Text(
                            '${(_progress * 100).round()}%',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Slider(
                  value: _progress,
                  onChanged: (v) => setState(() => _progress = v),
                ),
                SegmentedButton<WearShape>(
                  segments: const [
                    ButtonSegment(value: WearShape.round, label: Text('Round')),
                    ButtonSegment(value: WearShape.square, label: Text('Square')),
                  ],
                  selected: {_shape},
                  onSelectionChanged: (s) => setState(() => _shape = s.first),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
