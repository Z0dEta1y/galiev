import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Habit {
  final String id;
  String name;
  bool isCompleted;
  DateTime createdAt;
  List<int> selectedDays; // 1-7 (пн-вс)

  Habit({
    required this.name,
    this.isCompleted = false,
    this.selectedDays = const [],
    String? id,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'selectedDays': selectedDays,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        name: json['name'],
        isCompleted: json['isCompleted'],
        selectedDays: List<int>.from(json['selectedDays']),
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;

  Note({
    required this.title,
    required this.content,
    String? id,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        title: json['title'],
        content: json['content'],
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
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade300,
          secondary: Colors.blue.shade200,
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
  final List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

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

  void _addHabit(String name, List<int> selectedDays) {
    setState(() {
      habits.add(Habit(name: name, selectedDays: selectedDays));
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
    final currentDay = DateTime.now().weekday - 1; // 0-6 (пн-вс)

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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Сегодня: ${weekDays[currentDay]}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final isTodaySelected =
                          habit.selectedDays.contains(currentDay + 1);

                      if (!isTodaySelected) return const SizedBox.shrink();

                      return _HabitCard(
                        habit: habit,
                        onChanged: (value) => _toggleHabit(habit.id),
                        onDelete: () => _deleteHabit(habit.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final nameController = TextEditingController();
    final selectedDays = <int>[];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Новая привычка'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название привычки',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Дни повторения:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final dayNumber = index + 1;
                      return FilterChip(
                        label: Text(weekDays[index]),
                        selected: selectedDays.contains(dayNumber),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(dayNumber);
                            } else {
                              selectedDays.remove(dayNumber);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty &&
                      selectedDays.isNotEmpty) {
                    _addHabit(nameController.text.trim(), selectedDays);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Добавить'),
              ),
            ],
          );
        },
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: habit.isCompleted,
              onChanged: onChanged,
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

class NotesTab extends StatefulWidget {
  const NotesTab({super.key});

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  List<Note> notes = [];
  final _prefsKey = 'notes_data';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      setState(() {
        notes = jsonList.map((json) => Note.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notes.map((note) => note.toJson()).toList();
    prefs.setString(_prefsKey, jsonEncode(jsonList));
  }

  void _addNote(String title, String content) {
    setState(() {
      notes.add(Note(title: title, content: content));
    });
    _saveNotes();
  }

  void _updateNote(String id, String newTitle, String newContent) {
    setState(() {
      final note = notes.firstWhere((n) => n.id == id);
      note.title = newTitle;
      note.content = newContent;
    });
    _saveNotes();
  }

  void _deleteNote(String id) {
    setState(() {
      notes.removeWhere((note) => note.id == id);
    });
    _saveNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddNoteDialog(context),
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'Добавьте свою первую заметку',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteCard(
                  note: note,
                  onEdit: () => _showEditNoteDialog(context, note),
                  onDelete: () => _deleteNote(note.id),
                );
              },
            ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая заметка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Содержание',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addNote(
                  titleController.text.trim(),
                  contentController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать заметку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Содержание',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _updateNote(
                  note.id,
                  titleController.text.trim(),
                  contentController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(note.content),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
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
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
