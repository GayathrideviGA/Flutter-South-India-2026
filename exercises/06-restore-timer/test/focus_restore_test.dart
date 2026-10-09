// How these tests "kill the process":
//   * the InMemoryStore stands in for the disk and is kept,
//   * the old FocusController is thrown away (the dead process),
//   * a NEW FocusController is built on the same store (the app reopening),
//   * the fake clock is moved forward to say how long we were gone.

import 'package:flutter_test/flutter_test.dart';
import 'package:ex06_restore_timer/focus_controller.dart';
import 'package:ex06_restore_timer/focus_state.dart';
import 'package:ex06_restore_timer/key_value_store.dart';

void main() {
  final t0 = DateTime.utc(2026, 10, 10, 9); // 09:00 UTC
  late DateTime clock;
  late InMemoryStore disk;

  FocusController openApp() => FocusController(store: disk, now: () => clock);

  setUp(() {
    clock = t0;
    disk = InMemoryStore();
  });

  group('restore()  (the pure decision)', () {
    final run = Running(t0.add(const Duration(minutes: 25)), const Duration(minutes: 25));

    test('run not finished yet -> keep running', () {
      expect(restore(run, t0.add(const Duration(minutes: 10))), same(run));
    });

    test('run already finished -> Done', () {
      expect(restore(run, t0.add(const Duration(minutes: 26))), isA<Done>());
    });

    test('exactly at the end time counts as finished', () {
      expect(restore(run, run.endsAt), isA<Done>());
    });

    test('nothing saved -> fresh Idle with the default length', () {
      final state = restore(null, t0);
      expect(state, isA<Idle>());
      expect((state as Idle).minutes, 25);
    });
  });

  group('Running', () {
    test('remaining and progress follow the clock you pass in', () {
      final run = Running(t0.add(const Duration(minutes: 25)), const Duration(minutes: 25));
      final later = t0.add(const Duration(minutes: 10));

      expect(run.remaining(later), const Duration(minutes: 15));
      expect(run.progress(later), closeTo(0.4, 1e-9));
    });

    test('JSON round trip keeps the exact instant', () {
      final run = Running(t0.add(const Duration(minutes: 25)), const Duration(minutes: 25));
      final copy = Running.fromJson(run.toJson());

      expect(copy.endsAt.isAtSameMomentAs(run.endsAt), isTrue);
      expect(copy.total, run.total);
    });
  });

  group('FocusController  (kill and reopen)', () {
    test('process dies mid-run: the timer is still right', () {
      openApp().start(25); // run starts, then the process is "killed"

      clock = t0.add(const Duration(minutes: 10));
      final reopened = openApp(); // a brand-new controller, same disk

      final state = reopened.state;
      expect(state, isA<Running>());
      expect((state as Running).remaining(clock), const Duration(minutes: 15));
    });

    test('timer ends while the app is dead: reopening shows Done', () {
      openApp().start(25);

      clock = t0.add(const Duration(minutes: 30));
      final reopened = openApp();

      expect(reopened.state, isA<Done>());
      expect(disk.read('focus.run'), isNull, reason: 'a finished run must be cleared');
    });

    test('corrupt saved data falls back to Idle instead of crashing', () {
      disk.write('focus.run', '{not json');

      final app = openApp();

      expect(app.state, isA<Idle>());
      expect(disk.read('focus.run'), isNull);
    });

    test('refresh() turns Running into Done once the end time passes', () {
      final app = openApp()..start(1);

      clock = t0.add(const Duration(seconds: 59));
      app.refresh();
      expect(app.state, isA<Running>());

      clock = t0.add(const Duration(minutes: 1));
      app.refresh();
      expect(app.state, isA<Done>());
    });

    test('cancel() clears the saved run', () {
      final app = openApp()..start(5);
      app.cancel();

      expect(app.state, isA<Idle>());
      expect(openApp().state, isA<Idle>());
    });
  });
}
