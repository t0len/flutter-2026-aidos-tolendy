import 'package:flutter/foundation.dart';

import 'book.dart';

class Cart extends ChangeNotifier {
  final Map<Book, int> _qty = {};

  List<Book> get items => List.unmodifiable(_qty.keys.toList());

  int get count => _qty.length;

  int qtyOf(Book b) => _qty[b] ?? 0;

  int get total => _qty.entries.fold<int>(
    0,
    (sum, entry) => sum + entry.key.price * entry.value,
  );

  bool add(Book b) {
    if (_qty.containsKey(b)) return false;
    _qty[b] = 1;
    notifyListeners();
    return true;
  }

  void remove(Book b) {
    _qty.remove(b);
    notifyListeners();
  }

  void increment(Book b) {
    final current = _qty[b];
    if (current == null) return;
    _qty[b] = current + 1;
    notifyListeners();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
  }
}
