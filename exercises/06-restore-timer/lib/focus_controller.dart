// The glue: state + storage + clock.
//
// Three things are INJECTED so tests can control them:
//   * store : where the run is saved       (InMemoryStore in tests)
//   * now   : what time it is              (a variable the test moves forward)
//
// Life of a timer:
//
//   start(25) --> save endsAt --> Running
//        process killed? no problem, endsAt is on disk
//   app reopens --> FocusController() reads endsAt --> restore() --> Running / Done

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'focus_state.dart';
import 'key_value_store.dart';

class FocusController extends ChangeNotifier {
  FocusController({required KeyValueStore store, DateTime Function()? now})
      : _store = store,
        _now = now ?? DateTime.now {
    _state = _loadAndReconcile(); // runs on every app start
  }

  static const _storageKey = 'focus.run';

  final KeyValueStore _store;
  final DateTime Function() _now;
  late FocusState _state;

  FocusState get state => _state;

  /// The current time according to the injected clock. The UI uses this so
  /// it never calls DateTime.now() itself.
  DateTime get now => _now();

  /// Start a new run of [minutes] and save it straight away.
  void start(int minutes) {
    final total = Duration(minutes: minutes);
    final run = Running(_now().add(total), total);

    _store.write(_storageKey, jsonEncode(run.toJson()));
    _set(run);
  }

  /// Stop counting and forget the saved run.
  void cancel({int minutes = 25}) {
    _store.delete(_storageKey);
    _set(Idle(minutes));
  }

  /// Call this once a second and whenever the app comes back to the front.
  ///
  ///   * end time passed  -> move to Done (and clear the saved run)
  ///   * still running    -> just tell the UI to redraw the new remaining time
  void refresh() {
    final current = _state;
    if (current is! Running) return;

    if (current.endsAt.isAfter(_now())) {
      notifyListeners();
    } else {
      _store.delete(_storageKey);
      _set(const Done());
    }
  }

  /// The user has seen the "Done" screen.
  void acknowledge({int minutes = 25}) => _set(Idle(minutes));

  // ---- private helpers ----

  FocusState _loadAndReconcile() {
    Running? saved;

    final raw = _store.read(_storageKey);
    if (raw != null) {
      try {
        final json = (jsonDecode(raw) as Map).cast<String, Object?>();
        saved = Running.fromJson(json);
      } catch (_) {
        // Corrupt data must never crash the watch app. Drop it and start fresh.
        _store.delete(_storageKey);
      }
    }

    final result = restore(saved, _now());
    // Only a still-running timer needs to stay on disk.
    if (result is! Running) _store.delete(_storageKey);
    return result;
  }

  void _set(FocusState next) {
    _state = next;
    notifyListeners();
  }
}
