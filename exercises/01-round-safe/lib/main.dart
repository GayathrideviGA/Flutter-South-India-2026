// Demo for exercise 01.
//
// Shows a fake 454 px round watch. A block fills the whole child area.
// Flip the switch to see its corners get clipped (off) or stay safe (on).
//
// Run:  flutter create --platforms=android .   (once, to add the runner)
//       flutter run

import 'package:flutter/material.dart';

import 'round_safe.dart';

void main() => runApp(const RoundSafeDemo());

class RoundSafeDemo extends StatefulWidget {
  const RoundSafeDemo({super.key});

  @override
  State<RoundSafeDemo> createState() => _RoundSafeDemoState();
}

class _RoundSafeDemoState extends State<RoundSafeDemo> {
  bool _useRoundSafe = true;

  @override
  Widget build(BuildContext context) {
    // The block we are trying to keep inside the circle.
    final block = Container(
      color: Colors.lightBlueAccent,
      alignment: Alignment.center,
      child: const Text(
        '25 min',
        style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );

    // The "watch": a 454 x 454 box clipped to a circle, like a real display.
    final watch = ClipOval(
      child: Container(
        width: 454,
        height: 454,
        color: Colors.black,
        child: _useRoundSafe ? RoundSafe(child: block) : block,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                // FittedBox scales the 454 px watch down to fit any phone.
                child: Center(child: FittedBox(child: watch)),
              ),
              SwitchListTile(
                title: const Text('Wrap in RoundSafe'),
                subtitle: const Text('Off: corners are clipped. On: they are not.'),
                value: _useRoundSafe,
                onChanged: (v) => setState(() => _useRoundSafe = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
