import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prac6/main.dart';

void main() {
  testWidgets('list opens detail and keeps the row', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
    expect(find.text('Yerlan Sadyk'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();

    expect(find.text('aida@kbtu.kz'), findsOneWidget);
    expect(find.text('IT-2302'), findsWidgets);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.mail), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Aida Akhmetova'), findsOneWidget);
  });

  testWidgets(
    'clean back changes nothing, dirty back asks, save returns the name',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Aida Akhmetova'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Aida Akhmetova'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Q');
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Q'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Aida Akhmetova'), findsOneWidget);
      expect(find.text('Q'), findsNothing);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Aida Test');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Aida Test'), findsOneWidget);
      expect(find.text('aida@kbtu.kz'), findsOneWidget);
    },
  );
}
