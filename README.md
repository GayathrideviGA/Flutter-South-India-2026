# Flutter South India 2026 - Wearable Flutter Workshop

[Link to session slide](https://docs.google.com/presentation/d/11hSKa6kkhC9nfntVeo-pNkR2MTRuBsk_-9R3LFM9L6s/edit?usp=sharing)

Hands-on exercises for the talk **Building Wearable Experiences with Flutter**.

Flutter lays out rectangles. A watch is round. These six small projects give you
the tools Flutter does not ship for circles, one idea at a time.

---

## Contents

- [What you will build](#what-you-will-build)
- [Repository layout](#repository-layout)
- [Before you start](#before-you-start)
- [Run an exercise](#run-an-exercise)
- [How to study an exercise](#how-to-study-an-exercise)
- [Good to know](#good-to-know)
- [Speakers](#speakers)

---

## What you will build

Work through the exercises in order. Each one builds on the idea before it.

| # | Exercise | The idea in one line | Main file |
| -: | -------- | -------------------- | --------- |
| 1 | [Round-safe layout](exercises/01-round-safe) | A circle has less room than you think, so keep UI inside the safe square | `round_safe.dart` |
| 2 | [Shape-agnostic ring](exercises/02-shape-ring) | One progress ring for every watch shape, by walking a `Path` | `shape_ring.dart` |
| 3 | [ChordText](exercises/03-chord-text) | Wrap text to the width of the circle, row by row | `chord_text.dart` |
| 4 | [ArcText](exercises/04-arc-text) | Curve text around the bezel: width ÷ radius = angle | `arc_text.dart` |
| 5 | [Circle test](exercises/05-circle-test) | A widget test that fails when the bezel clips text | `circle_matchers.dart` |
| 6 | [Persist and restore](exercises/06-restore-timer) | Store the instant a timer ends so it survives the process dying | `focus_state.dart` |

Every exercise folder has its own `README.md` with the idea, a diagram,
study questions and a "Level up" checklist.

---

## Repository layout

```text
wearable-flutter-workshop/
├── README.md                  <- you are here
└── exercises/
    ├── .gitignore
    ├── 01-round-safe/
    │   ├── README.md          the idea, explained
    │   ├── pubspec.yaml
    │   ├── lib/               the code (read the header comment first)
    │   └── test/              tests you can run
    ├── 02-shape-ring/
    ├── 03-chord-text/
    ├── 04-arc-text/
    ├── 05-circle-test/
    └── 06-restore-timer/
```

Each exercise is a separate, self-contained Flutter project. You can open and
run any of them without the others.

---

## Before you start

| You need | Notes |
| -------- | ----- |
| Flutter SDK | Dart 3.6 or newer |
| An Android target | A **Wear OS emulator** is ideal. Any Android phone or emulator also works for the demos |
| An editor | VS Code or Android Studio with the Flutter plugin |

Not sure your setup is ready? Run `flutter doctor`.

---

## Run an exercise

From the repository root, pick a folder and run these commands:

```bash
cd exercises/01-round-safe
flutter create --platforms=android .   # once: adds the Android runner
flutter run                            # starts the demo
flutter test                           # runs the exercise tests
```

Replace `01-round-safe` with any other exercise folder.

> **Tests need no emulator.** `flutter test` runs on your computer using only the
> Flutter SDK. You only need a device or emulator for `flutter run`.

---

## How to study an exercise

1. **Read** the exercise `README.md` to get the idea.
2. **Open** the main file in `lib/`. The comment at the top of the file is the lesson.
3. **Run** the demo and play with it.
4. **Test** it with `flutter test`, then break the code on purpose and see which test fails.
5. **Try** the "Level up" checklist at the bottom of the exercise README.

---

## Good to know

- **Exercises 1 to 5** depend only on the Flutter SDK.
- **Exercise 6** also uses [`shared_preferences`](https://pub.dev/packages/shared_preferences) for the demo app. Run `flutter pub get` inside that folder.
- The exercises use a small `WearShape` enum so they stay self-contained. In a real app, the `wear` plugin can tell you the shape of the device.
- `flutter test` draws text in a test font where every character has the same width. Numbers in tests are exact for that font, and real fonts will give slightly different sizes.
- Each exercise has starter and solution branches. Check the branch list in this repository.

---

## Speakers

| Name | Role |
| ---- | ---- |
| **Gayathri Devi Srinivasan** | Mobile Engineer, Degreed Inc |
| **Kamal Shree** | Senior Developer Advocate, Microsoft. Google Developer Expert, Flutter & Dart |


Found a bug or have an idea? Open an issue or a pull request.
