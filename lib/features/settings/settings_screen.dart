import 'package:flutter/material.dart';
import 'package:kurs_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode currentTheme;
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to access inherited widgets
    if (_isLoading) {
      currentTheme = Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
      loadTheme();
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';
    setState(() {
      currentTheme = ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$theme',
        orElse: () => ThemeMode.system,
      );
    });
  }

  Future<void> changeTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.toString().split('.').last);
    setState(() {
      currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Настройки'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Тема'),
              const SizedBox(
                height: 8,
              ),
              Card(
                child: Column(
                  children: [
                    RadioListTile(
                        title: const Text('Светлая'),
                        value: ThemeMode.light,
                        groupValue: currentTheme,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            MainApp.of(context)?.changeTheme(value);
                            setState(() {
                              currentTheme = value;
                            });
                          }
                        }),
                    RadioListTile(
                        title: const Text('Темная'),
                        value: ThemeMode.dark,
                        groupValue: currentTheme,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            MainApp.of(context)?.changeTheme(value);
                            setState(() {
                              currentTheme = value;
                            });
                          }
                        }),
                    RadioListTile(
                        title: const Text('Системная'),
                        value: ThemeMode.system,
                        groupValue: currentTheme,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            MainApp.of(context)?.changeTheme(value);
                            setState(() {
                              currentTheme = value;
                            });
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
