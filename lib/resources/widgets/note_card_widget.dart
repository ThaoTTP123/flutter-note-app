import 'package:flutter/material.dart';
import 'package:flutter_app/app/storage/note_storage_service.dart';
import '../../app/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final LayoutMode layout;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.layout,
    this.onLongPress,
  });

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (layout == LayoutMode.list) {
      // 📋 List style
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity, // makes the card full width
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.title.isNotEmpty)
                    Text(
                      note.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  Text(
                    _formatDate(note.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Grid style
    return AspectRatio(
      aspectRatio: 3 / 4, // width : height
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior:
            Clip.antiAlias, // needed so ripple stays inside rounded corners
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: Colors.grey.withOpacity(0.2), // ripple color
          highlightColor: Colors.grey.withOpacity(0.1), // hold effect color
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              note.content,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
