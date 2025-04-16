import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Модель привычки
class Habit {
  final String name;
  bool isCompleted;

  Habit({required this.name, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
    'name': name,
    'isCompleted': isCompleted,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    isCompleted: json['isCompleted'],
  );
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список привычек',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HabitListScreen(),
    );
  }
}

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit> habits = [];
  final _prefsKey = 'habits_list';

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      setState(() {
        habits = jsonList.map((json) => Habit.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = habits.map((habit) => habit.toJson()).toList();
    prefs.setString(_prefsKey, jsonEncode(jsonList));
  }

  void _addNewHabit(String name) {
    setState(() {
      habits.add(Habit(name: name));
    });
    _saveHabits();
  }

  void _toggleHabit(int index) {
    setState(() {
      habits[index].isCompleted = !habits[index].isCompleted;
    });
    _saveHabits();
  }

  void _deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    _saveHabits();
  }

  void _showAddHabitDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить привычку'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Название привычки'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addNewHabit(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои привычки')),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Checkbox(
              value: habits[index].isCompleted,
              onChanged: (_) => _toggleHabit(index),
            ),
            title: Text(
              habits[index].name,
              style: habits[index].isCompleted
                  ? TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteHabit(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddHabitDialog(context),
      ),
    );
  }
}