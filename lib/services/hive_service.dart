import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weekly_boss/models/task.dart';
import 'package:weekly_boss/models/week.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;

  HiveService._internal();

  static const String _boxName = 'weeklyTasksBox';

  late final Box<Week> _weekBox;

  final ValueNotifier<List<Week>> weeksNotifier = ValueNotifier<List<Week>>([]);

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(WeekAdapter());

    _weekBox = await Hive.openBox<Week>(_boxName);
    _loadAllWeeks();
  }

  void _loadAllWeeks() {
    weeksNotifier.value = _weekBox.values.toList().cast<Week>();
  }

  //    CRUD

  //create / update
  Future<void> addOrUpdateWeek(Week week) async {
    await _weekBox.put(week.weekId, week);
    _loadAllWeeks();
  }

  //read all
  List<Week> getAllWeeks() {
    return weeksNotifier.value;
  }

  //read single week
  Week? getWeek(int weekId) {
    return _weekBox.get(weekId);
  }

  //delete
  Future<void> deleteWeek(int weekId) async {
    await _weekBox.delete(weekId);
    _loadAllWeeks();
  }

  // Example: Updating a task within a week
  Future<void> updateTaskInWeek(
    int weekId,
    int taskIndex,
    Task updatedTask,
  ) async {
    final week = _weekBox.get(weekId);

    if (week != null) {
      week.task[taskIndex] = updatedTask;
      await week.save();
      _loadAllWeeks();
    }
  }
}
