import 'dart:io';
import 'package:flutter/material.dart';
import '../models/golf_round.dart';
import '../models/lifetime_stats.dart';
import '../services/database_service.dart';
import '../services/ocr_service.dart';
import '../services/scorecard_parser.dart';

class GolfTrackerProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final OcrService _ocr = OcrService();

  List<GolfRound> _rounds = [];
  LifetimeStats _lifetimeStats = LifetimeStats.empty();
  bool _isLoading = false;
  String? _errorMessage;

  List<GolfRound> get rounds => _rounds;
  LifetimeStats get lifetimeStats => _lifetimeStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  GolfTrackerProvider() {
    loadRounds();
  }

  Future<void> loadRounds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rounds = await _db.getAllRounds();
      _lifetimeStats = LifetimeStats.fromRounds(_rounds);
    } catch (e) {
      _errorMessage = 'Failed to load rounds: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRound(GolfRound round) async {
    try {
      await _db.insertRound(round);
      await loadRounds();
    } catch (e) {
      _errorMessage = 'Failed to save round: $e';
      notifyListeners();
    }
  }

  Future<void> updateRound(GolfRound round) async {
    try {
      await _db.updateRound(round);
      await loadRounds();
    } catch (e) {
      _errorMessage = 'Failed to update round: $e';
      notifyListeners();
    }
  }

  Future<void> deleteRound(String id) async {
    try {
      await _db.deleteRound(id);
      await loadRounds();
    } catch (e) {
      _errorMessage = 'Failed to delete round: $e';
      notifyListeners();
    }
  }

  Future<ParsedScorecardResult> scanAndParseImage(File imageFile) async {
    return await _ocr.processImage(imageFile);
  }
}
