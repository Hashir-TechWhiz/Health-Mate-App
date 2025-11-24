import 'package:intl/intl.dart';
import '../data/db_helper.dart';
import '../models/health_record.dart';
import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;
  List<HealthRecord> records = [];
  bool initialized = false;

  Future<void> init() async {
    await _seedIfEmpty();
    await loadRecords();
    initialized = true;
  }

  Future<void> _seedIfEmpty() async {
    final all = await _db.fetchAllRecords();
    if (all.isEmpty) {
      final DateTime today = DateTime.now();
      final df = DateFormat('yyyy-MM-dd');
      final List<HealthRecord> seeds = [
        HealthRecord(
          date: df.format(today),
          steps: 8234,
          calories: 2100,
          water: 2200,
        ),
        HealthRecord(
          date: df.format(today.subtract(const Duration(days: 1))),
          steps: 7521,
          calories: 1950,
          water: 1800,
        ),
      ];
      for (final r in seeds) {
        await _db.insertRecord(r);
      }
    }
  }

  Future<void> loadRecords() async {
    records = await _db.fetchAllRecords();
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord r) async {
    await _db.insertRecord(r);
    await loadRecords();
  }

  Future<void> updateRecord(HealthRecord r) async {
    await _db.updateRecord(r);
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _db.deleteRecord(id);
    await loadRecords();
  }

  List<HealthRecord> recordsInRange(DateTime start, DateTime end) {
    final df = DateFormat('yyyy-MM-dd');
    final s = df.format(start);
    final e = df.format(end);
    return records
        .where((r) => r.date.compareTo(s) >= 0 && r.date.compareTo(e) <= 0)
        .toList();
  }

  HealthRecord? recordForDate(DateTime date) {
    final df = DateFormat('yyyy-MM-dd');
    return records.firstWhere(
      (r) => r.date == df.format(date),
      orElse: () =>
          HealthRecord(date: df.format(date), steps: 0, calories: 0, water: 0),
    );
  }

  Map<String, int> todayTotals() {
    final df = DateFormat('yyyy-MM-dd');
    final today = df.format(DateTime.now());
    final recs = records.where((r) => r.date == today);
    int steps = 0, calories = 0, water = 0;
    for (final r in recs) {
      steps += r.steps;
      calories += r.calories;
      water += r.water;
    }
    return {'steps': steps, 'calories': calories, 'water': water};
  }

  Map<String, double> last7DayAverages() {
    final df = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    int days = 7;
    int totalSteps = 0, totalCalories = 0, totalWater = 0;
    for (int i = 0; i < days; i++) {
      final d = df.format(now.subtract(Duration(days: i)));
      final r = records.firstWhere(
        (rec) => rec.date == d,
        orElse: () => HealthRecord(date: d, steps: 0, calories: 0, water: 0),
      );
      totalSteps += r.steps;
      totalCalories += r.calories;
      totalWater += r.water;
    }
    return {
      'stepsAvg': totalSteps / days,
      'caloriesAvg': totalCalories / days,
      'waterAvg': totalWater / days,
    };
  }
}
