import 'package:flutter_test/flutter_test.dart';
import 'package:switch_sports_tracker/services/scorecard_parser.dart';

void main() {
  late ScorecardParser parser;

  setUp(() {
    parser = ScorecardParser();
  });

  group('ScorecardParser Tests', () {
    test('Parses full 18-hole Switch Sports scorecard text (from golfExample.jpg)', () {
      // Exact representation of the scorecard from golfExample.jpg
      const ocrOutput = '''
Hole No. 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 Total
Par 4 3 5 3 5 4 4 3 5 4 3 5 3 5 4 4 3 5 72
-1 -1 -1 -1 -1 ±0 -1 ±0 ±0 -1 -2 -2 -1 -1 -1 +1 ±0 ±0 -13
Total -13
''';

      final result = parser.parseFromText(ocrOutput);

      expect(result.success, isTrue);
      expect(result.holes.length, 18);
      expect(result.totalPar, 72);
      expect(result.totalRelativeScore, -13);
      expect(result.totalStrokes, 59); // 72 - 13
      expect(result.checksumValid, isTrue);
      expect(result.courseType, '18 Holes (Resort + Classic)');

      // Verify specific holes
      expect(result.holes[0].holeNumber, 1);
      expect(result.holes[0].par, 4);
      expect(result.holes[0].strokes, 3); // -1

      expect(result.holes[5].holeNumber, 6);
      expect(result.holes[5].par, 4);
      expect(result.holes[5].strokes, 4); // ±0

      expect(result.holes[10].holeNumber, 11);
      expect(result.holes[10].par, 3);
      expect(result.holes[10].strokes, 1); // -2 (Ace!)

      expect(result.holes[15].holeNumber, 16);
      expect(result.holes[15].par, 4);
      expect(result.holes[15].strokes, 5); // +1 (Bogey)
    });

    test('Parses 9-hole Resort scorecard', () {
      const ocrOutput = '''
Hole No. 1 2 3 4 5 6 7 8 9 Total
Par 4 3 5 3 5 4 4 3 5 36
-1 ±0 -1 -1 ±0 ±0 +1 -1 ±0 -3
Total -3
''';

      final result = parser.parseFromText(ocrOutput);

      expect(result.success, isTrue);
      expect(result.holes.length, 9);
      expect(result.totalPar, 36);
      expect(result.totalRelativeScore, -3);
      expect(result.totalStrokes, 33);
      expect(result.checksumValid, isTrue);
      expect(result.courseType, 'Resort (Holes 1–9)');
    });

    test('Parses 3-hole scorecard', () {
      const ocrOutput = '''
Hole No. 1 2 3 Total
Par 4 3 5 12
-1 ±0 -1 -2
Total -2
''';

      final result = parser.parseFromText(ocrOutput);

      expect(result.success, isTrue);
      expect(result.holes.length, 3);
      expect(result.totalPar, 12);
      expect(result.totalRelativeScore, -2);
      expect(result.totalStrokes, 10);
      expect(result.checksumValid, isTrue);
      expect(result.courseType, '3 Holes (Holes 1–3)');
    });

    test('Handles fallback when header words are slightly garbled', () {
      const ocrOutput = '''
-1 -1 -1 -1 -1 0 -1 0 0 -1 -2 -2 -1 -1 -1 +1 0 0
''';

      final result = parser.parseFromText(ocrOutput);

      expect(result.success, isTrue);
      expect(result.holes.length, 18);
      expect(result.totalRelativeScore, -13);
      expect(result.totalPar, 72);
      expect(result.totalStrokes, 59);
    });
  });
}
