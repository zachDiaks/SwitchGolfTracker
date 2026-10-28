import 'package:flutter_test/flutter_test.dart';
import 'package:switch_sports_tracker/models/golf_round.dart';
import 'package:switch_sports_tracker/models/hole_score.dart';
import 'package:switch_sports_tracker/models/lifetime_stats.dart';

void main() {
  group('HoleScore Model Tests', () {
    test('Calculates relative scores and labels correctly', () {
      const birdie = HoleScore(holeNumber: 1, par: 4, strokes: 3);
      expect(birdie.relativeScore, -1);
      expect(birdie.scoreType, ScoreType.birdie);
      expect(birdie.formattedRelative, '-1');
      expect(birdie.scoreLabel, 'Birdie');

      const eagle = HoleScore(holeNumber: 3, par: 5, strokes: 3);
      expect(eagle.relativeScore, -2);
      expect(eagle.scoreType, ScoreType.eagle);
      expect(eagle.formattedRelative, '-2');
      expect(eagle.scoreLabel, 'Eagle');

      const par = HoleScore(holeNumber: 6, par: 4, strokes: 4);
      expect(par.relativeScore, 0);
      expect(par.scoreType, ScoreType.par);
      expect(par.formattedRelative, '±0');
      expect(par.scoreLabel, 'Par');

      const bogey = HoleScore(holeNumber: 16, par: 4, strokes: 5);
      expect(bogey.relativeScore, 1);
      expect(bogey.scoreType, ScoreType.bogey);
      expect(bogey.formattedRelative, '+1');
      expect(bogey.scoreLabel, 'Bogey');

      const ace = HoleScore(holeNumber: 2, par: 3, strokes: 1);
      expect(ace.relativeScore, -2);
      expect(ace.scoreType, ScoreType.holeInOne);
      expect(ace.scoreLabel, 'Hole in One');
    });

    test('Serialization to and from Map', () {
      const original = HoleScore(holeNumber: 12, par: 5, strokes: 3);
      final map = original.toMap();
      final restored = HoleScore.fromMap(map);

      expect(restored.holeNumber, original.holeNumber);
      expect(restored.par, original.par);
      expect(restored.strokes, original.strokes);
    });
  });

  group('GolfRound Model Tests', () {
    test('Calculates totals and score breakdown correctly', () {
      final holes = [
        const HoleScore(holeNumber: 1, par: 4, strokes: 3), // -1
        const HoleScore(holeNumber: 2, par: 3, strokes: 2), // -1
        const HoleScore(holeNumber: 3, par: 5, strokes: 4), // -1
        const HoleScore(holeNumber: 4, par: 4, strokes: 4), // E
        const HoleScore(holeNumber: 5, par: 4, strokes: 5), // +1
      ];

      final round = GolfRound(
        id: 'test-1',
        timestamp: DateTime(2026, 10, 28, 14, 0),
        courseType: 'Custom 5H',
        holes: holes,
      );

      expect(round.totalPar, 20);
      expect(round.totalStrokes, 18);
      expect(round.totalRelativeScore, -2);
      expect(round.formattedRelativeScore, '-2');
      expect(round.birdieCount, 3);
      expect(round.parCount, 1);
      expect(round.bogeyCount, 1);
    });

    test('Serialization to and from Map with JSON holes', () {
      final holes = [
        const HoleScore(holeNumber: 1, par: 4, strokes: 3),
        const HoleScore(holeNumber: 2, par: 3, strokes: 3),
      ];

      final original = GolfRound(
        id: 'round-abc',
        timestamp: DateTime.now(),
        courseType: 'Resort (Holes 1–9)',
        holes: holes,
        notes: 'Great weather',
      );

      final map = original.toMap();
      final restored = GolfRound.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.courseType, original.courseType);
      expect(restored.notes, original.notes);
      expect(restored.holes.length, 2);
      expect(restored.holes.first.holeNumber, 1);
      expect(restored.holes.first.strokes, 3);
    });
  });

  group('LifetimeStats Calculations', () {
    test('Computes lifetime metrics across multiple rounds', () {
      final round1Holes = [
        const HoleScore(holeNumber: 1, par: 4, strokes: 3), // -1
        const HoleScore(holeNumber: 2, par: 3, strokes: 3), // E
        const HoleScore(holeNumber: 3, par: 5, strokes: 4), // -1
      ];
      final round2Holes = [
        const HoleScore(holeNumber: 1, par: 4, strokes: 4), // E
        const HoleScore(holeNumber: 2, par: 3, strokes: 2), // -1
        const HoleScore(holeNumber: 3, par: 5, strokes: 6), // +1
      ];

      final r1 = GolfRound(
        id: '1',
        timestamp: DateTime.now(),
        courseType: '3 Holes',
        holes: round1Holes,
      );
      final r2 = GolfRound(
        id: '2',
        timestamp: DateTime.now(),
        courseType: '3 Holes',
        holes: round2Holes,
      );

      final stats = LifetimeStats.fromRounds([r1, r2]);

      expect(stats.totalRounds, 2);
      expect(stats.totalHoles, 6);
      expect(stats.totalBirdies, 3);
      expect(stats.totalPars, 2);
      expect(stats.totalBogeys, 1);
      expect(stats.bestRoundRelative, -2); // r1 was -2, r2 was 0

      // Check hole 1 stats
      final h1Stat = stats.holeStats[1]!;
      expect(h1Stat.timesPlayed, 2);
      expect(h1Stat.averageStrokes, 3.5);
      expect(h1Stat.bestStrokes, 3);
    });
  });
}
