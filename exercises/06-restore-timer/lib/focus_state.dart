// Exercise 06 - the state of a focus timer
//
// THE RULE OF THIS WHOLE EXERCISE
//
//     Store the INSTANT the timer ends, never a counter.
//
// WHY
//   Android may kill a watch app at any time to save battery. A counter
//   ("12 minutes left") is frozen the moment the process dies, so it is wrong
//   when you come back. An end time ("ends at 09:25:00") is still true no
//   matter how long the app was dead: just compare it with the clock.
//
//   counter  : 25 -> 24 -> 23 -> [process killed] ... reopen: 23?  (wrong)
//   instant  : endsAt = 09:25   [process killed] ... reopen: 09:25 - now (right)

/// The three things a focus timer can be.
///
/// `sealed` lets the compiler check that every `switch` handles all three.
sealed class FocusState {
  const FocusState();
}

/// Waiting to start. [minutes] is the length the user has chosen.
class Idle extends FocusState {
  const Idle(this.minutes);
  final int minutes;
}

/// Counting down. This is the only state we save to disk.
class Running extends FocusState {
  const Running(this.endsAt, this.total);

  /// The moment the timer finishes.
  final DateTime endsAt;

  /// The length it was started with (needed to draw the progress ring).
  final Duration total;

  /// Time left. Takes `now` as an argument instead of calling DateTime.now()
  /// so tests can jump the clock forward in a millisecond.
  Duration remaining(DateTime now) => endsAt.difference(now);

  /// 0.0 at the start, 1.0 when finished.
  double progress(DateTime now) {
    final left = remaining(now).inMilliseconds / total.inMilliseconds;
    return (1 - left).clamp(0.0, 1.0).toDouble();
  }

  /// Plain JSON-friendly data. Always saved in UTC so time zones and
  /// daylight-saving changes cannot shift it.
  Map<String, Object?> toJson() => {
        'endsAt': endsAt.toUtc().toIso8601String(),
        'totalMs': total.inMilliseconds,
      };

  factory Running.fromJson(Map<String, Object?> json) => Running(
        DateTime.parse(json['endsAt']! as String),
        Duration(milliseconds: json['totalMs']! as int),
      );
}

/// Finished. We do not save this: after the user sees it once, it is gone.
class Done extends FocusState {
  const Done();
}

/// Decide what state to show when the app starts or comes back to the front.
///
/// [saved] is whatever we found on disk (null if nothing).
///
/// Three cases, and nothing else:
///   * a run that has not ended yet       -> carry on with it
///   * a run whose end time has passed    -> it finished while we were away
///   * nothing saved                      -> a fresh timer
FocusState restore(Running? saved, DateTime now, {int defaultMinutes = 25}) {
  return switch (saved) {
    Running run when run.endsAt.isAfter(now) => run,
    Running() => const Done(),
    null => Idle(defaultMinutes),
  };
}
