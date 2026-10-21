import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _unfocus(PointerDownEvent _) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        title: _title.text.trim(),
        author: _author.text.trim(),
        pages: int.parse(_pages.text),
        year: int.tryParse(_year.text),
      );
      Navigator.pop(context, book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add book')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title'),
                onTapOutside: _unfocus,
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'At least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _author,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Author'),
                onTapOutside: _unfocus,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pages,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Pages'),
                onTapOutside: _unfocus,
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n <= 0) {
                    return 'A whole number above 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Year'),
                onTapOutside: _unfocus,
                onFieldSubmitted: (_) => _save(),
                validator: (value) {
                  final text = value ?? '';
                  if (text.isEmpty) {
                    return null;
                  }
                  final n = int.tryParse(text);
                  final latest = DateTime.now().year;
                  if (n == null || n < 1450 || n > latest) {
                    return 'A year from 1450 to $latest';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
