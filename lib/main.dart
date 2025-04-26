import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Habit {
  final String id;
  String name;
  bool isCompleted;
  DateTime createdAt;

  Habit({
    required this.name,
    this.isCompleted = false,
    String? id,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        name: json['name'],
        isCompleted: json['isCompleted'],
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Трекер привычек',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade800,
          secondary: Colors.blue.shade600,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade300,
          secondary: Colors.blue.shade200,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: MainScreen(
        onThemeChanged: (mode) {
          setState(() {
            _themeMode = mode;
          });
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HabitsTab(),
      const NotesTab(),
      SettingsTab(onThemeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'Привычки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_rounded),
            label: 'Заметки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Настройки',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class HabitsTab extends StatefulWidget {
  const HabitsTab({super.key});

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  List<Habit> habits = [];
  final _prefsKey = 'habits_data';

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

  void _addHabit(String name) {
    setState(() {
      habits.add(Habit(name: name));
    });
    _saveHabits();
  }

  void _deleteHabit(String id) {
    setState(() {
      habits.removeWhere((habit) => habit.id == id);
    });
    _saveHabits();
  }

  void _toggleHabit(String id) {
    setState(() {
      final habit = habits.firstWhere((h) => h.id == id);
      habit.isCompleted = !habit.isCompleted;
    });
    _saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои привычки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'Добавьте свою первую привычку',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _HabitCard(
                  habit: habit,
                  onChanged: (value) => _toggleHabit(habit.id),
                  onDelete: () => _deleteHabit(habit.id),
                );
              },
            ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить привычку'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Название привычки',
            hintText: 'Например: Утренняя зарядка',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _addHabit(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Checkbox(
              value: habit.isCompleted,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                habit.name,
                style: TextStyle(
                  fontSize: 16,
                  decoration:
                      habit.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Заметки')),
    );
  }
}

class SettingsTab extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsTab({super.key, required this.onThemeChanged});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSetting(),
          const Divider(),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildThemeSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тема приложения',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: Text('Светлая'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: Text('Тёмная'),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.settings_suggest),
              label: Text('Системная'),
            ),
          ],
          selected: {_themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            setState(() {
              _themeMode = newSelection.first;
              widget.onThemeChanged(_themeMode);
            });
          },
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return ListTile(
      leading: const Icon(Icons.delete_outline),
      title: const Text('Сбросить все данные'),
      textColor: Colors.red,
      iconColor: Colors.red,
      onTap: () => _showResetDialog(context),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить все данные?'),
        content: const Text('Это действие нельзя отменить!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
