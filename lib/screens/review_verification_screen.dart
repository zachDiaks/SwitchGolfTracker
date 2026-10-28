import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/golf_round.dart';
import '../models/hole_score.dart';
import '../providers/golf_tracker_provider.dart';
import '../services/scorecard_parser.dart';
import '../widgets/score_badge.dart';

class ReviewVerificationScreen extends StatefulWidget {
  final ParsedScorecardResult? initialParsedResult;
  final List<HoleScore>? initialHoles;
  final String? initialCourseType;

  const ReviewVerificationScreen({
    super.key,
    this.initialParsedResult,
    this.initialHoles,
    this.initialCourseType,
  });

  @override
  State<ReviewVerificationScreen> createState() => _ReviewVerificationScreenState();
}

class _ReviewVerificationScreenState extends State<ReviewVerificationScreen> {
  late String _courseType;
  late List<HoleScore> _holes;
  final TextEditingController _notesController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.initialParsedResult != null) {
      _courseType = widget.initialParsedResult!.courseType;
      _holes = List.from(widget.initialParsedResult!.holes);
    } else {
      _courseType = widget.initialCourseType ?? '18 Holes (Resort + Classic)';
      _holes = List.from(widget.initialHoles ?? []);
    }

    if (_holes.isEmpty) {
      // Default to standard 18 holes
      _holes = List.generate(
        18,
        (i) => HoleScore(
          holeNumber: i + 1,
          par: (i == 1 || i == 3 || i == 7 || i == 10 || i == 12 || i == 16)
              ? 3
              : (i == 2 || i == 4 || i == 8 || i == 11 || i == 13 || i == 17)
                  ? 5
                  : 4,
          strokes: 4,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _totalPar => _holes.fold(0, (sum, h) => sum + h.par);
  int get _totalStrokes => _holes.fold(0, (sum, h) => sum + h.strokes);
  int get _totalRelative => _totalStrokes - _totalPar;

  void _updateStrokes(int index, int delta) {
    setState(() {
      final current = _holes[index];
      final newStrokes = (current.strokes + delta).clamp(1, 20);
      _holes[index] = current.copyWith(strokes: newStrokes);
    });
  }

  void _updatePar(int index, int delta) {
    setState(() {
      final current = _holes[index];
      final newPar = (current.par + delta).clamp(3, 6);
      _holes[index] = current.copyWith(par: newPar);
    });
  }

  Future<void> _saveRound() async {
    final round = GolfRound(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      courseType: _courseType,
      holes: _holes,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final provider = Provider.of<GolfTrackerProvider>(context, listen: false);
    await provider.addRound(round);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Round successfully saved to history!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = widget.initialParsedResult;
    final relStr = _totalRelative == 0
        ? 'E'
        : (_totalRelative > 0 ? '+$_totalRelative' : '$_totalRelative');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Scorecard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Round',
            onPressed: _saveRound,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status or OCR Verification Banner
            if (parsed != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: parsed.checksumValid
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: parsed.checksumValid
                        ? const Color(0xFF81C784)
                        : const Color(0xFFFFB74D),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      parsed.checksumValid ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: parsed.checksumValid
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF57C00),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        parsed.message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: parsed.checksumValid
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Course Type',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _courseType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _totalRelative <= 0
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            relStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Holes', '${_holes.length}'),
                        _buildStat('Par', '$_totalPar'),
                        _buildStat('Strokes', '$_totalStrokes'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Hole-by-Hole Scores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + or - to adjust any strokes or pars before saving.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Editable Holes List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _holes.length,
              itemBuilder: (context, index) {
                final hole = _holes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueGrey[800],
                          child: Text(
                            '${hole.holeNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Par controls
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Par',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${hole.par}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 14),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                  onPressed: () => _updatePar(index, -1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 14),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                  onPressed: () => _updatePar(index, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Strokes controls
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Strokes',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () => _updateStrokes(index, -1),
                                ),
                                Text(
                                  '${hole.strokes}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                  onPressed: () => _updateStrokes(index, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Badge
                        ScoreBadge(holeScore: hole, compact: false),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Notes Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. Played with friends, personal best round',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.note_alt_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Confirm & Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Confirm & Save Round',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saveRound,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
