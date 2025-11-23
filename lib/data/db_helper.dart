import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/health_record.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static const _dbName = 'healthmate.db';
  static const _dbVersion = 1;
  static const table = 'health_records';

  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        water INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(HealthRecord r) async {
    final db = await database;
    return await db.insert(table, r.toMap());
  }

  Future<List<HealthRecord>> fetchAllRecords() async {
    final db = await database;
    final rows = await db.query(table, orderBy: 'date DESC');
    return rows.map((r) => HealthRecord.fromMap(r)).toList();
  }

  Future<int> updateRecord(HealthRecord r) async {
    final db = await database;
    return await db.update(
      table,
      r.toMap(),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HealthRecord>> fetchRecordsByDateRange(
    String start,
    String end,
  ) async {
    final db = await database;
    final rows = await db.query(
      table,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return rows.map((r) => HealthRecord.fromMap(r)).toList();
  }
}
