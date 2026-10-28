import 'package:flutter/material.dart';
import '../models/lifetime_stats.dart';

class HoleAveragesChart extends StatelessWidget {
  final Map<int, HoleStat> holeStats;

  const HoleAveragesChart({super.key, required this.holeStats});

  @override
  Widget build(BuildContext context) {
    if (holeStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedHoles = holeStats.values.toList()
      ..sort((a, b) => a.holeNumber.compareTo(b.holeNumber));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hole-by-Hole Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Avg vs Par',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sortedHoles.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final stat = sortedHoles[index];
                  final avgRel = stat.averageRelativeScore;
                  final isUnderPar = avgRel < 0;
                  final isOverPar = avgRel > 0;
                  final color = isUnderPar
                      ? const Color(0xFF2E7D32)
                      : (isOverPar ? const Color(0xFFE53935) : const Color(0xFF546E7A));

                  final relText = avgRel == 0
                      ? 'E'
                      : (avgRel > 0 ? '+${avgRel.toStringAsFixed(1)}' : avgRel.toStringAsFixed(1));

                  return Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hole ${stat.holeNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Par ${stat.par}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            relText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Best: ${stat.bestStrokes}',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
