# 06 · Store the Instant

> **Slide:** "Model time so it survives the process dying"
> **One-line idea:** save *when the timer ends*, never *how much is left*.

Android is allowed to kill your watch app whenever it likes. Two ways to model a
25-minute timer, and what each says after the app was dead for 10 minutes:

```
                         09:00 start      09:05          09:15 reopen        09:25
  time ------------------|----------------|--------------|-------------------|
                          start(25)       process killed   what do we show?

  COUNTER  (stored "20 min left" at 09:05)       shows 20:00      WRONG, frozen in time
  INSTANT  (stored "ends at 09:25")              shows 10:00      RIGHT, just subtract the clock
```

A counter is a photograph of a moving thing. An end time stays true.

## The design in three layers

```
   focus_state.dart        pure Dart. Idle / Running / Done, restore(). No Flutter, no clock calls.
          |
   focus_controller.dart   joins state + a KeyValueStore + an injected clock
          |
   main.dart               the screen. A 1-second ticker only REDRAWS; it is not the source of truth.
```

### Three decisions worth stealing

1. **`now` is a parameter.** `run.remaining(now)` instead of `DateTime.now()` inside. A test jumps 25 minutes in one line.
2. **Storage is an interface.** Tests use `InMemoryStore`; the app uses `PrefsStore`. Same controller, no mocks.
3. **Only `Running` is saved.** `Done` is shown once and forgotten, so reopening a week later does not replay "finished!".

## `restore()` is a three-row table

| Saved on disk | End time vs now | Result |
| ------------- | --------------- | ------ |
| a run | in the future | `Running` (carry on) |
| a run | passed (or equal) | `Done` |
| nothing | n/a | `Idle` |

## The kill test, by hand

1. `flutter run`, tap **1 min**.
2. Force-stop the app from system settings.
3. Reopen within the minute: the countdown continues from the right place.
4. Repeat, but wait longer than a minute: you land on the Done screen.

The automated version lives in `test/focus_restore_test.dart`. Throw the old
controller away, build a new one on the same store, move the fake clock.

## What is in this folder

| File | What it teaches |
| ---- | --------------- |
| `lib/focus_state.dart` | Sealed class, `remaining`, `progress`, JSON, `restore()` |
| `lib/key_value_store.dart` | Interface plus `InMemoryStore` |
| `lib/prefs_store.dart` | The real thing, on `shared_preferences` |
| `lib/focus_controller.dart` | Start, cancel, refresh, acknowledge, reconcile on launch |
| `lib/main.dart` | Lifecycle-aware demo screen |
| `test/focus_restore_test.dart` | Kill-and-reopen scenarios |

## Run it

```bash
flutter create --platforms=android .
flutter pub get
flutter run
flutter test
```

## Not in scope here (on purpose)

A Dart `Timer` dies with the process too. To *ring a bell* while the app is dead,
schedule the completion alert with the operating system (see the "Keep the timer
alive" slide: Ongoing Activity plus a system notification). This exercise only
makes sure the **display** is right when you come back.

## Study questions

1. Why save `endsAt` in UTC?
2. `restore()` treats "ends exactly now" as finished. Why is `isAfter` safer than `!isBefore`?
3. What does the controller do with corrupt JSON, and why must it never throw?

## Level up

- [ ] Add pause and resume. What do you store while paused: an instant, or a duration?
- [ ] Schedule a system notification at `endsAt` when `start()` is called.
- [ ] Persist a history of finished sessions and show today's total.
