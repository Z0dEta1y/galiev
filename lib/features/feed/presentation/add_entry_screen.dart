import 'package:flutter/material.dart';
import 'package:kurs_flutter/features/feed/domain/feed_entry.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Добавить запись"),
        actions: [IconButton(onPressed: saveEntry, icon: const Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите заголовок.";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите описание.";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                      labelText: 'Содержимое',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите содержимое.";
                    }
                    return null;
                  },
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = Entry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          content: _contentController.text,
          dateAdded: DateTime.now().toString());

      await Entry.saveEntry(entry);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
