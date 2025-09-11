import 'package:nylo_framework/nylo_framework.dart';
import '../models/note.dart';

enum LayoutMode { list, grid }

class NoteStorageService {
  static const String _layoutKey = "layout_mode";

  /// Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final notesJson = await NyStorage.readCollection(Note.key);
    return notesJson.map((json) => Note.fromJson(json)).toList();
  }

  /// Thêm mới ghi chú
  Future<void> addNote(Note note) async {
    final notes = await getAllNotes();
    final newId = notes.isEmpty ? 1 : (notes.last.id ?? 0) + 1;
    final noteWithId = note..id = note.id ?? newId;
    await NyStorage.addToCollection(Note.key, item: noteWithId.toJson());
  }

  /// Cập nhật ghi chú theo id
  Future<void> updateNote(Note updatedNote) async {
    final notesJson = await NyStorage.readCollection(Note.key) ?? [];
    final index = notesJson.indexWhere((n) => n['id'] == updatedNote.id);
    if (index != -1) {
      notesJson[index] = updatedNote.toJson();
      await NyStorage.saveCollection(Note.key, notesJson);
    }
  }

  /// Xóa ghi chú theo id
  Future<void> deleteNote(int id) async {
    final notesJson = await NyStorage.readCollection(Note.key);
    notesJson.removeWhere((item) => item['id'] == id);
    await NyStorage.saveCollection(Note.key, notesJson);
  }

  /// Tìm kiếm theo title/content
  Future<List<Note>> searchNotes(String keyword) async {
    final notes = await getAllNotes();
    return notes.where((n) {
      final lower = keyword.toLowerCase();
      return n.title.toLowerCase().contains(lower) ||
          n.content.toLowerCase().contains(lower);
    }).toList();
  }

  /// Lọc theo điều kiện custom
  Future<List<Note>> filterNotes(bool Function(Note) condition) async {
    final notes = await getAllNotes();
    return notes.where(condition).toList();
  }

  /// Xóa toàn bộ ghi chú
  Future<void> clearAllNotes() async {
    await await NyStorage.deleteCollection(Note.key);
  }

  /// Layout Mode (Grid/List)
  Future<LayoutMode> getLayoutMode() async {
    final mode = await NyStorage.read(_layoutKey, defaultValue: "list");
    return mode == "grid" ? LayoutMode.grid : LayoutMode.list;
  }

  Future<void> setLayoutMode(LayoutMode mode) async {
    await NyStorage.save(_layoutKey, mode == LayoutMode.grid ? "grid" : "list");
  }
}
