# 03 · Chord of the Day

> **Slide:** "Primitive 1: ChordText"
> **One-line idea:** a newspaper column is a rectangle; a watch face is not. Let every line use *its own* width.

```
   plain wrapping (a rectangle)        chord wrapping (the circle)

        .-----------.                       .-----------.
      /  Standup      \                   /   Standup     \
     |   moved to      |                 |  moved to 3:40   |
     |   3:40 PM in    |        vs       | PM in the Orion  |
     |   the Orion     |                 | room. Priya is   |
      \  room.        /                   \ bringing the   /
        '-----------'                       '--demo.-----'
     small text, empty sides             bigger text, full circle
```

## Words you will meet

| Word | Meaning |
| ---- | ------- |
| **chord** | A straight line across a circle. Each row of text is a chord. |
| **far edge** | The edge of a row *further* from the centre. It reaches the bezel first, so it sets the row's width. |
| **budget** | How wide a row is allowed to be: `2 * sqrt(r² − far²)` |

## The algorithm, in four steps

1. Pick a font size (start big, shrink one px at a time).
2. Pick a row count (1, 2, 3 …). Rows are **centred** on the circle.
3. For each row, compute its budget from its far edge, then pack words in until the next word would not fit.
4. Success = every word placed and no row empty. Otherwise try more rows; if none work, shrink the font.

Tiny trace (radius 100, three rows, rows are 30 px tall):

| Row | Far edge | Budget | Content |
| --: | -------: | -----: | ------- |
| 0   | 45       | 179    | `Standup` |
| 1   | 15       | 198    | `moved to` |
| 2   | 45       | 179    | `3:40 PM` |

Rows 0 and 2 are narrower than row 1 because they sit closer to the bezel.

## What is in this folder

| File | What it teaches |
| ---- | --------------- |
| `lib/chord_text.dart` | `chordBudget`, `farEdge`, greedy row filling, `fitChordText`, the `ChordText` widget |
| `lib/main.dart` | Plain `Text` vs `ChordText` on two round watches |
| `test/chord_text_test.dart` | Properties, not pixels: every word kept, every row within its chord, chord beats the safe square |

### About the tests

`flutter test` draws text in the **Ahem** font where every character is exactly
one font-size wide. That makes widths predictable. The numbers (and "chord font
is bigger") hold for *that* font; with a real font the sizes will differ, but the
chord layout should still be at least as big as the square one.

## Run it

```bash
flutter create --platforms=android .
flutter run
flutter test
```

## Study questions

1. Why does the *far* edge decide the width and not the near edge or the middle?
2. Why can a row count that works for 3 rows fail for 4 rows, even though more rows means more room?
3. `maxRows` is 14. What goes wrong if you remove that limit and the text is one giant word?

## Level up

- [ ] Hyphenate or break a word that is wider than every row instead of returning `null`.
- [ ] Cache `measureWidth` results in a `Map<String, double>`. How much faster is `fitText`?
- [ ] Add `TextAlign.left` that starts each row at the chord's left end instead of centring.
