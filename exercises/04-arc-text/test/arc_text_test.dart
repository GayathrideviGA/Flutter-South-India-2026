// Reminder: flutter test draws text with the "Ahem" font, where every
// character is exactly 1 em wide. So "ABCD" at fontSize 10 is 40 px wide.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex04_arc_text/arc_text.dart';

const _style = TextStyle(fontSize: 10);

void main() {
  // Measuring text needs the Flutter test binding (and its test font) running.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('arcSpan  (angle = width / radius)', () {
    test('40 px of text on a 100 px radius covers 0.4 rad', () {
      expect(arcSpan('ABCD', _style, 100), closeTo(0.4, 1e-9));
    });

    test('doubling the radius halves the angle', () {
      final small = arcSpan('ABCD', _style, 100);
      final large = arcSpan('ABCD', _style, 200);
      expect(large, closeTo(small / 2, 1e-9));
    });

    test('more letters cover more of the circle', () {
      expect(arcSpan('ABCDEFGH', _style, 100), greaterThan(arcSpan('ABCD', _style, 100)));
    });
  });

  testWidgets('ArcText builds and paints without errors', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 300,
          height: 300,
          child: ArcText('FOCUS SESSION', radius: 120, style: _style),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ArcText), findsOneWidget);
  });
}
