# Workshop exercises

Six small Flutter projects, in the order of the talk. Each one is
self-contained: its own `pubspec.yaml`, a demo you can run, and tests you can run.

| # | Folder | The idea in one line |
| -: | ------ | -------------------- |
| 1 | [`01-round-safe`](01-round-safe) | A circle has less room than you think: keep UI inside the safe square |
| 2 | [`02-shape-ring`](02-shape-ring) | One progress ring for every watch shape, by walking a `Path` |
| 3 | [`03-chord-text`](03-chord-text) | Wrap text to the width of the circle, row by row |
| 4 | [`04-arc-text`](04-arc-text) | Curve text around the bezel: width ÷ radius = angle |
| 5 | [`05-circle-test`](05-circle-test) | A widget test that fails when the bezel clips text |
| 6 | [`06-restore-timer`](06-restore-timer) | Store the instant a timer ends so it survives the process dying |

## Run any exercise

```bash
cd exercises/01-round-safe
flutter create --platforms=android .   # once: adds the Android runner
flutter run                            # demo (use a Wear OS emulator, or any Android device)
flutter test                           # exercise tests (no emulator needed)
```

The tests need only the Flutter SDK. Exercises 1-5 have no other dependencies;
exercise 6 uses `shared_preferences` for the demo app.

## How to study one

1. Read the folder's `README.md` for the idea.
2. Read the `lib/` file top to bottom. The header comment is the lesson.
3. Run the tests, then break the code on purpose and watch which test fails.
4. Try the "Level up" list.
