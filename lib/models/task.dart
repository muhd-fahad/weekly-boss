import 'package:hive_flutter/hive_flutter.dart';
part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String? note;

  @HiveField(3)
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.note,
    this.isCompleted = false,
  });
}
