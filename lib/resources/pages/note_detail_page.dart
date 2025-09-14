import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/note_controller.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/models/note.dart';

class NoteDetailPage extends NyStatefulWidget<NoteController> {
  static RouteView path = ("/note-detail", (_) => NoteDetailPage());

  NoteDetailPage({super.key}) : super(child: () => _NoteDetailPageState());
}

class _NoteDetailPageState extends NyState<NoteDetailPage> {
  Note? _note;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _isNew;

  @override
  get init => () {
        _note = widget.data<Note?>();
        _isNew = _note == null;
        _titleController = TextEditingController(text: _note?.title ?? "");
        _contentController = TextEditingController(text: _note?.content ?? "");
      };

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    final newNote = Note(
      id: _note?.id,
      title: title,
      content: content,
      createdAt: _note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isNew) {
      await widget.controller.addNote(newNote);
    } else {
      await widget.controller.updateNote(newNote);
    }
  }

  Future<void> _deleteNote() async {
    if (!_isNew && _note?.id != null) {
      await widget.controller.deleteNotes([_note!.id!]);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveNote();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? "New Note" : "Edit Note"),
          actions: [
            if (!_isNew)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteNote,
              )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Title (max 120 chars)",
                ),
                maxLength: 120,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: "Write your note...",
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
