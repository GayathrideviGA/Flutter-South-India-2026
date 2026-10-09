# 02 · Ring Cartography

> **Slide:** "One ring painter for every shape"
> **One-line idea:** don't teach the painter about shapes. Hand it a *map* (a `Path`) and let it walk.

Think of a ring progress bar as a hiker on a trail:

```
        start = 12 o'clock
              *
        .-----+-----.            *-------+-------.
      /               \          |               |
     |                 |   or    |               |
      \               /          |               |
        '-----------'            '---------------'
        round trail                square (rounded rect) trail

     "Walk 64% of the trail, leave a bright line behind you."
```

The painter never asks *"am I round?"*. It asks the trail how long it is and
walks a fraction of that length. New shape? Draw a new trail. The walker stays.

## The three moves

| Move | Code | In plain words |
| ---- | ---- | -------------- |
| **Draw the trail** | `ringOutline(rect, shape)` | A closed `Path` that starts at 12 o'clock and runs clockwise |
| **Measure it** | `path.computeMetrics()` | Ask the path for its length and points along it |
| **Walk part of it** | `metric.extractPath(0, length * progress)` | Cut out the first N% as a new path |

### Why build the path starting at 12?

Paths have a start point, and progress begins there. Ready-made helpers such as
`addOval` begin at **3 o'clock**, which would make your ring start on the right
side of the watch. You could rotate the canvas by −90° afterwards, or you can
build the path from the top in the first place. This exercise does the second:
fewer moving parts, nothing to forget.

> Don't take my word for it: print
> `(Path()..addOval(rect)).computeMetrics().first.getTangentForOffset(0)!.position`
> and see where it lands.

### The stroke-width trap

A stroke is centred on the path. A 12 px stroke on a path touching the edge
loses its outer 6 px. So the painter shrinks the rect by `strokeWidth / 2`
(`deflate`) before building the trail.

## What is in this folder

| File | What it teaches |
| ---- | --------------- |
| `lib/shape_ring.dart` | `ringOutline`, `progressPath`, `ShapeRingPainter`, `ShapeRing` |
| `lib/main.dart` | Slider for progress, toggle for shape |
| `test/shape_ring_test.dart` | Testing geometry: start point, half ring bounds, clamping |

## Run it

```bash
flutter create --platforms=android .
flutter run
flutter test
```

## Study questions

1. In `ringOutline` for `square`, which angle does each corner `arcTo` start at, and why?
2. What would happen to a ring at 100% if you removed `StrokeCap.round`?
3. `shouldRepaint` lists four fields. What bug appears if you forget `shape`?

## Level up

- [ ] Add a third shape, `WearShape.pill`, for watches with very tall rounded screens.
- [ ] Draw a small dot at the *end* of the progress with `getTangentForOffset`.
- [ ] Animate `progress` with an `AnimationController`. Does `shouldRepaint` still behave?
