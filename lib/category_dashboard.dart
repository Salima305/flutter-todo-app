
import 'package:flutter/material.dart';
import 'task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

class CategoryDashboard extends StatefulWidget {
  const CategoryDashboard({super.key});

  @override
  State<CategoryDashboard> createState() => _CategoryDashboardState();
}

class _CategoryDashboardState extends State<CategoryDashboard> {
  List<Task> _tasks = [];
  double _progress = 0;
  bool _isLoading = true;

final List<String> _categories = [
  'Study',
  'Work',
  'Personal',
  'Shopping',
  'Health',
];

  void _calculateProgress() {
  if (_tasks.isEmpty) {
    _progress = 0;
    return;
  }

  final completedCount =
      _tasks.where((task) => task.isCompleted).length;

  _progress = completedCount / _tasks.length;
}

String _getTaskCount(String category) {
  final count =
      _tasks.where((task) => task.category == category).length;

  return '$count ${count == 1 ? 'task' : 'tasks'}';
}

Future<void> _loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
await prefs.remove('categories');
  final savedTasks = prefs.getStringList('tasks') ?? [];

  setState(() {
    _tasks = savedTasks.map((task) {
      return Task.fromJson(
        jsonDecode(task) as Map<String, dynamic>,
      );
    }).toList();
_calculateProgress();
    _isLoading = false;
  });
}

@override 
void initState(){
    super.initState();
    _loadTasks();
}



// Future<void> _showAddCategoryDialog() async {
//   final controller = TextEditingController();

//   final name = await showDialog<String>(
//     context: context,
//     builder: (dialogContext) {
//       return AlertDialog(
//         title: const Text('Add Category'),
//         content: TextField(
//           controller: controller,
//           autofocus: true,
//           textCapitalization: TextCapitalization.words,
//           decoration: const InputDecoration(
//             labelText: 'Category name',
//             hintText: 'e.g. Travel',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(
//                 dialogContext,
//                 controller.text.trim(),
//               );
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       );
//     },
//   );

//   controller.dispose();

//   if (!mounted || name == null || name.isEmpty) return;

//   final alreadyExists = _categories.any(
//     (category) => category.toLowerCase() == name.toLowerCase(),
//   );

//   if (alreadyExists) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('This category already exists.'),
//       ),
//     );
//     return;
//   }

//   final prefs = await SharedPreferences.getInstance();
//   final updatedCategories = [..._categories, name];

//   await prefs.setStringList('categories', updatedCategories);

//   if (!mounted) return;

//   setState(() {
//     _categories.add(name);
//   });
// }



  @override
  Widget build(BuildContext context) {
   return Scaffold(
  body: SafeArea(
    child: Container(
        color: const Color(0xFFFFFCF5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Yellow banner with title and progress.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                color: const Color(0xFFF5C94D),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Organize your day',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('A little progress every day.'),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('YOUR DAILY PROGRESS'),
                          const SizedBox(height: 12),
                         Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
'${_tasks.where((task) => task.isCompleted).length} of ${_tasks.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('tasks completed'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:LinearProgressIndicator(
  value: _progress,
  minHeight: 8,
  backgroundColor: const Color(0xFFE8DDBE),
  color: const Color(0xFF5C7B51),
),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Category section on the cream background.
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                     children: [
  _buildCategoryCard(
    'All Tasks',
    Icons.checklist_rounded,
    '${_tasks.length} ${_tasks.length == 1 ? 'task' : 'tasks'}',
    const Color(0xFFFFF0C2),
  ),

 ..._categories.map((category) {
  final IconData icon;
  final Color color;

  switch (category) {
    case 'Study':
      icon = Icons.book_outlined;
      color = const Color(0xFFE8EAFB);
      break;
    case 'Work':
      icon = Icons.work_outline;
      color = const Color(0xFFFBE5D8);
      break;
    case 'Personal':
      icon = Icons.favorite_border;
      color = const Color(0xFFDFF1E4);
      break;
    case 'Shopping':
      icon = Icons.shopping_bag_outlined;
      color = const Color(0xFFF8E8F1);
      break;
    case 'Health':
      icon = Icons.fitness_center;
      color = const Color(0xFFE0F2F1);
      break;
    default:
      icon = Icons.category_outlined;
      color = const Color(0xFFE8EAFB);
  }

  return _buildCategoryCard(
    category,
    icon,
    _getTaskCount(category),
    color,
  );
}),
// _buildCategoryCard(
//   'Add Category',
//   Icons.add_circle_outline,
//   'Create a category',
//   const Color(0xFFFFF0C2),
// ),
],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    String taskCount,
    Color backgroundColor,
  ) {
  return InkWell(
 onTap: () async {
  // if (title == 'Add Category') {
  //   await _showAddCategoryDialog();
  //   return;
  // }

  await context.push(
    '/tasks',
    extra: title == 'All Tasks' ? null : title,
  );

  if (!mounted) return;
  await _loadTasks();
},
  child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(taskCount),
        ],
      ),
     ),
  );
  }
}
