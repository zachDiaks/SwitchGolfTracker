class CourseDefinition {
  final String name;
  final List<int> holeNumbers;
  final Map<int, int> parMap;

  const CourseDefinition({
    required this.name,
    required this.holeNumbers,
    required this.parMap,
  });

  int get totalPar => holeNumbers.fold(0, (sum, h) => sum + (parMap[h] ?? 4));
}

class CourseCatalog {
  // Official standard pars in Nintendo Switch Sports Golf:
  // Resort Course: Holes 1 to 9 (Total Par 36)
  static const Map<int, int> resortPars = {
    1: 4,
    2: 3,
    3: 5,
    4: 3,
    5: 5,
    6: 4,
    7: 4,
    8: 3,
    9: 5,
  };

  // Classic Course: Holes 10 to 18 (Total Par 36)
  static const Map<int, int> classicPars = {
    10: 4,
    11: 3,
    12: 5,
    13: 3,
    14: 5,
    15: 4,
    16: 4,
    17: 3,
    18: 5,
  };

  // Special Course: Holes 19 to 21
  static const Map<int, int> specialPars = {
    19: 3,
    20: 4,
    21: 5,
  };

  static final Map<int, int> allKnownPars = {
    ...resortPars,
    ...classicPars,
    ...specialPars,
  };

  static int getExpectedPar(int holeNumber) {
    return allKnownPars[holeNumber] ?? 4;
  }

  static String guessCourseType(List<int> holeNumbers) {
    if (holeNumbers.isEmpty) return 'Custom';
    final sorted = List<int>.from(holeNumbers)..sort();
    final first = sorted.first;
    final last = sorted.last;
    final count = sorted.length;

    if (count == 18 && first == 1 && last == 18) {
      return '18 Holes (Resort + Classic)';
    }
    if (count == 9 && first == 1 && last == 9) {
      return 'Resort (Holes 1–9)';
    }
    if (count == 9 && first == 10 && last == 18) {
      return 'Classic (Holes 10–18)';
    }
    if (count == 3) {
      return '3 Holes (Holes $first–$last)';
    }
    if (last <= 9) {
      return 'Resort (${count}H)';
    }
    if (first >= 10 && last <= 18) {
      return 'Classic (${count}H)';
    }
    return '$count-Hole Round';
  }
}
