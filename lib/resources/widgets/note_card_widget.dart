import 'package:flutter/material.dart';
import 'package:flutter_app/app/storage/note_storage_service.dart';
import '../../app/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final LayoutMode layout;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.layout,
  });

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = note.createdAt;
    final dateText = _formatDate(createdAt);

    if (layout == LayoutMode.list) {
      // 📋 List style (date + title inside card)
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !note.title.isEmpty
                  ? Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : SizedBox(),
              Text(
                dateText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
          subtitle: Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: onTap,
        ),
      );
    }

    // 🟥 Grid style (title + date centered under the card)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 3 / 4, // width : height
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip
                    .antiAlias, // needed so ripple stays inside rounded corners
                child: InkWell(
                  onTap: onTap,
                  onLongPress: () {
                    // handle long press here
                  },
                  splashColor: Colors.grey.withOpacity(0.2), // ripple color
                  highlightColor:
                      Colors.grey.withOpacity(0.1), // hold effect color
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
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          !note.title.isEmpty
              ? note.title
              : 'Note created day ${note.createdAt.day}-${note.createdAt.month}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          dateText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
