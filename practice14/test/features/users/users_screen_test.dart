import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prac14/features/users/users_model.dart';
import 'package:prac14/features/users/users_screen.dart';

import '../../fakes/fake_user_repository.dart';

import 'package:provider/provider.dart';

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    final model = UsersModel(FakeUserRepository(fail: true));
    await tester.runAsync(model.load);
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: model,
          child: const UsersScreen(),
        ),
      ),
    );
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(Duration.zero);
  });
}
