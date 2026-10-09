import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:ex02_shape_ring/shape_ring.dart';

void main() {
  const rect = Rect.fromLTWH(0, 0, 400, 400);

  group('every outline starts at 12 o\'clock', () {
    for (final shape in WearShape.values) {
      test(shape.name, () {
        final outline = ringOutline(rect, shape);
        final start = outline.computeMetrics().first.getTangentForOffset(0)!.position;

        expect(start.dx, closeTo(200, 1)); // centre x
        expect(start.dy, closeTo(0, 1)); // top
      });
    }
  });

  group('progressPath', () {
    test('half of a round ring covers only the right half', () {
      final half = progressPath(ringOutline(rect, WearShape.round), 0.5);
      final bounds = half.getBounds();

      expect(bounds.left, closeTo(200, 1.5));
      expect(bounds.right, closeTo(400, 1.5));
    });

    test('more progress means a longer path, for both shapes', () {
      for (final shape in WearShape.values) {
        final outline = ringOutline(rect, shape);
        double length(double p) => progressPath(outline, p)
            .computeMetrics()
            .fold<double>(0, (sum, m) => sum + m.length);

        expect(length(0.25), lessThan(length(0.5)));
        expect(length(0.5), lessThan(length(1.0)));
      }
    });

    test('values outside 0..1 are clamped, never a crash', () {
      final outline = ringOutline(rect, WearShape.square);
      expect(() => progressPath(outline, -1), returnsNormally);
      expect(() => progressPath(outline, 7), returnsNormally);
    });
  });
}
