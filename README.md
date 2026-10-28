# Nintendo Switch Sports Golf Tracker ⛳

A specialized Android and cross-platform mobile application built with Flutter to scan, track, and analyze your lifetime Nintendo Switch Sports Golf performance.

## Key Features

1. **On-Device OCR Scorecard Recognition:**
   - Powered by Google ML Kit Text Recognition (`google_mlkit_text_recognition`).
   - 100% offline and free — no cloud servers, subscriptions, or API keys needed.
   - Accurately detects and maps hole numbers, par values, and player scores (`-1`, `±0`, `+1`, `-2`, etc.) directly from TV photos or screenshots.

2. **Smart Grid Parser & Validation:**
   - Built-in Nintendo Switch Sports course catalog (Resort Holes 1–9, Classic Holes 10–18, 18-Hole rounds, and Special Holes 19–21).
   - Checksum consistency validation (`Total Strokes = Par + Relative Score`, sum of scores matches parsed Total).

3. **Review & Verification UI:**
   - Editable score table before saving.
   - Stepper controls (`+` / `-`) for quick adjustments to pars and strokes.
   - Real-time score badges (Albatross, Eagle, Birdie, Par, Bogey, Double Bogey+).

4. **Persistent Local Database ("Memory"):**
   - SQLite storage using `sqflite` (with `sqflite_common_ffi` support).
   - Stores full round history and hole-by-hole records locally on the device.

5. **Lifetime Statistics Dashboard:**
   - Total rounds and holes played.
   - Overall average score relative to par.
   - Personal best round tracking (18-hole and 9-hole).
   - Scoring distribution breakdown with visual progress meters.
   - Hole-by-hole historical performance and averages to identify your best and toughest holes.

---

## Architecture

```
lib/
├── models/
│   ├── hole_score.dart          # HoleScore, ScoreType, formatting
│   ├── golf_round.dart          # GolfRound, JSON serialization
│   ├── lifetime_stats.dart      # Lifetime stats aggregations & hole history
│   └── course_catalog.dart      # Nintendo Switch Sports courses & standard pars
├── services/
│   ├── scorecard_parser.dart    # Token & grid parser with checksum validation
│   ├── ocr_service.dart         # Google ML Kit integration
│   └── database_service.dart   # SQLite database & CRUD operations
├── providers/
│   └── golf_tracker_provider.dart # State management (Provider)
├── screens/
│   ├── home_dashboard_screen.dart # Lifetime KPIs, distribution, recent rounds
│   ├── scan_image_screen.dart     # Camera / Gallery picker & OCR trigger
│   ├── review_verification_screen.dart # Editable table & verification
│   ├── manual_entry_screen.dart   # Manual round creator
│   └── round_detail_screen.dart   # Detailed score breakdown & round deletion
└── widgets/
    ├── score_badge.dart         # Color-coded score indicators
    ├── stats_card.dart          # Dashboard metric cards
    ├── distribution_chart.dart  # Scoring distribution breakdown
    └── hole_averages_chart.dart # Hole-by-hole horizontal chart
```

---

## Testing & Verification

Run all unit, widget, and parser test suites:
```bash
flutter test
```

Run static code analysis:
```bash
flutter analyze
```

---

## Building the Android APK

The debug APK has been generated and is ready for installation:
```bash
# Path to built APK:
build/app/outputs/flutter-apk/app-debug.apk
```

To install directly onto an Android device connected via USB:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```
Or run directly in debug mode:
```bash
flutter run
```
