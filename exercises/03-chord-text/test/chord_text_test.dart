// Flutter tests draw every glyph with the "Ahem" font, where each character
// (spaces too) is exactly 1 em wide. That makes widths predictable:
//     width of "hello" at font size 20  ==  5 * 20  ==  100.
// If you change the message or radius, re-check the numbers below.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex03_chord_text/chord_text.dart';

const _message = 'Standup moved to 3:40 PM in the Orion room. Priya is bringing the demo.';
const _radius = 227 * 0.88; // a 454 px watch, 88% of the radius
const _base = TextStyle();

void main() {
  // Text measuring needs the Flutter test binding (and its test font) running.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('chordBudget', () {
    test('widest at the centre, equal to the diameter', () {
      expect(chordBudget(100)(0), closeTo(200, 1e-9));
    });

    test('shrinks towards the bezel and is null outside the circle', () {
      final budget = chordBudget(100);
      expect(budget(50)!, lessThan(budget(0)!));
      expect(budget(100), isNull);
      expect(budget(130), isNull);
    });
  });

  group('fitChordText', () {
    late ChordLayout layout;
    setUpAll(() => layout = fitChordText(_message, base: _base, radius: _radius)!);

    test('keeps every word, in order', () {
      expect(layout.lines.join(' '), _message);
    });

    test('every row fits the chord at its own height', () {
      final style = _base.copyWith(fontSize: layout.fontSize, height: kLineHeightFactor);
      final lineHeight = layout.fontSize * kLineHeightFactor;
      final budget = chordBudget(_radius);

      for (var row = 0; row < layout.lines.length; row++) {
        final allowed = budget(farEdge(row, layout.lines.length, lineHeight))!;
        expect(measureWidth(layout.lines[row], style), lessThanOrEqualTo(allowed + 1e-9));
      }
    });

    test('beats wrapping inside the safe square (the whole point)', () {
      final square = fitText(
        _message,
        base: _base,
        budgetFor: safeSquareBudget(_radius),
      )!;

      expect(layout.fontSize, greaterThan(square.fontSize));
    });

    test('returns null when the text cannot fit even at the minimum size', () {
      expect(
        fitChordText('Extraordinarily', base: _base, radius: 20, minFont: 10, maxFont: 12),
        isNull,
      );
    });
  });
}
