import 'package:hive_flutter/hive_flutter.dart';
import 'package:weekly_boss/models/task.dart';
part 'week.g.dart';

@HiveType(typeId: 2)
  class Week extends HiveObject {
  @HiveField(0)
  final int weekId;
  @HiveField(1)
  final List<Task> task;

  Week({required this.weekId, required this.task});
}
