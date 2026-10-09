// Demo for exercise 03: the same message in a plain wrapping Text and in
// ChordText, side by side on two round "watches".
//
// Run:  flutter create --platforms=android .   (once)
//       flutter run

import 'package:flutter/material.dart';

import 'chord_text.dart';

void main() => runApp(const ChordTextDemo());

const _message = 'Standup moved to 3:40 PM in the Orion room. Priya is bringing the demo.';

class ChordTextDemo extends StatelessWidget {
  const ChordTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              Expanded(child: _Watch(label: 'Plain Text', child: Center(child: _plain(style)))),
              Expanded(child: _Watch(label: 'ChordText', child: const ChordText(_message, style: style))),
            ],
          ),
        ),
      ),
    );
  }

  // A normal Text that wraps inside the safe square (what you get without this exercise).
  Widget _plain(TextStyle style) => Padding(
        padding: const EdgeInsets.all(66),
        child: Text(_message, style: style.copyWith(fontSize: 22), textAlign: TextAlign.center),
      );
}

class _Watch extends StatelessWidget {
  const _Watch({required this.label, required this.child});
  final String label;
  final Widget child;

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
              child: ClipOval(child: child),
            ),
          ),
        ),
        Text(label),
      ],
    );
  }
}
