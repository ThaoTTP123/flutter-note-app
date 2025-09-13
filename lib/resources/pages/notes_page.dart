import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  Timer? _fabTimer;
  @override
  void initState() {
    super.initState();
    boot();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() => _isFabVisible = false);
        }
        _fabTimer?.cancel();
        _fabTimer = Timer(const Duration(seconds: 2), () {
          if (!_isFabVisible) {
            setState(() => _isFabVisible = true);
          }
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
          _fabTimer?.cancel();
        }
      }
    });
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _filteredNotes.isEmpty
            ? const Center(child: Text("No notes yet"))
            : _layoutMode == LayoutMode.grid
                ? Scrollbar(
                    controller: _scrollController,
                    radius: const Radius.circular(10),
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredNotes.length,
                      itemBuilder: (_, i) => NoteCard(
                        note: _filteredNotes[i],
                        onTap: () => _navigateToDetail(_filteredNotes[i]),
                        layout: _layoutMode,
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    radius: const Radius.circular(10),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredNotes.length,
                      itemBuilder: (_, i) => NoteCard(
                        note: _filteredNotes[i],
                        onTap: () => _navigateToDetail(_filteredNotes[i]),
                        layout: _layoutMode,
                      ),
                    ),
                  ),
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton.small(
              onPressed: () => _navigateToDetail(),
              backgroundColor: Colors.white,
              shape: CircleBorder(),
              child: const Icon(
                Icons.edit_note,
                color: Colors.blue,
              ),
            )
          : null,
    );
  }
}
