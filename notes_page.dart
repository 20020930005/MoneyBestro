import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/notes.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Box<Note> _noteBox;
  int? _selectedNoteIndex;

  @override
  void initState() {
    super.initState();
    _noteBox = Hive.box<Note>('notes');
  }

  void _addNote() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isNotEmpty && content.isNotEmpty) {
                  final newNote = Note(
                    title: title,
                    content: content,
                    createdAt: DateTime.now(),
                  );

                  _noteBox.add(newNote); // Add the note to Hive
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );
  }

  void _toggleNoteDetail(int index) {
    setState(() {
      if (_selectedNoteIndex == index) {
        // If the selected note is tapped again, go back to the list view
        _selectedNoteIndex = null;
      } else {
        // Otherwise, show the detailed view for the selected note
        _selectedNoteIndex = index;
      }
    });
  }

  void _editNote(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isNotEmpty && content.isNotEmpty) {
                  note.title = title;
                  note.content = content;
                  note.save();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: const Text('Update Note'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNoteConfirm(Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                note.delete(); // Delete from Hive
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllNotes() async {
    try {
      await _noteBox.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notes cleared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear notes: $e')),
      );
    }
  }

  void _confirmClearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to clear all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _clearAllNotes(); // Correct method to clear notes
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Notes'),
  //       backgroundColor: Colors.deepOrange,
  //       actions: [
  //         IconButton(
  //           icon:
  //               const Icon(Icons.delete_forever_outlined, color: Colors.white),
  //           onPressed: _confirmClearAllData,
  //         ),
  //       ],
  //     ),
  //     body: ValueListenableBuilder(
  //       valueListenable: _noteBox.listenable(),
  //       builder: (context, Box<Note> box, _) {
  //         if (box.isEmpty) {
  //           return const Center(child: Text('No notes available'));
  //         }

  //         // Convert box values to a list
  //         final notesList = box.values.toList().cast<Note>();

  //         return ReorderableListView.builder(
  //           itemCount: notesList.length,
  //           onReorder: (oldIndex, newIndex) {
  //             setState(() {
  //               if (newIndex > oldIndex) newIndex -= 1;

  //               // Move the item within the list
  //               final movedNote = notesList.removeAt(oldIndex);
  //               notesList.insert(newIndex, movedNote);

  //               // After reordering, save the updated list back to Hive
  //               for (int i = 0; i < notesList.length; i++) {
  //                 box.putAt(i, notesList[i]);
  //               }
  //             });
  //           },
  //           itemBuilder: (context, index) {
  //             final note = notesList[index];

  //             return Card(
  //               key: ValueKey(note), // Unique key for reordering
  //               margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //               elevation: 4,
  //               child: ListTile(
  //                 title: Text(note.title),
  //                 subtitle: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       note.content,
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'Created: ${DateFormat.yMMMd().format(note.createdAt)}',
  //                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
  //                     ),
  //                   ],
  //                 ),
  //                 trailing: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     IconButton(
  //                       icon: const Icon(Icons.edit, color: Colors.orange),
  //                       onPressed: () => _editNote(note),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.delete, color: Colors.red),
  //                       onPressed: () => _deleteNoteConfirm(note),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       },
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: _addNote,
  //       child: const Icon(Icons.add),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.delete_forever_outlined, color: Colors.white),
            onPressed: _confirmClearAllData,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _noteBox.listenable(),
        builder: (context, Box<Note> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No notes available'));
          }

          // Convert box values to a list
          final notesList = box.values.toList().cast<Note>();

          return ReorderableListView.builder(
            itemCount: notesList.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;

                // Move the item within the list
                final movedNote = notesList.removeAt(oldIndex);
                notesList.insert(newIndex, movedNote);

                // After reordering, save the updated list back to Hive
                for (int i = 0; i < notesList.length; i++) {
                  box.putAt(i, notesList[i]);
                }
              });
            },
            itemBuilder: (context, index) {
              final note = notesList[index];

              return Card(
                key: ValueKey(note), // Unique key for reordering
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  title: Text(note.title),
                  subtitle: _selectedNoteIndex == index
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              note.content,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created: ${DateFormat.yMMMd().format(note.createdAt)}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created: ${DateFormat.yMMMd().format(note.createdAt)}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                  onTap: () => _toggleNoteDetail(index), // Toggle detail view
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editNote(note),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNoteConfirm(note),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
