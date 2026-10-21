import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'category_dashboard.dart';
import 'task.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router=GoRouter(
  routes:[
    GoRoute(
      path:'/',
      builder:(context,state)=>const  CategoryDashboard(),
    ),
    GoRoute(
      path:'/tasks',
      builder:(context,state)=> MyHomePage(title: 'My Tasks',selectedCategory: state.extra as String?,),
    ),
  ],
);
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return MaterialApp.router(
      title: 'My To-Do App',
      theme: ThemeData(
        
         colorScheme:ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.selectedCategory,});

  final String title;
  final String? selectedCategory;

@override
State<MyHomePage> createState()=>
_MyHomePageState();

}
class _MyHomePageState extends State<MyHomePage>
{
  
final List<Task> _tasks=[];
final TextEditingController _taskController=TextEditingController();
String _selectedFilter = 'All';
final List<String> _categories = [
  'Personal',
  'Study',
  'Work',
  'Shopping',
  'Health',
];

String _selectedCategory = 'Personal';
final TextEditingController _searchController=TextEditingController();

@override
void initState(){
  super.initState();
  _loadTasks();
}

 void _showAddTaskDialog(){
  showDialog(
    context:context,
    builder:(context){
      return AlertDialog(
        title:const Text('Add Task'),
        content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    TextField(
      controller: _taskController,
      decoration: const InputDecoration(
        labelText: 'Enter task',
        hintText: 'e.g. Learn Flutter',
      ),
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    ),
  ],
),
        actions:[
          TextButton(
            onPressed:(){
              Navigator.pop(context);
            },
            child:const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed:(){
              final task = _taskController.text.trim();
              if (task.isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:Text('Please enter a task title.'),
                  ),
                );
              return;
              }
              
              final alreadyExists= _tasks.any((existingTask)=>existingTask.title.trim().toLowerCase()==task.toLowerCase(),);
              if(alreadyExists){
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content:Text('This task already exists.'),
                  ),
                );
                return;
              }
              
                setState((){
                  _tasks.add(Task(title: task, category: _selectedCategory,));
                });
                _saveTasks();
                _taskController.clear();
                Navigator.pop(context);
              
            },
            child:const Text('Save'),
          ),
        ],
      );
    },
  );
 }

void _showEditTaskDialog(Task task) {
  _selectedCategory = _categories.contains(task.category)
    ? task.category
    : 'Personal';
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Task'),
       content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    TextField(
      controller: _taskController,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: 'Task title',
      ),
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      initialValue: _categories.contains(task.category)
          ? task.category
          : 'Personal',
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    ),
  ],
),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _taskController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedTitle = _taskController.text.trim();

              if (updatedTitle.isNotEmpty) {
                setState(() {
                  task.title = updatedTitle;
                  task.category = _selectedCategory;
                });
                _saveTasks();

                _taskController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}

 List <Task>get _filteredTasks{
  List<Task>filtered= _tasks;

   if (widget.selectedCategory != null) {
    filtered = filtered
        .where((task) =>
            task.category == widget.selectedCategory)
        .toList();
  }
  if (_selectedFilter=='Active'){
    filtered=filtered.where((task)=>
    !task.isCompleted).toList();
  }

  else if (_selectedFilter=='Completed'){
   filtered=filtered.where((task)=>task.isCompleted).toList();
  }
  final query=_searchController.text.trim().toLowerCase();
  if(query.isNotEmpty){
    filtered=filtered.where((task)=>task.title.toLowerCase().contains(query)).toList();
  }
  return filtered;
 }

Future<void> _saveTasks() async {
  final prefs = await SharedPreferences.getInstance();

  final tasksJson = _tasks
      .map((task) => jsonEncode(task.toJson()))
      .toList();

  await prefs.setStringList('tasks', tasksJson);
}

Future<void>_loadTasks()async{
  final prefs=await SharedPreferences.getInstance();
  final savedTasks=prefs.getStringList('tasks');
  if (savedTasks!=null){
    setState((){
      _tasks.clear();
      _tasks.addAll(
        savedTasks.map((task)=>Task.fromJson(jsonDecode(task)as Map<String,dynamic>,
        ),
        ),
      );
    });
  }
}


Color _getCategoryColor(String category) {
  switch (category) {
    case 'Study':
      return const Color(0xFFFCE7F3); // Pink
    case 'Work':
      return const Color(0xFFDBEAFE); // Blue
    case 'Personal':
      return const Color(0xFFD1FAE5); // Mint
    case 'Shopping':
      return const Color(0xFFFEF3C7); // Yellow
    case 'Health':
      return const Color(0xFFEDE9FE); // Lavender
    default:
      return const Color(0xFFFFF8F0); // Cream
  }
}


  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
appBar: AppBar(
 backgroundColor: const Color(0xFFE8DDF8),
title: const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      'My Tasks',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    ),
    SizedBox(height: 4),
    Text(
      'Small steps, meaningful progress.',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Color(0xFF77717A),
      ),
    ),
  ],
),

   
),
     body: Column(
  children: [
   Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
   
  ),
),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  ),
  child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Search tasks...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _searchController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
    ),
    onChanged: (value) {
      setState(() {});
    },
  ),
),
Padding(
  padding: const EdgeInsets.all(12),
  child: Wrap(
    spacing: 8,
   
children: ['All', 'Active', 'Completed'].map((filter) {
  final categoryTasks = widget.selectedCategory == null
      ? _tasks
      : _tasks
          .where((task) =>
              task.category == widget.selectedCategory)
          .toList();

  final int count;

  if (filter == 'Active') {
    count = categoryTasks
        .where((task) => !task.isCompleted)
        .length;
  } else if (filter == 'Completed') {
    count = categoryTasks
        .where((task) => task.isCompleted)
        .length;
  } else {
    count = categoryTasks.length;
  }

  return ChoiceChip(
    label: Text('$filter($count)'),
    selected: _selectedFilter == filter,
    onSelected: (selected) {
      setState(() {
        _selectedFilter = filter;
      });
    },
  );
}).toList(),

  ),
),

  Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        const Icon(
          Icons.folder_outlined,
          color: Color(0xFF62418B),
        ),
        const SizedBox(width: 8),
        Text(
        widget.selectedCategory ?? 'All Tasks',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF62418B),
          ),
        ),
      ],
    ),
  ),
   Expanded(
  child: _filteredTasks.isEmpty
      ? Center(
          child: Text(
            _searchController.text.trim().isNotEmpty
                ? 'No matching tasks found'
                : _selectedFilter == 'Completed'
                    ? 'No completed tasks yet'
                    : _selectedFilter == 'Active'
                        ? 'No active tasks'
                        : 'No tasks yet!',
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        )
          : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
   return Card(
  elevation: 0,
color: task.isCompleted
    ? const Color(0xFFE8E8E8)
    : _getCategoryColor(task.category),
  margin: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 5,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: ListTile(
  leading: Checkbox(
    value: task.isCompleted,
    onChanged: (bool? value) {
      setState(() {
        task.isCompleted = value??false;
      });
      _saveTasks();
    },
  ),
  title: Text(
  task.title,
  style: TextStyle(
    decoration: task.isCompleted
        ? TextDecoration.lineThrough
        : TextDecoration.none,
  ),
),

  trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        _taskController.text = task.title;
        _showEditTaskDialog(task);
      },
    ),
  
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        setState(() {
          _tasks.remove(task);
        });
        _saveTasks();
      },
    ),
  ],
),
  ),
);
      },
          ),),
  ],
     ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
    
  }
}
