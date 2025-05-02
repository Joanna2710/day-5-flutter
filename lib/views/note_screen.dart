import 'package:day__5/controllers/hive_controller.dart';
import 'package:day__5/controllers/sqlite_controller.dart';
import 'package:day__5/models/note.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_application_1/controllers/hive_controller.dart';
// import 'package:flutter_application_1/controllers/sqlite_controller.dart';
// import 'package:flutter_application_1/models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum StorageType { hive, sqlite }

class _NotesScreenState extends State<NotesScreen> {
  final SqliteController sqliteController = SqliteController();
  final HiveController hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Note> _notes = [];
  StorageType selectedStorage = StorageType.hive;

  void _initHive() async {
    hiveController.init();
  }

  void _loadNotes() async {
    if (selectedStorage == StorageType.sqlite) {
      final notes = await sqliteController.getNotes();
      setState(() {
        _notes = notes;
      });
    } else {
      final notes = await hiveController.getNotes();
      setState(() {
        _notes = notes;
      });
    }
  }

  void _addNote() async {
    final note = Note(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.insert(note);
    } else {
      hiveController.add(note);
    }

    _titleController.clear();
    _descriptionController.clear();
    Navigator.pop(context);
    _loadNotes();
  }

  void deleteNote(int? id) async {
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.delete(id);
    } else {
      hiveController.delete(id);
    }
    _loadNotes();
  }

  void _showAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Note", style: Theme.of(context).textTheme.titleLarge),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _addNote,
                child: Text("Save"),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initHive();
      sqliteController.init();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              if (selectedStorage == StorageType.hive) {
                hiveController.clear();
                _loadNotes();
              }
            },
            tooltip: 'Clear Hive Notes',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            DropdownButtonFormField<StorageType>(
              value: selectedStorage,
              decoration: InputDecoration(
                labelText: "Select Storage",
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: StorageType.sqlite, child: Text('SQLite')),
                DropdownMenuItem(value: StorageType.hive, child: Text('Hive')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStorage = value!;
                });
                _loadNotes();
              },
            ),
            SizedBox(height: 12),
            Expanded(
              child: _notes.isEmpty
                  ? Center(child: Text("No notes yet."))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(note.title),
                            subtitle: Text(note.description),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
  final id = selectedStorage == StorageType.hive ? index : note.id;
  if (id != null) {
    deleteNote(id);
  }
}

                            
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
