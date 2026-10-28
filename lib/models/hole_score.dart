enum ScoreType {
  holeInOne,
  albatross,
  eagle,
  birdie,
  par,
  bogey,
  doubleBogey,
  worse,
}

class HoleScore {
  final int holeNumber;
  final int par;
  final int strokes;

  const HoleScore({
    required this.holeNumber,
    required this.par,
    required this.strokes,
  });

  int get relativeScore => strokes - par;

  ScoreType get scoreType {
    if (strokes == 1 && par > 1) return ScoreType.holeInOne;
    final diff = strokes - par;
    if (diff <= -3) return ScoreType.albatross;
    if (diff == -2) return ScoreType.eagle;
    if (diff == -1) return ScoreType.birdie;
    if (diff == 0) return ScoreType.par;
    if (diff == 1) return ScoreType.bogey;
    if (diff == 2) return ScoreType.doubleBogey;
    return ScoreType.worse;
  }

  String get scoreLabel {
    if (strokes == 1 && par > 1) return 'Hole in One';
    final diff = strokes - par;
    if (diff <= -3) return 'Albatross';
    if (diff == -2) return 'Eagle';
    if (diff == -1) return 'Birdie';
    if (diff == 0) return 'Par';
    if (diff == 1) return 'Bogey';
    if (diff == 2) return 'Double Bogey';
    return '+$diff';
  }

  String get formattedRelative {
    final diff = strokes - par;
    if (diff == 0) return '±0';
    if (diff > 0) return '+$diff';
    return '$diff';
  }

  Map<String, dynamic> toMap() {
    return {
      'holeNumber': holeNumber,
      'par': par,
      'strokes': strokes,
    };
  }

  factory HoleScore.fromMap(Map<String, dynamic> map) {
    return HoleScore(
      holeNumber: map['holeNumber'] as int,
      par: map['par'] as int,
      strokes: map['strokes'] as int,
    );
  }

  HoleScore copyWith({
    int? holeNumber,
    int? par,
    int? strokes,
  }) {
    return HoleScore(
      holeNumber: holeNumber ?? this.holeNumber,
      par: par ?? this.par,
      strokes: strokes ?? this.strokes,
    );
  }
}
