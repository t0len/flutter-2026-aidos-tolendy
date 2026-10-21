import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (confirmed == true) {
      Navigator.pop(context, BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final yearText = book.year == null ? 'Year unknown' : 'Year: ${book.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(book.title, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(book.author, style: textTheme.titleMedium),
          const SizedBox(height: 16),
          Text('Pages: ${book.pages}', style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(yearText, style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(book.read ? 'Read' : 'Unread', style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context, BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => _confirmDelete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
