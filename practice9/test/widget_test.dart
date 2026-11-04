import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prac9/main.dart';

void main() {
  testWidgets('Add updates the row and the badge from the same list', (
    tester,
  ) async {
    await tester.pumpWidget(const Shell());

    expect(find.text('Widgets All the Way Down'), findsOneWidget);
    expect(find.text('Added'), findsNothing);
    expect(find.text('0 · 0'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();

    expect(find.text('Added'), findsOneWidget);
    expect(find.text('1 · 4200'), findsOneWidget);

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Widgets All the Way Down'), findsOneWidget);
    expect(find.text('Total: 4200 ₸'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();

    expect(find.text('Total: 0 ₸'), findsOneWidget);
  });
}
