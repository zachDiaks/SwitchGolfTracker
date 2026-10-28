import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/golf_round.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // If running on desktop (Linux / Windows / macOS), initialize FFI
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      final docDir = await getApplicationDocumentsDirectory();
      path = join(docDir.path, 'switch_sports_golf.db');
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'switch_sports_golf.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE golf_rounds (
            id TEXT PRIMARY KEY,
            timestamp INTEGER NOT NULL,
            courseType TEXT NOT NULL,
            notes TEXT,
            holesJson TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertRound(GolfRound round) async {
    final db = await database;
    await db.insert(
      'golf_rounds',
      round.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRound(GolfRound round) async {
    final db = await database;
    await db.update(
      'golf_rounds',
      round.toMap(),
      where: 'id = ?',
      whereArgs: [round.id],
    );
  }

  Future<void> deleteRound(String id) async {
    final db = await database;
    await db.delete(
      'golf_rounds',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<GolfRound>> getAllRounds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'golf_rounds',
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => GolfRound.fromMap(m)).toList();
  }

  Future<GolfRound?> getRoundById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'golf_rounds',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return GolfRound.fromMap(maps.first);
  }

  Future<void> clearAllRounds() async {
    final db = await database;
    await db.delete('golf_rounds');
  }
}
