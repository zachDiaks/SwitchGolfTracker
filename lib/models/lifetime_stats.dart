import 'golf_round.dart';
import 'hole_score.dart';

class HoleStat {
  final int holeNumber;
  final int timesPlayed;
  final int par;
  final double averageStrokes;
  final double averageRelativeScore;
  final int bestStrokes;

  HoleStat({
    required this.holeNumber,
    required this.timesPlayed,
    required this.par,
    required this.averageStrokes,
    required this.averageRelativeScore,
    required this.bestStrokes,
  });
}

class LifetimeStats {
  final int totalRounds;
  final int totalHoles;
  final double averageScoreRelativeToPar; // per round (for standard rounds) or per 9-hole equivalent
  final double averageScorePerHole;
  final int? bestRoundRelative;
  final int? best18HoleRelative;
  final int? best9HoleRelative;
  final int totalAlbatross;
  final int totalEagles;
  final int totalBirdies;
  final int totalPars;
  final int totalBogeys;
  final int totalDoubleBogeysOrWorse;
  final Map<int, HoleStat> holeStats;

  const LifetimeStats({
    required this.totalRounds,
    required this.totalHoles,
    required this.averageScoreRelativeToPar,
    required this.averageScorePerHole,
    this.bestRoundRelative,
    this.best18HoleRelative,
    this.best9HoleRelative,
    required this.totalAlbatross,
    required this.totalEagles,
    required this.totalBirdies,
    required this.totalPars,
    required this.totalBogeys,
    required this.totalDoubleBogeysOrWorse,
    required this.holeStats,
  });

  factory LifetimeStats.empty() {
    return const LifetimeStats(
      totalRounds: 0,
      totalHoles: 0,
      averageScoreRelativeToPar: 0.0,
      averageScorePerHole: 0.0,
      bestRoundRelative: null,
      best18HoleRelative: null,
      best9HoleRelative: null,
      totalAlbatross: 0,
      totalEagles: 0,
      totalBirdies: 0,
      totalPars: 0,
      totalBogeys: 0,
      totalDoubleBogeysOrWorse: 0,
      holeStats: {},
    );
  }

  factory LifetimeStats.fromRounds(List<GolfRound> rounds) {
    if (rounds.isEmpty) return LifetimeStats.empty();

    int totalHoles = 0;
    int sumRelative = 0;
    int albatross = 0;
    int eagles = 0;
    int birdies = 0;
    int pars = 0;
    int bogeys = 0;
    int doubleOrWorse = 0;

    int? bestOverall;
    int? best18;
    int? best9;

    // Per hole data: holeNumber -> list of HoleScore
    final Map<int, List<HoleScore>> holeHistory = {};

    for (final r in rounds) {
      final roundRel = r.totalRelativeScore;
      if (bestOverall == null || roundRel < bestOverall) {
        bestOverall = roundRel;
      }
      if (r.holeCount == 18) {
        if (best18 == null || roundRel < best18) {
          best18 = roundRel;
        }
      } else if (r.holeCount == 9) {
        if (best9 == null || roundRel < best9) {
          best9 = roundRel;
        }
      }

      totalHoles += r.holeCount;
      sumRelative += roundRel;

      albatross += r.albatrossCount;
      eagles += r.eagleCount;
      birdies += r.birdieCount;
      pars += r.parCount;
      bogeys += r.bogeyCount;
      doubleOrWorse += r.doubleBogeyOrWorseCount;

      for (final h in r.holes) {
        holeHistory.putIfAbsent(h.holeNumber, () => []).add(h);
      }
    }

    final double avgPerHole = totalHoles > 0 ? (sumRelative / totalHoles) : 0.0;
    final double avgPerRound = rounds.isNotEmpty ? (sumRelative / rounds.length) : 0.0;

    final Map<int, HoleStat> statsByHole = {};
    final sortedHoles = holeHistory.keys.toList()..sort();
    for (final hNum in sortedHoles) {
      final list = holeHistory[hNum]!;
      final count = list.length;
      final par = list.first.par;
      final totalStrokes = list.fold(0, (sum, s) => sum + s.strokes);
      final totalHoleRel = list.fold(0, (sum, s) => sum + s.relativeScore);
      final best = list.fold<int>(999, (min, s) => s.strokes < min ? s.strokes : min);

      statsByHole[hNum] = HoleStat(
        holeNumber: hNum,
        timesPlayed: count,
        par: par,
        averageStrokes: count > 0 ? totalStrokes / count : par.toDouble(),
        averageRelativeScore: count > 0 ? totalHoleRel / count : 0.0,
        bestStrokes: best == 999 ? par : best,
      );
    }

    return LifetimeStats(
      totalRounds: rounds.length,
      totalHoles: totalHoles,
      averageScoreRelativeToPar: avgPerRound,
      averageScorePerHole: avgPerHole,
      bestRoundRelative: bestOverall,
      best18HoleRelative: best18,
      best9HoleRelative: best9,
      totalAlbatross: albatross,
      totalEagles: eagles,
      totalBirdies: birdies,
      totalPars: pars,
      totalBogeys: bogeys,
      totalDoubleBogeysOrWorse: doubleOrWorse,
      holeStats: statsByHole,
    );
  }
}
