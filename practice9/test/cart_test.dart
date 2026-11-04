import 'package:flutter_test/flutter_test.dart';
import 'package:prac9/models/book.dart';
import 'package:prac9/models/cart.dart';

void main() {
  test('add, duplicate, remove answers before any widget', () {
    final cart = Cart();
    cart.add(books[0]);
    cart.add(books[1]);
    cart.add(books[0]);
    cart.remove(books[0]);
    expect(cart.count, 1);
    expect(cart.total, 3100);
  });

  test('outside code cannot change the cart behind its back', () {
    final cart = Cart();
    expect(
      () => cart.items.add(books[0]),
      throwsA(
        isA<UnsupportedError>().having(
          (e) => e.message,
          'message',
          contains('Cannot add to an unmodifiable list'),
        ),
      ),
    );
  });

  test('duplicate add notifies nothing and increment multiplies the total', () {
    final cart = Cart();
    var notices = 0;
    cart.addListener(() => notices++);

    expect(cart.add(books[0]), isTrue);
    expect(cart.add(books[0]), isFalse);
    expect(notices, 1);
    expect(cart.qtyOf(books[0]), 1);

    cart.increment(books[0]);
    expect(cart.count, 1);
    expect(cart.qtyOf(books[0]), 2);
    expect(cart.total, 8400);

    cart.clear();
    expect(cart.count, 0);
    expect(cart.total, 0);
  });
}
