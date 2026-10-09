// Exercise 03 - ChordText
//
// GOAL
//   Wrap a paragraph so each row is as wide as the CIRCLE allows at that row.
//   Rows near the middle are wide, rows near the bezel are short. The text
//   can then be bigger than it could be inside a plain rectangle.
//
// VOCABULARY
//   chord  : a straight line across a circle, e.g. one row of text.
//   far    : the edge of a row that is FURTHER from the centre. It touches
//            the bezel first, so it decides how wide the row can be.
//
//                 ___________
//              .'   row 0     '.     row 0 is short: its far edge (top)
//             /  ------------  \     is close to the bezel
//            |  --------------  |
//            |  --------------  |    middle rows are wide
//             \  ------------  /
//              '.___________.'
//
// HOW A ROW'S WIDTH IS WORKED OUT
//   A row sits at distance `far` from the centre. By Pythagoras the circle is
//   `2 * sqrt(r*r - far*far)` wide at that height.
//
// THE ALGORITHM IN ONE PARAGRAPH
//   For a font size, try 1 row, then 2, then 3 ... For each row count:
//   centre the block of rows, work out each row's width budget, and fill rows
//   greedily with words. The first row count where every word fits (and no
//   row is empty) wins. If nothing fits, make the font smaller and repeat.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How wide a row may be, given the distance of its far edge from the
/// centre. Returns null when the row cannot exist (it pokes out of the shape).
typedef RowBudget = double? Function(double farEdge);

/// Budget for a circle of [radius]: the chord width at that height.
RowBudget chordBudget(double radius) {
  return (far) {
    if (far >= radius) return null; // outside the circle
    return 2 * math.sqrt(radius * radius - far * far);
  };
}

/// Budget for the plain "safe square" inside the same circle.
/// Used as the baseline we compare ChordText against.
RowBudget safeSquareBudget(double radius) {
  final side = radius * math.sqrt2;
  return (far) => far > side / 2 ? null : side;
}

/// The answer: which font size and which text rows.
class ChordLayout {
  const ChordLayout(this.fontSize, this.lines);
  final double fontSize;
  final List<String> lines;
}

/// Line height as a multiple of the font size. We set it explicitly so the
/// maths here and the widget below always agree.
const double kLineHeightFactor = 1.2;

/// Width in logical pixels of [text] drawn with [style] on one line.
double measureWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// Distance from the centre to the FAR edge of row [row] when [rows] rows of
/// height [lineHeight] are centred on the circle.
double farEdge(int row, int rows, double lineHeight) {
  final top = (row - rows / 2) * lineHeight; // negative above the centre
  return math.max(top.abs(), (top + lineHeight).abs());
}

/// Try to place [words] into exactly [rows] rows. Returns null if they do not fit.
List<String>? _fill(List<String> words, TextStyle style, double lineHeight, int rows, RowBudget budgetFor) {
  final lines = <String>[];
  var next = 0; // index of the next word to place

  for (var row = 0; row < rows; row++) {
    final budget = budgetFor(farEdge(row, rows, lineHeight));
    if (budget == null) return null; // this row would leave the shape

    var line = '';
    while (next < words.length) {
      final candidate = line.isEmpty ? words[next] : '$line ${words[next]}';
      if (measureWidth(candidate, style) > budget) break; // row is full
      line = candidate;
      next++;
    }

    if (line.isEmpty) return null; // even one word is too wide for this row
    lines.add(line);
  }

  // Success only if every word found a home.
  return next == words.length ? lines : null;
}

/// Finds the largest font size (between [minFont] and [maxFont]) at which
/// [text] fits the shape described by [budgetFor]. Returns null if even
/// [minFont] does not fit.
ChordLayout? fitText(
  String text, {
  required TextStyle base,
  required RowBudget budgetFor,
  double minFont = 10,
  double maxFont = 60,
  int maxRows = 14,
}) {
  final words = text.trim().split(RegExp(r'\s+'));

  for (var size = maxFont; size >= minFont; size -= 1) {
    final style = base.copyWith(fontSize: size, height: kLineHeightFactor);
    final lineHeight = size * kLineHeightFactor;

    for (var rows = 1; rows <= maxRows; rows++) {
      final lines = _fill(words, style, lineHeight, rows, budgetFor);
      if (lines != null) return ChordLayout(size, lines);
    }
  }
  return null;
}

/// Convenience: fit [text] to a circle of [radius].
ChordLayout? fitChordText(
  String text, {
  required TextStyle base,
  required double radius,
  double minFont = 10,
  double maxFont = 60,
}) {
  return fitText(
    text,
    base: base,
    budgetFor: chordBudget(radius),
    minFont: minFont,
    maxFont: maxFont,
  );
}

/// A paragraph that follows the circle.
///
/// ```dart
/// const ChordText('Standup moved to 3:40 PM', style: TextStyle(color: Colors.white))
/// ```
class ChordText extends StatelessWidget {
  const ChordText(
    this.text, {
    super.key,
    required this.style,
    this.minFontSize = 10,
    this.maxFontSize = 48,
    this.radiusFactor = 0.88,
  });

  final String text;
  final TextStyle style;
  final double minFontSize;
  final double maxFontSize;

  /// Use only this fraction of the radius. 1.0 would let text touch the
  /// bezel; around 0.88 leaves a comfortable gap.
  final double radiusFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final radius = constraints.biggest.shortestSide / 2 * radiusFactor;

        final layout = fitChordText(
          text,
          base: style,
          radius: radius,
          minFont: minFontSize,
          maxFont: maxFontSize,
        );

        // Nothing fits even at the smallest size: show the smallest text
        // rather than nothing, and let the caller see the problem.
        final fontSize = layout?.fontSize ?? minFontSize;
        final lines = layout?.lines ?? [text];
        final lineStyle = style.copyWith(fontSize: fontSize, height: kLineHeightFactor);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in lines)
                Text(line, style: lineStyle, textAlign: TextAlign.center, maxLines: 1, softWrap: false),
            ],
          ),
        );
      },
    );
  }
}
