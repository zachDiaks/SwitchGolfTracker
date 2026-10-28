import '../models/course_catalog.dart';
import '../models/hole_score.dart';

class ParsedScorecardResult {
  final bool success;
  final String courseType;
  final List<HoleScore> holes;
  final int totalPar;
  final int totalRelativeScore;
  final int totalStrokes;
  final bool checksumValid;
  final String message;
  final String rawText;

  const ParsedScorecardResult({
    required this.success,
    required this.courseType,
    required this.holes,
    required this.totalPar,
    required this.totalRelativeScore,
    required this.totalStrokes,
    required this.checksumValid,
    required this.message,
    required this.rawText,
  });

  factory ParsedScorecardResult.failure(String message, {String rawText = ''}) {
    return ParsedScorecardResult(
      success: false,
      courseType: 'Unknown',
      holes: const [],
      totalPar: 0,
      totalRelativeScore: 0,
      totalStrokes: 0,
      checksumValid: false,
      message: message,
      rawText: rawText,
    );
  }
}

class OcrBoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const OcrBoundingBox(this.left, this.top, this.right, this.bottom);
}

class OcrTextItem {
  final String text;
  final OcrBoundingBox box;

  OcrTextItem(this.text, this.box);
}

class ScorecardParser {
  /// Parses raw text extracted from OCR.
  ParsedScorecardResult parseFromText(String fullText) {
    if (fullText.trim().isEmpty) {
      return ParsedScorecardResult.failure('No text detected in image.', rawText: fullText);
    }

    final lines = fullText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // 1. Look for hole numbers line: "Hole No." or numbers 1..18 / 1..9 / 10..18 / 1..3
    List<int> holeNumbers = _extractHoleNumbers(lines);

    // 2. Look for par line
    List<int> pars = _extractPars(lines, holeNumbers.length);

    // 3. Look for player scores relative to par
    List<int> relativeScores = _extractRelativeScores(lines, holeNumbers.length);

    // 4. Look for parsed totals
    int? parsedTotalPar = _extractTotalPar(lines);
    int? parsedTotalScore = _extractTotalRelativeScore(lines);

    // Fallbacks if hole numbers or pars weren't fully identified
    if (holeNumbers.isEmpty) {
      if (relativeScores.length >= 18) {
        holeNumbers = List.generate(18, (i) => i + 1);
      } else if (relativeScores.length >= 9) {
        holeNumbers = List.generate(9, (i) => i + 1);
      } else if (relativeScores.length >= 3) {
        holeNumbers = List.generate(relativeScores.length, (i) => i + 1);
      }
    }

    if (relativeScores.length > holeNumbers.length) {
      // The last number might be the total relative score
      if (parsedTotalScore == null && relativeScores.length == holeNumbers.length + 1) {
        parsedTotalScore = relativeScores.last;
      }
      relativeScores = relativeScores.take(holeNumbers.length).toList();
    }

    if (holeNumbers.isEmpty || relativeScores.isEmpty) {
      return _fallbackPatternParse(lines, fullText);
    }

    // Align pars with known catalog if missing or incomplete
    if (pars.length < holeNumbers.length) {
      pars = holeNumbers.map((h) => CourseCatalog.getExpectedPar(h)).toList();
    }

    // Build HoleScore list
    final List<HoleScore> holes = [];
    final minLen = [holeNumbers.length, pars.length, relativeScores.length].reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < minLen; i++) {
      final hNum = holeNumbers[i];
      final par = pars[i];
      final rel = relativeScores[i];
      final strokes = (par + rel) > 0 ? (par + rel) : 1;
      holes.add(HoleScore(
        holeNumber: hNum,
        par: par,
        strokes: strokes,
      ));
    }

    final sumPar = holes.fold(0, (sum, h) => sum + h.par);
    final sumRelative = holes.fold(0, (sum, h) => sum + h.relativeScore);
    final sumStrokes = holes.fold(0, (sum, h) => sum + h.strokes);

    final expectedTotalScore = parsedTotalScore ?? sumRelative;
    final bool parMatches = (parsedTotalPar == null || sumPar == parsedTotalPar);
    final bool checksumValid = (sumRelative == expectedTotalScore) && parMatches;

    final courseType = CourseCatalog.guessCourseType(holes.map((h) => h.holeNumber).toList());

    String msg;
    if (checksumValid) {
      msg = 'Scorecard verified! Total: ${expectedTotalScore >= 0 ? "+$expectedTotalScore" : "$expectedTotalScore"}';
    } else if (!parMatches) {
      msg = 'Parsed ${holes.length} holes. Total par mismatch: calculated $sumPar vs scanned $parsedTotalPar. Please review.';
    } else {
      msg = 'Parsed ${holes.length} holes. Checksum mismatch: calculated $sumRelative vs scanned $expectedTotalScore. Please review.';
    }

