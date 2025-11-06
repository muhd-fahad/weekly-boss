import 'package:flutter/material.dart';
import 'package:weekly_boss/models/week.dart';
import 'package:weekly_boss/screens/task_detail_screen.dart';
import 'package:weekly_boss/services/hive_service.dart';

import '../models/task.dart';

class WeekDetailScreen extends StatelessWidget {
  final int weekId;
  final HiveService hiveService;

  const WeekDetailScreen({
    super.key,
    required this.weekId,
    required this.hiveService,
  });

  // Helper function to add a new task to the current week
  // MUST accept the 'title' argument
  void _addNewTask(Week week, String title) {
    if (title.trim().isEmpty) return; // Prevent adding empty tasks

    final newTask = Task(
      title: title,
      description: '',
    );

    // 1. Add the new task to the list
    week.task.add(newTask);

    // 2. Save the parent object (Week) to persist the change via HiveService
    hiveService.addOrUpdateWeek(week);
  }

  // Helper function to toggle a task's completion status and save
  void _toggleTaskCompletion(Week week, int taskIndex) {
    final task = week.task[taskIndex];
    // Toggle the value
    task.isCompleted = !task.isCompleted;

    // Save the parent Week object to update the changes in Hive
    hiveService.addOrUpdateWeek(week);
  }

  void _showAddTaskDialog(BuildContext context, Week currentWeek) {
    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add New Task'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.black)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.black,width: 2)
              ),
              hintText: "Enter task title",
            ),
          ),
          actions:[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12))
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Pass the collected text to the helper
                _addNewTask(currentWeek, titleController.text);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12))
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final Week currentWeek = hiveService.weeksNotifier.value.firstWhere((w) => w.weekId == weekId,);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: () => Navigator.pop(context),icon: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 24,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week $weekId',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton.outlined(
                    color: Colors.red,
                    onPressed: () async {
                      await hiveService.deleteWeek(weekId);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
              ValueListenableBuilder<List<Week>>(
                valueListenable: hiveService.weeksNotifier,
                builder: (context, allWeeks, child) {
                  // final Week currentWeek = allWeeks.firstWhere(
                  //   (w) => w.weekId == weekId,
                  // );

                  final List<Task> tasks = currentWeek.task;

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          'No tasks yet. Tap the "+" button to add one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index)
                    {
                      final task = tasks[index];
                      return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        leading: Checkbox(
                          value: task.isCompleted,
                          focusColor: Colors.black,
                          activeColor: Colors.black,
                          onChanged: (value) =>
                              _toggleTaskCompletion(currentWeek, index),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: Icon(Icons.sticky_note_2_outlined),
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskDetailScreen(taskIndex: index,task: task,parentWeek: currentWeek,hiveService: hiveService,),
                              ),
                            ),
                      ),
                    );
                    }
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ValueListenableBuilder<List<Week>>(
        valueListenable: hiveService.weeksNotifier,
        builder: (context, allWeeks, child) {
          return FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context, currentWeek),
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}
