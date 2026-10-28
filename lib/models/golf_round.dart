import 'dart:convert';
import 'hole_score.dart';

class GolfRound {
  final String id;
  final DateTime timestamp;
  final String courseType;
  final List<HoleScore> holes;
  final String? notes;

  const GolfRound({
    required this.id,
    required this.timestamp,
    required this.courseType,
    required this.holes,
    this.notes,
  });

  int get totalStrokes => holes.fold(0, (sum, h) => sum + h.strokes);
  int get totalPar => holes.fold(0, (sum, h) => sum + h.par);
  int get totalRelativeScore => totalStrokes - totalPar;

  String get formattedRelativeScore {
    final diff = totalRelativeScore;
    if (diff == 0) return 'E';
    if (diff > 0) return '+$diff';
    return '$diff';
  }

  int get holeCount => holes.length;

  int countScoreType(ScoreType type) {
    return holes.where((h) => h.scoreType == type).length;
  }

  int get albatrossCount =>
      holes.where((h) => h.scoreType == ScoreType.albatross).length;
  int get eagleCount =>
      holes.where((h) => h.scoreType == ScoreType.eagle).length;
  int get birdieCount =>
      holes.where((h) => h.scoreType == ScoreType.birdie).length;
  int get parCount =>
      holes.where((h) => h.scoreType == ScoreType.par).length;
  int get bogeyCount =>
      holes.where((h) => h.scoreType == ScoreType.bogey).length;
  int get doubleBogeyOrWorseCount => holes
      .where((h) =>
          h.scoreType == ScoreType.doubleBogey ||
          h.scoreType == ScoreType.worse)
      .length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'courseType': courseType,
      'notes': notes,
      'holesJson': jsonEncode(holes.map((h) => h.toMap()).toList()),
    };
  }

  factory GolfRound.fromMap(Map<String, dynamic> map) {
    final holesRaw = map['holesJson'] as String? ?? '[]';
    final decodedList = jsonDecode(holesRaw) as List<dynamic>;
    final holes = decodedList
        .map((item) => HoleScore.fromMap(item as Map<String, dynamic>))
        .toList();

    return GolfRound(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      courseType: map['courseType'] as String? ?? 'General',
      holes: holes,
      notes: map['notes'] as String?,
    );
  }

  GolfRound copyWith({
    String? id,
    DateTime? timestamp,
    String? courseType,
    List<HoleScore>? holes,
    String? notes,
  }) {
    return GolfRound(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      courseType: courseType ?? this.courseType,
      holes: holes ?? this.holes,
      notes: notes ?? this.notes,
    );
  }
}
