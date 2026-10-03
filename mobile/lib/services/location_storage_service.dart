// import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//Models
import '../models/location_entry_model.dart';

//Logging
import "../debug/debug.dart";
import 'package:logger/logger.dart';



class LocationStorageService {
  static final LocationStorageService _instance =
      LocationStorageService._internal();

  factory LocationStorageService() => _instance;

  LocationStorageService._internal();

  Database? _database;

  final logger = Logger();

  Future<Database> _initDb() async {

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'location_entries.db');

    Log.success('Initialized database!');
    
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_key TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            accuracy REAL,
            altitude REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE locations ADD COLUMN user_key TEXT;');
          await db.execute(
            "UPDATE locations SET user_key = 'unknown' WHERE user_key IS NULL;",
          );
        }
      },
    );
  }

  Future<Database> get _db async {
      
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    // clearAll(); // Clear all entries on startup for testing purposes

//     _database!.execute('''
//       INSERT INTO locations (latitude, longitude, timestamp, accuracy, altitude)
// VALUES (37.7749, -122.4194, '2023-01-01 00:00:00', 5.0, 10.0);
//       )
//     ''');
    
    return _database!;
  }



  Future<void> insert(LocationEntry entry, {required String userKey}) async {
    final db = await _db;
    await db.insert(
      'locations',
      entry.toMap()
        ..remove('id')
        ..['user_key'] = userKey,
      // conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocationEntry>> getLastEntries(
    int limit, {
    required String userKey,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'locations',
      where: 'user_key = ?',
      whereArgs: [userKey],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    Log.info('Retrieved last ${rows.length} location entries.');
    return rows.map(LocationEntry.fromMap).toList();
  }

  Future<List<LocationEntry>> getAllEntries({required String userKey}) async {
    final db = await _db;
    final rows = await db.query(
      'locations',
      where: 'user_key = ?',
      whereArgs: [userKey],
      orderBy: 'timestamp ASC',
    );
    return rows.map(LocationEntry.fromMap).toList();
  }

  Future<void> clearAll({required String userKey}) async {
    final db = await _db;
    await db.delete(
      'locations',
      where: 'user_key = ?',
      whereArgs: [userKey],
    );
    Log.info('Cleared all location entries from the database.');
  }
}

