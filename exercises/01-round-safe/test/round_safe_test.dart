import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex01_round_safe/round_safe.dart';

void main() {
  group('roundSafeInset', () {
    test('round: 14.6% of the diameter, so 66.5 px on a 454 px watch', () {
      expect(roundSafeInset(454, WearShape.round), closeTo(66.48, 0.05));
    });

    test('square: a small fixed margin, whatever the size', () {
      expect(roundSafeInset(454, WearShape.square), kSquareMargin);
      expect(roundSafeInset(200, WearShape.square), kSquareMargin);
    });
  });

  group('RoundSafe widget', () {
    testWidgets('shrinks the child to the biggest square inside the circle',
        (tester) async {
      const childKey = Key('child');

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 454,
              height: 454,
              child: RoundSafe(child: SizedBox.expand(key: childKey)),
            ),
          ),
        ),
      );

      // 454 / sqrt(2) = 321.04
      final size = tester.getSize(find.byKey(childKey));
      expect(size.width, closeTo(321.04, 0.1));
      expect(size.height, closeTo(321.04, 0.1));
    });

    testWidgets('square shape only keeps a small margin', (tester) async {
      const childKey = Key('child');

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: RoundSafe(
                shape: WearShape.square,
                child: SizedBox.expand(key: childKey),
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(284, 284));
    });
  });
}
