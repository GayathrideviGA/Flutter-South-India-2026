import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex05_circle_test/watch_faces.dart';

import 'support/circle_matchers.dart';

/// Pumps [face] on a 454 px watch screen.
Future<void> pumpFace(WidgetTester tester, Widget face) async {
  useWatchScreen(tester);
  await tester.pumpWidget(
    MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: face)),
  );
}

void main() {
  testWidgets('SafeFace stays inside the bezel', (tester) async {
    await pumpFace(tester, const SafeFace());
    expectInsideCircle(tester);
  });

  // A test for the test. A checker that never fails proves nothing, so we
  // make sure it DOES fail on a face we know is broken.
  testWidgets('the checker catches a clipped face', (tester) async {
    await pumpFace(tester, const ClippedFace());

    expect(
      () => expectInsideCircle(tester),
      throwsA(isA<TestFailure>()),
    );
  });
}
