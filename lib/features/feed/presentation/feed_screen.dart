import 'package:flutter/material.dart';
import 'package:kurs_flutter/features/feed/domain/feed_entry.dart';
import 'package:kurs_flutter/features/feed/presentation/add_entry_screen.dart';
import 'package:kurs_flutter/features/Habit/presentation/home_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Entry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = Entry.loadEntries();
  }

  Future<void> addEntry() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEntryScreen(),
        ));

    if (result == true) {
      setState(() {
        _entriesFuture = Entry.loadEntries();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Лента"),
      ),
      body: FutureBuilder<List<Entry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Ошибка :("),
            );
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const Center(
              child: Text('Данных нет'),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.description),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitListScreen(),
                        ));
                  },
                  trailing: IconButton(
                      onPressed: () async {
                        await Entry.deleteEntry(entry.id);
                        setState(() {
                          _entriesFuture = Entry.loadEntries();
                        });
                      },
                      icon: const Icon(Icons.delete)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
