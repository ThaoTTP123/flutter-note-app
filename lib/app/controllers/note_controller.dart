import 'package:flutter_app/app/models/note.dart';
import 'package:flutter_app/app/storage/note_storage_service.dart';

import '/app/controllers/controller.dart';

class NoteController extends Controller {
  final NoteStorageService _noteStorageService = NoteStorageService();

  // Notes
  Future<List<Note>> fetchNotes() => _noteStorageService.getAllNotes();
  Future<void> addNote(Note note) => _noteStorageService.addNote(note);
  Future<void> updateNote(Note note) => _noteStorageService.updateNote(note);
  Future<void> deleteNotes(List<String> ids) =>
      _noteStorageService.deleteNotes(ids);
  Future<List<Note>> searchNotes(String keyword) =>
      _noteStorageService.searchNotes(keyword);
  Future<List<Note>> filterNotes(bool Function(Note) condition) =>
      _noteStorageService.filterNotes(condition);
  Future<void> clearAll() => _noteStorageService.clearAllNotes();

  // Layout
  Future<LayoutMode> getLayoutMode() => _noteStorageService.getLayoutMode();
  Future<void> setLayoutMode(LayoutMode mode) =>
      _noteStorageService.setLayoutMode(mode);
}
