import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final books = rawBooks.map(Book.fromJson).toList();

  final library = Library();
  for (final book in books) {
    library.add(book);
  }
  library.open();

  library.titles;
  library.booksAfter2010;
  library.averagePages;
  library.booksByAuthor;
  library.authorNames;
  library.genres;
  library.displayList;
  library.report();

  library.countryOf('Refactoring');
  library.countryOf('Design Patterns');

  final clean = library.findByTitle('Clean Code');
  if (clean != null) {
    clean.borrowLabel();
  }

  final mag = Magazine(title: 'Dart Weekly', year: 2024, issue: 42);
  final ghost = Ghost(title: 'The Phantom', year: 1890);
  mag.describe();
  ghost.describe();
  ghost.isOld;

  print(statsOf(books));
  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('Database connection lost')));
}
