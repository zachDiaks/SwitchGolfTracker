import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'scorecard_parser.dart';

class OcrService {
  final ScorecardParser _parser = ScorecardParser();

  Future<ParsedScorecardResult> processImage(File imageFile) async {
    try {
      // If running on Android or iOS where ML Kit has native platform support
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final inputImage = InputImage.fromFile(imageFile);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

        try {
          final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
          final fullText = recognizedText.text;

          // Parse results using our parser
          final result = _parser.parseFromText(fullText);
          return result;
        } finally {
          await textRecognizer.close();
        }
      } else {
        // Desktop / Mock environment:
        // We can read file metadata or parse text if provided or return fallback
        return _fallbackForDesktop(imageFile);
      }
    } catch (e) {
      return ParsedScorecardResult.failure('OCR Processing failed: $e');
    }
  }

  ParsedScorecardResult _fallbackForDesktop(File imageFile) {
    // For testing and simulation on Linux desktop, provide simulated 18-hole parse
    // matching standard Switch Sports results
    const simulatedText = '''
Hole No. 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 Total
Par 4 3 5 3 5 4 4 3 5 4 3 5 3 5 4 4 3 5 72
Player -1 -1 -1 -1 -1 ±0 -1 ±0 ±0 -1 -2 -2 -1 -1 -1 +1 ±0 ±0 -13
Total -13
''';
    return _parser.parseFromText(simulatedText);
  }
}
