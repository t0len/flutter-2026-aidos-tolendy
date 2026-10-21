import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prac8/main.dart';
import 'package:prac8/models/book.dart';
import 'package:prac8/widgets/book_tile.dart';

void main() {
  test('level 1 model prints the expected lines', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
    expect(
      Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
      'X – Y, 10 pp.',
    );
    expect(
      Book(
        title: 'Null Safety for Humans',
        author: 'B. Seitkali',
        pages: 196,
        year: 2022,
      ).toString(),
      'Null Safety for Humans – B. Seitkali, 196 pp. (2022)',
    );
    expect(
      Book(
        title: 'Constraints Go Down, Sizes Go Up',
        author: 'C. Tashimova',
        pages: 320,
      ).toString(),
      'Constraints Go Down, Sizes Go Up – C. Tashimova, 320 pp.',
    );

    final mapped = Book.fromMap({'title': 'T', 'author': 'A', 'pages': 3});
    expect(mapped.year, isNull);
    expect(mapped.read, isFalse);

    expect(authors(seed), [
      'A. Nurmagambetova',
      'B. Seitkali',
      'C. Tashimova',
      'D. Alibekov',
      'E. Omarova',
    ]);
    expect(
      authors([
        Book(title: 'A', author: 'Ann', pages: 1),
        Book(title: 'B', author: 'Bob', pages: 2),
        Book(title: 'C', author: 'Ann', pages: 3),
      ]),
      ['Ann', 'Bob'],
    );
  });

  testWidgets('header, filters and checkbox stay in sync', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Pages'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(_unreadDots, findsNWidgets(4));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();

    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(find.text('Widgets All the Way Down'), findsNothing);
    expect(find.text('Null Safety for Humans'), findsOneWidget);
    final unreadChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Unread'),
    );
    expect(unreadChip.selected, isTrue);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsNothing);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(
      find.descendant(
        of: find.ancestor(
          of: find.text('Null Safety for Humans'),
          matching: find.byType(BookTile),
        ),
        matching: find.byType(Checkbox),
      ),
    );
    expect(checkbox.value, isTrue);
    expect(_unreadDots, findsNWidgets(3));
    expect(
      find.byKey(const ValueKey('unread-Null Safety for Humans')),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Read'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (2)'), findsOneWidget);
    final readChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Read'),
    );
    expect(readChip.selected, isTrue);
  });

  testWidgets('detail answers with read, cancel and delete', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('The Navigator Is a Stack'));
    await tester.pumpAndSettle();
    expect(find.text('Mark as read'), findsOneWidget);
    expect(find.text('Year: 2020'), findsOneWidget);
    expect(find.text('Pages: 240'), findsOneWidget);
    expect(find.text('D. Alibekov'), findsOneWidget);
    expect(find.text('Unread'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);

    await tester.tap(find.text('The Navigator Is a Stack'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Mark as read'));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(
      find.descendant(
        of: find.ancestor(
          of: find.text('The Navigator Is a Stack'),
          matching: find.byType(BookTile),
        ),
        matching: find.byType(Checkbox),
      ),
    );
    expect(checkbox.value, isTrue);

    await tester.tap(find.text('Constraints Go Down, Sizes Go Up'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text("Delete 'Constraints Go Down, Sizes Go Up'?"),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Constraints Go Down, Sizes Go Up'), findsNothing);
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('900'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('empty form shows three errors and back adds nothing', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('At least 2 characters'), findsOneWidget);
    expect(find.text('Enter an author'), findsOneWidget);
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.textContaining('1450'), findsNothing);
    expect(find.text('Add book'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ab');
    await tester.enterText(find.byType(TextFormField).at(1), 'F. Author');
    await tester.enterText(find.byType(TextFormField).at(2), 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(find.text('Add book'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), '40');
    await tester.enterText(find.byType(TextFormField).at(3), '1200');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1450'), findsOneWidget);
    expect(find.text('Add book'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(3), '');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Reading list (6)'), findsOneWidget);
    expect(find.text('1260'), findsOneWidget);
    expect(find.text('ab'), findsOneWidget);

    await tester.tap(find.text('ab'));
    await tester.pumpAndSettle();
    expect(find.text('Year unknown'), findsOneWidget);
    expect(find.text('Unread'), findsWidgets);
  });
}

final _unreadDots = find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('unread-');
});

void _resetSeed() {
  for (final book in seed) {
    book.read = book.title == 'Widgets All the Way Down';
  }
}

Future<void> _pumpApp(WidgetTester tester) async {
  _resetSeed();
  await tester.binding.setSurfaceSize(const Size(400, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}
