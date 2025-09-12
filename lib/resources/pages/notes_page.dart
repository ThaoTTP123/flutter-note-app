import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/note_controller.dart';
import 'package:flutter_app/resources/pages/note_detail_page.dart';
import 'package:flutter_app/resources/widgets/note_card_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/models/note.dart';
import '../../app/storage/note_storage_service.dart';

class NotesPage extends NyStatefulWidget<NoteController> {
  static RouteView path = ("/home", (_) => NotesPage());

  NotesPage({super.key}) : super(child: () => _NotesPageState());
}

class _NotesPageState extends NyState<NotesPage> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  LayoutMode _layoutMode = LayoutMode.list;
  final TextEditingController _searchController = TextEditingController();
  // NEW: Track selected notes
  Set<int> _selectedNoteIds = {};
  @override
  void initState() {
    super.initState();
    boot();
  }

  boot() async {
    await _loadNotes();
    await _loadLayout();
    _searchController.addListener(_onSearch);
  }

  Future<void> _loadNotes() async {
    final notes = await widget.controller.fetchNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
    });
  }

  Future<void> _loadLayout() async {
    final mode = await widget.controller.getLayoutMode();
    setState(() => _layoutMode = mode);
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _filteredNotes = _notes);
    } else {
      setState(() => _filteredNotes = _notes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
  }

  void _navigateToDetail([Note? note]) async {
    await routeTo(NoteDetailPage.path, data: note);
    await _loadNotes();
  }

  Future<void> _toggleLayout() async {
    final newMode =
        _layoutMode == LayoutMode.list ? LayoutMode.grid : LayoutMode.list;
    setState(() => _layoutMode = newMode);
    await widget.controller.setLayoutMode(newMode);
  }

  // NEW: Delete selected notes
  Future<void> _deleteSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    for (var id in _selectedNoteIds) {
      await widget.controller.deleteNote(id);
    }
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            icon: Icon(
              _layoutMode == LayoutMode.grid ? Icons.list : Icons.grid_view,
            ),
            onPressed: _toggleLayout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text("No notes yet"))
          : _layoutMode == LayoutMode.grid
              ? GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _filteredNotes.length,
                  itemBuilder: (_, i) => NoteCard(
                    note: _filteredNotes[i],
                    onTap: () => _navigateToDetail(_filteredNotes[i]),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredNotes.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(_filteredNotes[i].title),
                    subtitle: Text(
                      _filteredNotes[i].content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _navigateToDetail(_filteredNotes[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetail(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
