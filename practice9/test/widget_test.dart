import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prac9/main.dart';
import 'package:prac9/models/cart.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('books, badge, cart quantity, search and clear', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const ShopApp()),
    );

    expect(find.text('Widgets All the Way Down'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').at(0));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').at(0));
    await tester.pump();

    expect(find.text('Added'), findsWidgets);
    expect(find.widgetWithText(SnackBar, 'Added'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));

    await tester.enterText(find.byType(TextField), 'Null');
    await tester.pump();
    expect(find.text('Null Safety for Humans'), findsOneWidget);
    expect(find.text('Widgets All the Way Down'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('×1'), findsNWidgets(2));
    expect(find.text('7300 ₸'), findsOneWidget);

    await tester.tap(find.byTooltip('Add one').first);
    await tester.pump();

    expect(find.text('×2'), findsOneWidget);
    expect(find.text('11500 ₸'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('11500 ₸'), findsOneWidget);

    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('0 ₸'), findsOneWidget);
    expect(find.text('×2'), findsNothing);
  });
}
