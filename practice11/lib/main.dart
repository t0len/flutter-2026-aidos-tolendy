import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prac11/core/api/api_client.dart';
import 'package:prac11/features/users/user_repository.dart';
import 'package:prac11/features/users/users_model.dart';
import 'package:prac11/features/users/users_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const UsersApp());
}

class UsersApp extends StatelessWidget {
  const UsersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final model = UsersModel(UserRepository(ApiClient.connected()));
        unawaited(model.load());
        return model;
      },
      child: MaterialApp(
        title: 'Users',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const UsersScreen(),
      ),
    );
  }
}
