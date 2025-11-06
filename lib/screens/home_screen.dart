import 'package:flutter/material.dart';
import 'package:weekly_boss/models/task.dart';
import 'package:weekly_boss/models/week.dart';
import 'package:weekly_boss/screens/week_detail_screen.dart';
import 'package:weekly_boss/services/hive_service.dart';

import '../services/auth_service.dart';

enum WeekSortOption {
  latest,
  oldest,
  mostCompleted,
  leastCompleted,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {


  final TextEditingController _searchController = TextEditingController();
  WeekSortOption _currentSort = WeekSortOption.latest;

  final AuthService _authService = AuthService();
  String _userName = 'Guest';

@override
  void initState() {
    super.initState();
    _loadUserInfo();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _loadUserInfo() async {
    final name = await _authService.getUserName();
    setState(() {
      _userName = name ?? 'Guest';
    });
  }


  Future<void> _signOutUser() async {
    if (_userName != 'Guest') {
      await _authService.signOut();
    }
    Navigator.pushReplacementNamed(context, 'register');
  }

  void _sortWeeks(List<Week> weeks) {
    weeks.sort((a, b) {
      switch (_currentSort) {
        case WeekSortOption.latest:
          return b.weekId.compareTo(a.weekId);

        case WeekSortOption.oldest:

          return a.weekId.compareTo(b.weekId);

        case WeekSortOption.mostCompleted:
          int completedA = a.task.where((t) => t.isCompleted).length;
          int completedB = b.task.where((t) => t.isCompleted).length;
          return completedB.compareTo(completedA);

        case WeekSortOption.leastCompleted:

          int completedA = a.task.where((t) => t.isCompleted).length;
          int completedB = b.task.where((t) => t.isCompleted).length;
          return completedA.compareTo(completedB);
      }
    });
  }

  List<Week> _filterWeeks(List<Week> weeks) {
    final sortBy = _searchController.text.toLowerCase().trim();
    if (sortBy.isEmpty) {
      return weeks;
    }
    return weeks.where((week) {
      if (week.weekId.toString().contains(sortBy)) {
        return true;
      }
      return week.task.any((task) {
        return task.title.toLowerCase().contains(sortBy) ||
            task.description.toLowerCase().contains(sortBy) ||
            (task.note ?? '').toLowerCase().contains(sortBy);
      });
    }).toList();
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {

              // helper function for readable names
              String getDisplayName(WeekSortOption option) {
                final name = option.toString().split('.').last;
                return name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}').trim();
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sort Weeks By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(),
                    
                    ...WeekSortOption.values.map((option) {
                      return ListTile(
                        title: Text(getDisplayName(option)),
                        leading: Radio<WeekSortOption>(
                          value: option,
                          groupValue: _currentSort,
                          onChanged: (WeekSortOption? newValue) {
                            if (newValue != null) {
                              // Update the main screen state and close
                              setState(() {
                                _currentSort = newValue;
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final HiveService hiveService = HiveService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 72,
        titleTextStyle: TextStyle(fontSize: 24, color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Boss'),
            Text(
              'Welcome, $_userName',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: const Icon(Icons.calendar_today_outlined, color: Colors.white),
        ),
        actions: [
          IconButton.outlined(
            onPressed: _signOutUser,
            icon: const Icon(Icons.no_accounts_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            constraints: BoxConstraints(maxWidth: 768),
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          prefixIconColor: Colors.grey,
                          hintText: 'Search week, task, or notes...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: ()=> _showSortBottomSheet(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.tune_rounded, size: 24),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<List<Week>>(
                  valueListenable: hiveService.weeksNotifier,
                  builder: (context, weeks, child) {

                    List<Week> filteredWeeks = _filterWeeks(List.from(weeks));
                    _sortWeeks(filteredWeeks);

                    if (filteredWeeks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'No results found for "${_searchController.text}"'
                                : 'No weeks added yet. Tap the "+" button to start!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }


                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      // reverse: true,
                      itemCount: filteredWeeks.length,
                      itemBuilder: (context, index) {
                        final week = filteredWeeks[index];
                        final totalTasks = week.task.length;
                        final completedTasks = week.task.where((t) => t.isCompleted).length;

                        final progressValue = totalTasks > 0
                            ? completedTasks / totalTasks
                            : 0.0;
                        final isCompleted = progressValue == 1.0 && totalTasks > 0;
                        final completedColor = isCompleted
                            ? Colors.green
                            : Colors.black;


                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Row(
                                  spacing: 12,
                                  children: [
                                    Text(
                                      'Week ${week.weekId}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    if (isCompleted)
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: completedColor,
                                      ),
                                    Text(
                                      '$completedTasks/$totalTasks Tasks',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                                titleTextStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  // color: completedColor,
                                ),
                                // subtitle: Text('data'),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: LinearProgressIndicator(
                                    year2023: false,
                                    value: progressValue,
                                    trackGap: 4,
                                    borderRadius: BorderRadius.circular(12),
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.1,
                                    ),
                                    color: completedColor,
                                    stopIndicatorColor: Colors.transparent,
                                    minHeight: 6,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeekDetailScreen(
                                        weekId: week.weekId,
                                        hiveService: hiveService,
                                      ),
                                    ),
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    12,
                                  ),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                // trailing: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewWeekExample(hiveService);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addNewWeekExample(HiveService service) {
    final allWeeks = service.getAllWeeks();
    final lastId = allWeeks.isEmpty ? 0 : allWeeks.last.weekId;
    final newWeekId = lastId + 1;
    final newWeek = Week(
      weekId: newWeekId,
      task: [
        Task(
          title: "Untitled task ",
          description: "First task of the week.",
          note: 'resources : flutter.dev, pub.dev, fluttermasterylibrary.com',
        ),
      ],
    );
    service.addOrUpdateWeek(newWeek);
  }
}
