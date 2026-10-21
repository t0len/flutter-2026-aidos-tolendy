import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute<BookAction>(
        builder: (context) => DetailScreen(book: book),
      ),
    );
    if (!mounted) {
      return;
    }
    switch (action) {
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
      case BookAction.delete:
        setState(() => _books.remove(book));
      case null:
        break;
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context).push<Book>(
      MaterialPageRoute<Book>(builder: (context) => const AddBookScreen()),
    );
    if (!mounted) {
      return;
    }
    if (book == null) {
      return;
    }
    setState(() => _books.add(book));
  }

  String _filterLabel(Filter filter) => switch (filter) {
    Filter.all => 'All',
    Filter.unread => 'Unread',
    Filter.read => 'Read',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${_visible.length})')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                      value: '${_books.length}',
                      label: 'Books',
                      textTheme: textTheme,
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      value: '${totalPages(_books)}',
                      label: 'Pages',
                      textTheme: textTheme,
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      value: '${unread(_books).length}',
                      label: 'Unread',
                      textTheme: textTheme,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final filter in Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(filter)),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final book = _visible[index];
                return BookTile(
                  book: book,
                  onToggle: () => setState(() => book.read = !book.read),
                  onTap: () => _openDetail(book),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBook(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.textTheme,
  });

  final String value;
  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(label, style: textTheme.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}
