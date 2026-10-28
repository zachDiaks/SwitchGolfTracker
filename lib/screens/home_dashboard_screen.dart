import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/golf_tracker_provider.dart';
import '../widgets/distribution_chart.dart';
import '../widgets/hole_averages_chart.dart';
import '../widgets/stats_card.dart';
import 'manual_entry_screen.dart';
import 'round_detail_screen.dart';
import 'scan_image_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sports_golf, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text(
              'Switch Golf Tracker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Consumer<GolfTrackerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.lifetimeStats;
          final rounds = provider.rounds;

          return RefreshIndicator(
            onRefresh: () => provider.loadRounds(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      StatsCard(
                        title: 'Total Rounds',
                        value: '${stats.totalRounds}',
                        subtitle: '${stats.totalHoles} holes played',
                        icon: Icons.golf_course,
                        color: const Color(0xFF2E7D32),
                      ),
                      StatsCard(
                        title: 'Avg Score / Round',
                        value: stats.totalRounds > 0
                            ? (stats.averageScoreRelativeToPar == 0
                                ? 'E'
                                : (stats.averageScoreRelativeToPar > 0
                                    ? '+${stats.averageScoreRelativeToPar.toStringAsFixed(1)}'
                                    : stats.averageScoreRelativeToPar.toStringAsFixed(1)))
                            : '--',
                        subtitle: 'vs Par',
                        icon: Icons.trending_up,
                        color: const Color(0xFF00ACC1),
                      ),
                      StatsCard(
                        title: 'Best Round',
                        value: stats.bestRoundRelative != null
                            ? (stats.bestRoundRelative == 0
                                ? 'E'
                                : (stats.bestRoundRelative! > 0
                                    ? '+${stats.bestRoundRelative}'
                                    : '${stats.bestRoundRelative}'))
                            : '--',
                        subtitle: 'Personal Best',
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xFFFFB300),
                      ),
                      StatsCard(
                        title: 'Total Birdies+',
                        value: '${stats.totalBirdies + stats.totalEagles + stats.totalAlbatross}',
                        subtitle: 'Under par holes',
                        icon: Icons.flight_takeoff,
                        color: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Scoring Distribution
                  if (stats.totalHoles > 0) ...[
                    DistributionChart(stats: stats),
                    const SizedBox(height: 20),
                  ],

                  // Hole by Hole Averages
                  if (stats.holeStats.isNotEmpty) ...[
                    HoleAveragesChart(holeStats: stats.holeStats),
                    const SizedBox(height: 20),
                  ],

                  // Recent Rounds Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Rounds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${rounds.length} Total',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (rounds.isEmpty) ...[
                    Card(
                      elevation: 0,
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.sports_golf, size: 54, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              const Text(
                                'No rounds recorded yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Scan a post-game scorecard photo or enter scores manually.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rounds.length,
                      itemBuilder: (context, index) {
                        final round = rounds[index];
                        final dateStr = DateFormat('MMM d, y • h:mm a').format(round.timestamp);
                        final rel = round.totalRelativeScore;
                        final relStr = round.formattedRelativeScore;
                        final isUnderPar = rel < 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isUnderPar
                                    ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                                    : (rel == 0 ? Colors.grey[200] : Colors.red[50]),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                relStr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: isUnderPar
                                      ? const Color(0xFF2E7D32)
                                      : (rel == 0 ? Colors.grey[800] : Colors.red[800]),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              round.courseType,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('$dateStr • ${round.totalStrokes} strokes (${round.holeCount}H)'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RoundDetailScreen(round: round),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'manual_entry_fab',
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2E7D32),
            tooltip: 'Manual Entry',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
              );
            },
            child: const Icon(Icons.edit_note_rounded),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'scan_fab',
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Scan Scorecard', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScanImageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