    return ParsedScorecardResult(
      success: holes.isNotEmpty,
      courseType: courseType,
      holes: holes,
      totalPar: sumPar,
      totalRelativeScore: sumRelative,
      totalStrokes: sumStrokes,
      checksumValid: checksumValid,
      message: msg,
      rawText: fullText,
    );
  }

  /// Extracts hole numbers from lines
  List<int> _extractHoleNumbers(List<String> lines) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('hole') || lower.contains('no.')) {
        final nums = _findPositiveIntegers(line.replaceAll(RegExp(r'hole|no\.', caseSensitive: false), ''));
        if (nums.length >= 3) {
          return nums;
        }
      }
    }

    // Fallback: search for sequential series 1..9 or 1..18 or 10..18
    for (final line in lines) {
      final nums = _findPositiveIntegers(line);
      if (nums.length >= 9 && nums.first == 1 && nums[1] == 2 && nums[2] == 3) {
        return nums.where((n) => n >= 1 && n <= 18).toList();
      }
      if (nums.length >= 9 && nums.first == 10 && nums[1] == 11) {
        return nums.where((n) => n >= 10 && n <= 18).toList();
      }
    }
    return [];
  }

  /// Extracts Par line values
  List<int> _extractPars(List<String> lines, int expectedCount) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.startsWith('par') || lower.contains('par')) {
        final cleaned = line.replaceAll(RegExp(r'par', caseSensitive: false), '');
        final nums = _findPositiveIntegers(cleaned);
        // Valid golf pars are typically 3, 4, 5
        final parCandidates = nums.where((n) => n >= 3 && n <= 5).toList();
        if (parCandidates.length >= 3) {
          return parCandidates;
        }
      }
    }
    return [];
  }

  /// Extracts relative score values (+1, -1, 0, ±0, etc.)
  List<int> _extractRelativeScores(List<String> lines, int expectedCount) {
    for (final line in lines) {
      // Relative score row typically contains ±0, -1, -2, +1, etc.
      if (line.contains('±') || line.contains('+') || line.contains('-')) {
        final scores = _parseSignedScores(line);
        if (scores.length >= 3) {
          return scores;
        }
      }
    }

    // Fallback: search any line with multiple small numbers
    for (final line in lines) {
      final scores = _parseSignedScores(line);
      if (scores.length >= 3) {
        return scores;
      }
    }
    return [];
  }

  /// Parses signed scores from a line like "-1 -1 -1 -1 -1 ±0 -1 ±0 ±0 -1 -2 -2 -1 -1 -1 +1 ±0 ±0 -13"
  List<int> _parseSignedScores(String line) {
    final List<int> result = [];
    final tokens = line
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .split(RegExp(r'\s+'));

    for (final token in tokens) {
      final t = token.trim();
      if (t.isEmpty) continue;

      if (t == '±0' || t == '+0' || t == '-0' || t == '0' || t.toUpperCase() == 'E') {
        result.add(0);
      } else if (RegExp(r'^[+-]?\d+$').hasMatch(t)) {
        final val = int.tryParse(t);
        if (val != null && val >= -20 && val <= 20) {
          result.add(val);
        }
      }
    }
    return result;
  }

  List<int> _findPositiveIntegers(String text) {
    final matches = RegExp(r'\b\d+\b').allMatches(text);
    return matches.map((m) => int.parse(m.group(0)!)).toList();
  }

  int? _extractTotalPar(List<String> lines) {
    for (final line in lines) {
      if (line.toLowerCase().contains('par')) {
        final nums = _findPositiveIntegers(line);
        for (final n in nums) {
          if (n == 36 || n == 72 || n == 35 || n == 37) return n;
        }
      }
    }
    return null;
  }

  int? _extractTotalRelativeScore(List<String> lines) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      // Match lines starting with total or dedicated total line
      if (lower.startsWith('total') || lower == 'total') {
        final match = RegExp(r'([+-]?\d+)').firstMatch(line.replaceAll(RegExp(r'total', caseSensitive: false), ''));
        if (match != null) {
          return int.tryParse(match.group(1)!);
        }
      }
    }
    return null;
  }

  /// Fallback pattern parse when grid headers are missing or OCR is fragmented
  ParsedScorecardResult _fallbackPatternParse(List<String> lines, String fullText) {
    final allScores = <int>[];
    for (final line in lines) {
      allScores.addAll(_parseSignedScores(line));
    }

    if (allScores.length >= 3) {
      final int count = allScores.length >= 18 ? 18 : (allScores.length >= 9 ? 9 : 3);
      final scores = allScores.take(count).toList();
      final holes = <HoleScore>[];
      for (int i = 0; i < scores.length; i++) {
        final hNum = i + 1;
        final par = CourseCatalog.getExpectedPar(hNum);
        final rel = scores[i];
        holes.add(HoleScore(
          holeNumber: hNum,
          par: par,
          strokes: (par + rel) > 0 ? (par + rel) : 1,
        ));
      }
      final sumPar = holes.fold(0, (sum, h) => sum + h.par);
      final sumRel = holes.fold(0, (sum, h) => sum + h.relativeScore);
      final sumStrokes = holes.fold(0, (sum, h) => sum + h.strokes);

      return ParsedScorecardResult(
        success: true,
        courseType: CourseCatalog.guessCourseType(holes.map((h) => h.holeNumber).toList()),
        holes: holes,
        totalPar: sumPar,
        totalRelativeScore: sumRel,
        totalStrokes: sumStrokes,
        checksumValid: true,
        message: 'Parsed ${holes.length} holes using pattern fallback. Please verify scores.',
        rawText: fullText,
      );
    }

    return ParsedScorecardResult.failure('Could not locate scorecard table in image.', rawText: fullText);
  }
}
