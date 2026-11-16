import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prac12/core/api/api_client.dart';
import 'package:prac12/core/storage/secure_store.dart';
import 'package:prac12/features/auth/auth_model.dart';
import 'package:prac12/features/auth/login_screen.dart';
import 'package:prac12/features/settings/settings_model.dart';
import 'package:prac12/features/users/user_repository.dart';
import 'package:prac12/features/users/users_cache.dart';
import 'package:prac12/features/users/users_model.dart';
import 'package:prac12/features/users/users_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatar = await prefs.getString('avatarPath');

  final store = const SecureStore();
  final token = await store.readToken();
  final api = ApiClient(http.Client(), store);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, city: city, avatarPath: avatar),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) {
            final model = UsersModel(UserRepository(api, UsersCache()));
            unawaited(model.load());
            return model;
          },
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<SettingsModel>().dark;
    return MaterialApp(
      title: 'Users',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final signedIn = context.watch<AuthModel>().signedIn;
    return signedIn ? const UsersScreen() : const LoginScreen();
  }
}
