import 'models.dart';


sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
      Empty() => 'The shelf is empty.',
      Ready(books: final books) => 'Shelf ready with ${books.length} book(s).',
      Broken(message: final msg) => 'Shelf broken: $msg',
    };

({int count, double avgPages}) statsOf(List<Book> books) {
  final total = books.fold<int>(0, (sum, b) => sum + b.pages);
  return (count: books.length, avgPages: books.isEmpty ? 0.0 : total / books.length);
}
