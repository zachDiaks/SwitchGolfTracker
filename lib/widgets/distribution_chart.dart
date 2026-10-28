import 'package:flutter/material.dart';
import '../models/lifetime_stats.dart';

class DistributionChart extends StatelessWidget {
  final LifetimeStats stats;

  const DistributionChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalHoles;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final items = [
      _DistItem('Albatross (-3)', stats.totalAlbatross, const Color(0xFF9C27B0)),
      _DistItem('Eagle (-2)', stats.totalEagles, const Color(0xFF00ACC1)),
      _DistItem('Birdie (-1)', stats.totalBirdies, const Color(0xFF2E7D32)),
      _DistItem('Par (E)', stats.totalPars, const Color(0xFF546E7A)),
      _DistItem('Bogey (+1)', stats.totalBogeys, const Color(0xFFE53935)),
      _DistItem('Double Bogey+ (+2+)', stats.totalDoubleBogeysOrWorse, const Color(0xFFC62828)),
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scoring Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$total Holes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...items.map((item) {
              final pct = total > 0 ? (item.count / total) : 0.0;
              final pctStr = (pct * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: item.color,
                          ),
                        ),
                        Text(
                          '${item.count} ($pctStr%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: item.color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DistItem {
  final String label;
  final int count;
  final Color color;

  _DistItem(this.label, this.count, this.color);
}
