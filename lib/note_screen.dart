import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'about_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<String> notes = [];
  final TextEditingController _controller = TextEditingController();
  late DatabaseReference _notesRef;

  @override
  void initState() {
    super.initState();
    _notesRef = FirebaseDatabase.instance.ref('notes');
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final snapshot = await _notesRef.get();
      if (snapshot.exists) {
        setState(() {
          final data = snapshot.value as List<dynamic>?;
          notes = data?.map((e) => e.toString()).toList() ?? [];
        });
      }
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  Future<void> _saveNotes() async {
    try {
      await _notesRef.set(notes);
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        notes.add(_controller.text);
        _controller.clear();
      });
      _saveNotes();
    }
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    _saveNotes();
  }

  void _editNote(int index) {
    _controller.text = notes[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать заметку'),
          content: TextField(controller: _controller),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  notes[index] = _controller.text;
                  _controller.clear();
                });
                _saveNotes();
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            )]);
      });
  }

  void _goToAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _goToAboutPage,
          )]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите заметку',
                    ))),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                )])),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editNote(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNote(index),
                      )]));
              },
            ))]));
  }
}
