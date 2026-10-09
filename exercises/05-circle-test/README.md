# 05 · Case File: The Bezel Inspector

> **Slide:** "Primitive 3: tests that know about circles"
> **One-line idea:** a clipped label is a bug. Bugs belong in CI, not in your user's eye.

---

### THE CRIME

Text at the top-left of a round watch is half hidden by the bezel. Nobody noticed
in review, because on a phone-shaped emulator it looked fine.

### THE SUSPECT WE DON'T TRUST

```dart
ClipOval(child: myFace)
```

`ClipOval` is a **cover-up**: it hides the damage without telling anyone. Your
test stays green while the user loses letters.

### THE INSPECTOR

`expectInsideCircle(tester)` walks every piece of text on screen and checks one
rule:

```
All four corners of every text box must be no further from the centre
than the radius.
```

```
        corner A ----- inside  (distance < radius)   OK
        corner B ----- outside (distance > radius)   FAIL: "text clipped by the bezel at Rect.fromLTRB(...)"
```

### EVIDENCE IN THIS FOLDER

| Exhibit | File | Role |
| ------- | ---- | ---- |
| A | `test/support/circle_matchers.dart` | The reusable inspector. Copy it into any project. |
| B | `lib/watch_faces.dart` | `ClippedFace` (guilty) and `SafeFace` (innocent) |
| C | `test/circle_test.dart` | Proves SafeFace passes **and** that the inspector really catches ClippedFace |
| D | `lib/main.dart` | Both faces side by side, so you can *see* the difference |

### WHY EXHIBIT C HAS A "TEST FOR THE TEST"

A checker that can never fail proves nothing. The second test pumps the broken
face and expects the inspector to throw. If someone weakens the inspector later,
that test goes red.

### TOLERANCE

`kTolerance = 0.5` px. A corner placed exactly on the edge should not fail
because of floating-point noise.

## Run the investigation

```bash
flutter create --platforms=android .
flutter test        # the point of this exercise
flutter run         # optional: look at the two faces
```

## Questions for the witness

1. The inspector checks `RichText`. Which widgets would it miss (icons, images, painted text)?
2. Why does `useWatchScreen` set `devicePixelRatio = 1`?
3. Why `addTearDown(tester.view.reset)` and not a line at the end of the test?

## Open cases

- [ ] Extend the inspector to include `Icon` and `Image` widgets.
- [ ] Make it print *how far* each corner is outside the circle.
- [ ] Run the check at 396 px and 360 px as well, using a loop over sizes.
