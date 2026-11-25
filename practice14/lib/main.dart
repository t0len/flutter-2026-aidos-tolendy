import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prac14/core/api/api_client.dart';
import 'package:prac14/core/env.dart';
import 'package:prac14/core/storage/secure_store.dart';
import 'package:prac14/features/auth/auth_model.dart';
import 'package:prac14/features/auth/login_screen.dart';
import 'package:prac14/features/settings/settings_model.dart';
import 'package:prac14/features/users/fake_user_repository.dart';
import 'package:prac14/features/users/user_repository.dart';
import 'package:prac14/features/users/users_cache.dart';
import 'package:prac14/features/users/users_model.dart';
import 'package:prac14/features/users/users_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef DemoUserRepository = FakeUserRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatar = await prefs.getString('avatarPath');
  final apiHost = await prefs.getString('apiHost');

  final store = const SecureStore();
  final token = await store.readToken();
  final settings = SettingsModel(
    prefs,
    dark: dark,
    city: city,
    avatarPath: avatar,
    apiHost: apiHost,
  );
  final api = ApiClient.connected(
    store,
    host: Env.host,
    hostOverride: () {
      if (!kDebugMode) return null;
      final value = settings.apiHost;
      if (value == null || value.isEmpty) return null;
      return value;
    },
  );
  final UserRepository repo = Env.useFakes
      ? FakeUserRepository()
      : HttpUserRepository(api, UsersCache());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token: token)),
        ChangeNotifierProvider(
          create: (_) {
            final model = UsersModel(repo);
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
    final signedIn = context.watch<AuthModel>().signedIn;
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
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}
