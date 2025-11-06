import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // REQUIRED for listenable() on the Box

import '../models/task.dart';
import '../models/week.dart';
import '../services/hive_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Week parentWeek;
  final int taskIndex;
  final HiveService hiveService;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.parentWeek,
    required this.taskIndex,
    required this.hiveService,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isReadOnly = true;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _notesController = TextEditingController(text: widget.task.note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  void _saveChanges(Week thisWeek) {
    final taskToUpdate = thisWeek.task[widget.taskIndex];
    taskToUpdate.title = _titleController.text.trim();
    taskToUpdate.description = _descriptionController.text.trim();
    taskToUpdate.note = _notesController.text.trim();

    widget.hiveService.addOrUpdateWeek(thisWeek);
    setState(() {
      _isReadOnly = true;
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Task details saved!')),
    // );
  }

  void _deleteTask(Week thisWeek) {
    thisWeek.task.removeAt(widget.taskIndex);
    widget.hiveService.addOrUpdateWeek(thisWeek);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Week>>(
      valueListenable: Hive.box<Week>('weeklyTasksBox').listenable(),
      builder: (context, box, child) {

        final thisWeek = box.get(widget.parentWeek.weekId);

        if (thisWeek == null || thisWeek.task.length <= widget.taskIndex) {
          Future.microtask(() => Navigator.pop(context));
          return const Scaffold(body: Center(child: Text("Task or Week deleted.")));
        }

        final thisTask = thisWeek.task[widget.taskIndex];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    readOnly: _isReadOnly,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: _isReadOnly
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      border: _isReadOnly
                          ? InputBorder.none
                          : const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                      contentPadding: _isReadOnly
                          ? EdgeInsets.zero
                          : const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: thisTask.isCompleted,
                        activeColor: Colors.black,
                        onChanged: (value) {
                          thisTask.isCompleted = value!;
                          widget.hiveService.addOrUpdateWeek(
                            thisWeek,
                          ); // Save the live object
                        },
                      ),
                      Text(thisTask.isCompleted ? 'Completed' : 'Pending'),
                      Spacer(),
                      // Delete button (uses thisWeek)
                      IconButton.outlined(
                        color: Colors.red,
                        onPressed: () => _deleteTask(thisWeek),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description Container
                  _buildDetailContainer(
                    title: 'Description',
                    controller: _descriptionController,
                    readOnly: _isReadOnly,
                    maxLines: 3,
                    height: 100,
                    hintText: 'Add task details, due date, or priority ...',
                  ),

                  const SizedBox(height: 24),

                  // Notes Container
                  _buildDetailContainer(
                    title: 'Notes',
                    controller: _notesController,
                    readOnly: _isReadOnly,
                    maxLines: 15,
                    height: 350,
                    hintText:
                        'Add your study notes, code snippets, or learning materials ...',
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              if (_isReadOnly) {
                setState(() {
                  _isReadOnly = false;
                });
              } else {
                _saveChanges(thisWeek);
              }
            },
            child: Icon(
              _isReadOnly ? Icons.edit : Icons.check,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailContainer({
    required String title,
    required TextEditingController controller,
    required bool readOnly,
    required int maxLines,
    required double height,
    required String hintText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              readOnly: readOnly,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: readOnly
                      ? BorderSide.none
                      : const BorderSide(color: Colors.black),
                ),
                hintText: hintText,
                filled: !readOnly,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
