import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:switch_sports_tracker/widgets/score_badge.dart';
import 'package:switch_sports_tracker/models/hole_score.dart';

void main() {
  testWidgets('ScoreBadge widget test', (WidgetTester tester) async {
    const hole = HoleScore(holeNumber: 1, par: 4, strokes: 3);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ScoreBadge(holeScore: hole),
      ),
    );

    expect(find.text('-1'), findsOneWidget);
    expect(find.text('Birdie'), findsOneWidget);
  });
}
