import 'package:shared_preferences/shared_preferences.dart';

class Entry {
  final String id;
  final String title;
  final String description;
  final String content;
  final String dateAdded;

  Entry({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'dateAdded': dateAdded,
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      title: json['title'],
      description: json['desceiption'],
      content: json['content'],
      dateAdded: json['dateAdded'],
    );
  }

  static Future<void> saveEntry(Entry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    entries.add(entry);
    await prefs.setString('recipes', encodeEntries(entries));
  }

  static Future<List<Entry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString('recipes');
    if (entriesString == null || entriesString.isEmpty) {
      return [];
    }
    return decodeEntries(entriesString);
  }

  static Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadEntries();
    entries.removeWhere((entry) => entry.id == id);
    await prefs.setString('recipes', encodeEntries(entries));
  }

  static String encodeEntries(List<Entry> entries) {
    return entries.map((entry) => entry.toJson()).toList().toString();
  }

  static List<Entry> decodeEntries(String entriesString) {
  //   try {
  //     final List<dynamic> jsonList = List<dynamic>.from(eval(entriesString));
  //     return jsonList.map((json) => Entry.fromJson(json)).toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }
    return [];
  }
}
