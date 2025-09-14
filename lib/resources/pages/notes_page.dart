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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  LayoutMode _layoutMode = LayoutMode.list;
  bool _isFabVisible = true;
  Timer? _fabTimer;
  bool _selectionMode = false;
  final Set<String> _selectedNotes = {};

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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // clean up
    _scrollController.dispose();
    super.dispose();
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

  void _onSearch() async {
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
    _searchFocusNode.unfocus();
    await routeTo(NoteDetailPage.path, data: note);
    await _loadNotes();
  }

  Future<void> _toggleLayout() async {
    final newMode =
        _layoutMode == LayoutMode.list ? LayoutMode.grid : LayoutMode.list;
    setState(() => _layoutMode = newMode);
    await widget.controller.setLayoutMode(newMode);
  }

  // Selection mode func
  void toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedNotes.clear();
      }
    });
  }

  void toggleSelection(int index) {
    final noteId = _filteredNotes[index].id;
    setState(() {
      if (_selectedNotes.contains(noteId)) {
        _selectedNotes.remove(noteId);
      } else {
        _selectedNotes.add(noteId);
      }
    });
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedNotes.clear();
        _selectedNotes.addAll(_filteredNotes.map((note) => note.id!));
      } else {
        _selectedNotes.clear();
      }
    });
  }

  Future<void> deleteSelected() async {
    if (_selectedNotes.isEmpty) return;
    await widget.controller.deleteNotes(_selectedNotes.toList());
    setState(() {
      _notes.removeWhere((note) => _selectedNotes.contains(note.id));
      _filteredNotes.removeWhere((note) => _selectedNotes.contains(note.id));
      _selectedNotes.clear();
      _selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // dismiss keyboard & stop focus,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: !_selectionMode
              ? const Text("Notes")
              : Row(
                  children: [
                    Checkbox(
                      value: _selectedNotes.length == _filteredNotes.length &&
                          _filteredNotes.isNotEmpty,
                      onChanged: toggleSelectAll,
                    ),
                    const SizedBox(width: 8),
                    Text("${_selectedNotes.length} selected"),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: deleteSelected,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: toggleSelectionMode,
                    ),
                  ],
                ),
          actions: !_selectionMode
              ? [
                  IconButton(
                    icon: Icon(
                      _layoutMode == LayoutMode.grid
                          ? Icons.list
                          : Icons.grid_view,
                    ),
                    onPressed: _toggleLayout,
                  ),
                ]
              : null,
          bottom: !_selectionMode
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search notes...",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : null,
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
                        itemBuilder: (_, i) => SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Stack(children: [
                                  NoteCard(
                                    note: _filteredNotes[i],
                                    onTap: () => !_selectionMode
                                        ? _navigateToDetail(_filteredNotes[i])
                                        : toggleSelection(i),
                                    layout: _layoutMode,
                                    onLongPress: () {
                                      if (!_selectionMode)
                                        toggleSelectionMode();
                                      // Select this card
                                      toggleSelection(i);
                                    },
                                  ),
                                  if (_selectionMode)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Checkbox(
                                        value: _selectedNotes
                                            .contains(_filteredNotes[i].id),
                                        onChanged: (val) {
                                          toggleSelection(i);
                                        },
                                      ),
                                    ),
                                ]),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                !_filteredNotes[i].title.isEmpty
                                    ? _filteredNotes[i].title
                                    : 'Note created day ${_filteredNotes[i].createdAt.day}-${_filteredNotes[i].createdAt.month}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _filteredNotes[i].createdAt.toDateStringUS()!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      radius: const Radius.circular(10),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredNotes.length,
                        itemBuilder: (_, i) => Stack(
                          children: [
                            NoteCard(
                              note: _filteredNotes[i],
                              onTap: () => !_selectionMode
                                  ? _navigateToDetail(_filteredNotes[i])
                                  : toggleSelection(i),
                              layout: _layoutMode,
                              onLongPress: () {
                                if (!_selectionMode) toggleSelectionMode();
                                // Select this card
                                toggleSelection(i);
                              },
                            ),
                            if (_selectionMode)
                              Positioned(
                                top: 0,
                                right: 8,
                                child: Checkbox(
                                  value: _selectedNotes
                                      .contains(_filteredNotes[i].id),
                                  onChanged: (val) {
                                    toggleSelection(i);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
        ),
        floatingActionButton: (!_selectionMode && _isFabVisible)
            ? FloatingActionButton.small(
                onPressed: () => _navigateToDetail(),
                shape: CircleBorder(),
                child: const Icon(
                  Icons.add,
                ),
              )
            : null,
      ),
    );
  }
}
