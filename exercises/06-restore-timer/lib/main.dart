// Demo for exercise 06: a real, saved timer.
//
// TRY THE KILL TEST (the one that matters)
//   1. Tap "1 min" so a run starts.
//   2. Swipe the app away / force-stop it from Settings.
//   3. Open it again within the minute: the countdown carries on.
//   4. Repeat, but wait longer than a minute: you land on "Done".
//
// Run:  flutter create --platforms=android .   (once)
//       flutter run

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'focus_controller.dart';
import 'focus_state.dart';
import 'prefs_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(RestoreDemo(controller: FocusController(store: PrefsStore(prefs))));
}

class RestoreDemo extends StatefulWidget {
  const RestoreDemo({super.key, required this.controller});
  final FocusController controller;

  @override
  State<RestoreDemo> createState() => _RestoreDemoState();
}

class _RestoreDemoState extends State<RestoreDemo> with WidgetsBindingObserver {
  Timer? _ticker;

  FocusController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Only the UI needs a ticker (to redraw). The truth lives in endsAt.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _c.refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back to the front: re-check the clock immediately.
    if (state == AppLifecycleState.resumed) _c.refresh();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: ListenableBuilder(
            listenable: _c,
            builder: (context, _) => _body(context),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    // `switch` on a sealed class: the compiler checks all three states.
    return switch (_c.state) {
      Idle() => _idle(),
      Running run => _running(context, run),
      Done() => _done(),
    };
  }

  Widget _idle() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ready'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final m in const [1, 5, 25])
                FilledButton(onPressed: () => _c.start(m), child: Text('$m min')),
            ],
          ),
        ],
      );

  Widget _running(BuildContext context, Running run) {
    final left = run.remaining(_c.now);
    final mm = left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = left.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$mm:$ss', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 8),
        SizedBox(width: 160, child: LinearProgressIndicator(value: run.progress(_c.now))),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _c.cancel, child: const Text('Cancel')),
      ],
    );
  }

  Widget _done() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64),
          const SizedBox(height: 8),
          FilledButton(onPressed: _c.acknowledge, child: const Text('Done')),
        ],
      );
}
