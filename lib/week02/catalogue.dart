import 'models.dart';



class Library {
  final List<LibraryItem> items;

  late final DateTime openedAt;

  String? _cachedReport;

  Library() : items = [];

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  void open() {
    openedAt = DateTime.now();
  }

  String report() {
    _cachedReport ??= _buildReport();
    return _cachedReport as String;
  }

  String _buildReport() {
    final buffer = StringBuffer('=== Library Report ===\n');
    for (final item in items) {
      buffer.writeln(item.describe());
    }
    return buffer.toString();
  }


  List<String> get titles =>
      items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((b) => b.year > 2010).toList();

  double get averagePages =>
      items.whereType<Book>().fold<int>(0, (sum, b) => sum + b.pages) /
      items.whereType<Book>().length;

  Map<String, int> get booksByAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        {},
        (map, b) => map..update(b.author.name, (c) => c + 1, ifAbsent: () => 1),
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get genres =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayList => [
        'CATALOGUE',
        for (final b in items.whereType<Book>()) '${b.title} (${b.year})',
        ...items.whereType<Book>().map((b) => b.author.name),
        if (items.whereType<Book>().any((b) => b.pages == 0)) '(incomplete data)',
      ];
}
