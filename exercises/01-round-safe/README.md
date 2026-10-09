# 01 · The Corner Problem

> **Slide:** "A circle has less room than you think"
> **One-line idea:** a screen is a rectangle, a watch is a circle, and the four corners are lies.

```
   what Flutter hands you          what the watch actually shows

   +------------------+                  .-------.
   | A              B |               .'           '.
   |                  |              /               \
   |                  |      -->    |                 |
   |                  |              \               /
   | C              D |               '.           .'
   +------------------+                  '-------'

   A, B, C, D exist in layout and are clipped by the bezel.
```

Put a button in corner **A** and your user never sees it. This exercise gives you
one widget, `RoundSafe`, that keeps everything inside the part of the screen
that survives.

## The only formula you need

The biggest square inside a circle has its **diagonal equal to the diameter**:

```
side * sqrt(2) = diameter     ->     side = diameter / sqrt(2)  ≈ 70.7% of diameter
```

So every edge of the screen must give up `(1 − 0.707) / 2 ≈ 14.6%` of the diameter.

| Watch diameter (logical px) | Inset per side | Safe square |
| --------------------------: | -------------: | ----------: |
| 454                         | 66.5           | 321.0       |
| 396                         | 58.0           | 280.0       |
| 360                         | 52.7           | 254.6       |
| 320                         | 46.9           | 226.3       |

## What is in this folder

| File | What it teaches |
| ---- | --------------- |
| `lib/round_safe.dart` | `roundSafeInset()` (pure maths) and the `RoundSafe` widget on top of it |
| `lib/main.dart` | A fake 454 px watch with a switch: clipped vs safe |
| `test/round_safe_test.dart` | Testing the maths first, then the widget |

## Run it

```bash
flutter create --platforms=android .   # once: adds the Android runner
flutter run                            # flip the switch and watch the corners
flutter test
```

## Study questions

1. Why is `roundSafeInset` a separate function instead of living inside `build`?
2. Why does `RoundSafe` use `LayoutBuilder` rather than `MediaQuery.sizeOf`?
   (Hint: what happens when you nest it inside a smaller box?)
3. Square watches only keep an 8 px margin. What would break if they used 14.6% too?

## Level up

- [ ] Replace the `shape` parameter with the `wear` plugin's `WatchShape` so the
      real device decides.
- [ ] Add a `fraction` parameter (default `1.0`) so a single screen can ask for
      *extra* safety, e.g. `0.9` of the safe square for small text.
- [ ] Add a test that nests two `RoundSafe` widgets. Is the result what you expected?
