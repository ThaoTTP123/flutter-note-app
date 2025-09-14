import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/note_controller.dart';
import 'package:flutter_app/config/top_dialog_styles.dart';
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
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }
    if (title.isEmpty) {
      // Show an error or toast
      showTopConfirmDialog(
        context,
        message:
            "Ghi chú này sẽ không được lưu do chưa có tiêu đề, bạn chắc chắn muốn quay lại?",
        cancelText: 'Hủy',
        confirmText: 'Quay lại',
        onConfirm: () async {
          Navigator.pop(context);
        },
      );
      return;
    }

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
    Navigator.pop(context);
  }

  Future<void> _deleteNote() async {
    if (!_isNew && _note?.id != null) {
      showTopConfirmDialog(
        context,
        message: "Chuyển 1 ghi chú vào thùng rác",
        cancelText: 'Thoát',
        confirmText: 'Chuyển vào thùng rác',
        onConfirm: () async {
          await widget.controller.deleteNotes([_note!.id!]);
          if (mounted) Navigator.pop(context);
        },
      );
    }
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
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isNew ? "Tạo ghi chú mới" : "Sửa ghi chú",
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
                  hintText: "Tiêu đề",
                ),
                style: Theme.of(context).textTheme.titleMedium,
                maxLength: 120,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: "Viết ghi chú...",
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
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
