import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final b in books)
        if (q.isEmpty ||
            b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q))
          b,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          for (final b in shown) _BookTile(key: ValueKey(b.title), book: b),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final inCart = context.select<Cart, bool>((c) => c.qtyOf(book) > 0);
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
