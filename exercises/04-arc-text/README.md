# 04 · Letters on a Wheel

> **Slide:** "Primitive 2: ArcText"
> **One-line idea:** curved text is just *rotate, draw one letter, rotate again*.

Flutter has no curved text widget. You get one anyway by treating the watch as a
clock face and placing each letter like a numeral.

```
                 0 rad  (12 o'clock)
                   |
        F  O  C  U | S     S  E  S  S  I  O  N
     .'            |                          '.
    /              |                            \
   |  -pi/2 ------ + ------ +pi/2 (3 o'clock)   |
    \              |                            /
     '.            |                          .'
                  pi  (6 o'clock)
```

## Three lines of maths

```
arc length = radius × angle        (the definition of a radian)
angle      = letter width / radius
next angle = this angle + angle        (walk clockwise)
```

That is the whole exercise. Everything else is bookkeeping.

## The drawing loop, one letter at a time

| Step | Canvas call | What it does |
| ---: | ----------- | ------------ |
| 1 | `save()` | Remember the canvas so we can undo our moves |
| 2 | `translate(center)` | Put the origin in the middle of the watch |
| 3 | `rotate(angle + step / 2)` | Turn towards the *middle* of this letter |
| 4 | `translate(-w / 2, -radius - h)` | Slide up to the rim, centre the letter on it |
| 5 | `paint()` | Draw the letter |
| 6 | `restore()` | Undo steps 2-4 for the next letter |

Centring the whole word: start at `mid − totalSpan / 2` instead of `0`.

## What is in this folder

| File | What it teaches |
| ---- | --------------- |
| `lib/arc_text.dart` | `arcSpan`, `paintArcText`, and the `ArcText` widget |
| `lib/main.dart` | Two sliders: radius and where the text sits on the circle |
| `test/arc_text_test.dart` | The `width / radius` rule, tested with the Ahem font |

## Run it

```bash
flutter create --platforms=android .
flutter run
flutter test
```

## Known limits (good conversation starters)

- **Bottom text reads upside down.** Letters are rotated, not mirrored. For a label at 6 o'clock you would flip the direction.
- **No kerning.** Each letter is measured alone, so pairs like "AV" look loose. `letterSpacing` in the demo hides this.
- **Painters are rebuilt every frame.** Fine for a label that rarely changes; for animation, cache them.

## Study questions

1. Why rotate by `angle + step / 2` rather than just `angle`?
2. What happens to the span if you double the font size? If you double the radius?
3. `arcSpan` disposes its `TextPainter`s. What would a leak cost on a battery-powered device?

## Level up

- [ ] Add a `clockwise` flag so a label can run along the *bottom* readably.
- [ ] Throw an error (or clamp) when `arcSpan` exceeds 2π. Text should not overlap itself.
- [ ] Cache the glyph painters in a `State` and measure how many microseconds you save per frame.
