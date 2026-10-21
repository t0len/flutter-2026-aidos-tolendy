import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prac7/main.dart';

Finder field(String label) => find.widgetWithText(TextFormField, label);

Finder signUpButton() => find.widgetWithText(FilledButton, 'Sign up');

void main() {
  testWidgets('empty sign up stays quiet until the box is ticked', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(signUpButton());
    await tester.pump();

    expect(find.text('Name is too short'), findsNothing);
    expect(tester.widget<FilledButton>(signUpButton()).onPressed, isNull);

    await tester.ensureVisible(find.text('I agree to the rules'));
    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();

    await tester.ensureVisible(signUpButton());
    await tester.tap(signUpButton());
    await tester.pump();

    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Email looks wrong'), findsOneWidget);
    expect(find.text('Password is too short'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsNothing);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Choose a date'), findsOneWidget);
  });

  testWidgets('confirm turns red as soon as the passwords differ', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(field('Password'), '12345678');
    await tester.enterText(field('Confirm password'), '12345679');
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.enterText(field('Confirm password'), '12345678');
    await tester.pump();

    expect(find.text('Passwords do not match'), findsNothing);
  });

  testWidgets('action key walks name, email, password, confirm, then submits', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(field('Name'));
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(_hasFocus(tester, 'Email'), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(_hasFocus(tester, 'Password'), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(_hasFocus(tester, 'Confirm password'), isTrue);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Account created'), findsNothing);
  });

  testWidgets('a valid form becomes a summary and start over clears it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await _fillValid(tester);
    await tester.tap(signUpButton());
    await tester.pump();

    expect(find.text('Account created'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@kbtu.kz'), findsOneWidget);
    expect(find.text('IT-2301'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(500, 1200));
    await tester.pump();

    expect(find.byType(GridView), findsNothing);
    expect(find.text('Ada'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('Account created'), findsNothing);

    await tester.tap(find.text('Start over'));
    await tester.pump();

    expect(find.text('Ada'), findsNothing);
    expect(find.text('I agree to the rules'), findsOneWidget);
    expect(tester.widget<FilledButton>(signUpButton()).onPressed, isNull);
    expect(tester.widget<TextFormField>(field('Name')).controller?.text, '');

    await tester.tap(find.text('I agree to the rules'));
    await tester.pump();
    await tester.ensureVisible(signUpButton());
    await tester.tap(signUpButton());
    await tester.pump();

    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Choose a date'), findsOneWidget);
    expect(find.text('Account created'), findsNothing);
  });

  testWidgets('cancel on the date picker keeps the previous date', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(field('Date of birth'));
    await tester.tap(field('Date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final saved = _dateText(tester);
    expect(saved, isNotEmpty);

    await tester.ensureVisible(field('Date of birth'));
    await tester.tap(field('Date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_dateText(tester), saved);
    expect(find.text('Choose a date'), findsNothing);
  });
}

bool _hasFocus(WidgetTester tester, String label) {
  final editable = tester.widget<EditableText>(
    find.descendant(of: field(label), matching: find.byType(EditableText)),
  );
  return editable.focusNode.hasFocus;
}

String _dateText(WidgetTester tester) {
  return tester
      .widget<EditableText>(
        find.descendant(
          of: field('Date of birth'),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;
}

Future<void> _fillValid(WidgetTester tester) async {
  await tester.enterText(field('Name'), 'Ada');
  await tester.enterText(field('Email'), 'ada@kbtu.kz');
  await tester.enterText(field('Password'), '12345678');
  await tester.enterText(field('Confirm password'), '12345678');

  await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('IT-2301').last);
  await tester.pumpAndSettle();

  await tester.ensureVisible(field('Date of birth'));
  await tester.tap(field('Date of birth'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('I agree to the rules'));
  await tester.tap(find.text('I agree to the rules'));
  await tester.pump();
}
