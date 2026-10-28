import 'package:flutter/material.dart';
import '../models/hole_score.dart';

class ScoreBadge extends StatelessWidget {
  final HoleScore holeScore;
  final bool compact;

  const ScoreBadge({
    super.key,
    required this.holeScore,
    this.compact = false,
  });

  static Color getScoreColor(HoleScore score) {
    switch (score.scoreType) {
      case ScoreType.holeInOne:
        return const Color(0xFFFFD700); // Gold
      case ScoreType.albatross:
        return const Color(0xFF9C27B0); // Purple
      case ScoreType.eagle:
        return const Color(0xFF00ACC1); // Darker Cyan for readability
      case ScoreType.birdie:
        return const Color(0xFF2E7D32); // Darker Green for readability
      case ScoreType.par:
        return const Color(0xFF546E7A); // Slate gray
      case ScoreType.bogey:
        return const Color(0xFFE53935); // Coral red
      case ScoreType.doubleBogey:
        return const Color(0xFFC62828); // Deep red
      case ScoreType.worse:
        return const Color(0xFF880E4F); // Dark maroon
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getScoreColor(holeScore);
    final relativeStr = holeScore.formattedRelative;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Text(
          relativeStr,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            relativeStr,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          Text(
            holeScore.scoreLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
