import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:prac12/core/api/api_client.dart';
import 'package:prac12/core/storage/secure_store.dart';
import 'package:prac12/features/auth/auth_model.dart';
import 'package:prac12/features/profile/profile_screen.dart';
import 'package:prac12/features/settings/settings_model.dart';
import 'package:prac12/features/settings/settings_screen.dart';
import 'package:prac12/features/users/user.dart';
import 'package:prac12/features/users/user_repository.dart';
import 'package:prac12/features/users/users_cache.dart';
import 'package:prac12/features/users/users_model.dart';
import 'package:prac12/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'cache round-trips through Documents and is null when missing',
    () async {
      final dir = Directory.systemTemp.createTempSync('users-cache');
      PathProviderPlatform.instance = _FakePaths(dir.path);
      final cache = UsersCache();
      expect(await cache.load(), isNull);

      final sample = _user(1, 'Gwenborough');
      await cache.save([sample]);
      final loaded = await cache.load();
      expect(loaded, isNotNull);
      expect(loaded!.single, sample);
      expect(loaded.single.address.city, 'Gwenborough');
      expect(File('${dir.path}/users.json').existsSync(), isTrue);
    },
  );

  test('the screen updates before the preference write finishes', () async {
    final release = Completer<void>();
    final prefs = _HoldingPrefs(release);
    SharedPreferencesAsyncPlatform.instance = prefs;
    final settings = SettingsModel(
      SharedPreferencesAsync(),
      dark: false,
      city: 'Gwenborough',
    );
    var notifications = 0;
    settings.addListener(() => notifications++);
    final write = settings.setDark(true);
    await prefs.started.future;
    expect(settings.dark, isTrue);
    expect(notifications, 1);
    expect(prefs.finished, isFalse);
    release.complete();
    await write;
    expect(prefs.finished, isTrue);
    expect(await SharedPreferencesAsync().getBool('darkMode'), isTrue);

    await settings.setCity(null);
    expect(settings.city, isNull);
    expect(notifications, 2);
    expect(await SharedPreferencesAsync().getString('cityFilter'), isNull);
  });

  test('login stores the token and logout deletes it', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthModel(const SecureStore());
    expect(auth.signedIn, isFalse);
    await auth.login('ada@kbtu.kz', '12345678');
    expect(auth.signedIn, isTrue);
    expect(await auth.readToken(), 'tok_${'ada@kbtu.kz'.hashCode}');
    await auth.logout();
    expect(auth.signedIn, isFalse);
    expect(await auth.readToken(), isNull);
  });

  test('a short password does not sign in', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final auth = AuthModel(const SecureStore());
    expect(
      () => auth.login('ada@kbtu.kz', 'short'),
      throwsA(isA<FormatException>()),
    );
    expect(auth.signedIn, isFalse);
    expect(await auth.readToken(), isNull);
  });

  testWidgets('dark mode, the city filter, and the stale banner', (
    tester,
  ) async {
    final settings = SettingsModel(
      SharedPreferencesAsync(),
      dark: true,
      city: 'Gwenborough',
    );
    final users = UsersModel(
      UserRepository(ApiClient.connected(const SecureStore()), UsersCache()),
    );
    users.items = [_user(1, 'Gwenborough'), _user(2, 'Wisokyburgh')];
    users.fromCache = true;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider(
            create: (_) => AuthModel(const SecureStore(), token: 'tok'),
          ),
          ChangeNotifierProvider.value(value: users),
        ],
        child: const App(),
      ),
    );

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(find.textContaining('Saved data — no connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('User 1'), findsOneWidget);
    expect(find.text('User 2'), findsNothing);

    users.fromCache = false;
    users.notifyListeners();
    await tester.pump();
    expect(find.textContaining('Saved data'), findsNothing);
    expect(find.text('User 1'), findsOneWidget);
  });

  testWidgets('settings offers dark mode, cities, and sign out', (
    tester,
  ) async {
    final settings = SettingsModel(
      SharedPreferencesAsync(),
      dark: false,
      city: null,
    );
    final users = UsersModel(
      UserRepository(ApiClient.connected(const SecureStore()), UsersCache()),
    );
    users.items = [_user(1, 'Gwenborough')];
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: users),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('All cities'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('the blocked-camera dialog is ours and opens settings', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final result = showDialog<bool>(
      context: tester.element(find.byType(Scaffold)),
      builder: (_) => const CameraBlockedDialog(),
    );
    await tester.pumpAndSettle();
    expect(find.text('Camera is blocked'), findsOneWidget);
    expect(
      find.text(
        'The system will not ask again. Open settings and allow the camera.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });
}

final class _HoldingPrefs extends InMemorySharedPreferencesAsync {
  _HoldingPrefs(this.release) : super.empty();

  final Completer<void> release;
  final started = Completer<void>();
  var finished = false;

  @override
  Future<bool> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) async {
    if (!started.isCompleted) started.complete();
    await release.future;
    final stored = await super.setBool(key, value, options);
    finished = true;
    return stored;
  }
}

class _FakePaths extends PathProviderPlatform {
  _FakePaths(this.documents);

  final String documents;

  @override
  Future<String?> getApplicationDocumentsPath() async => documents;
}

User _user(int id, String city) {
  return User(
    id: id,
    name: 'User $id',
    username: 'u$id',
    email: 'u$id@kbtu.kz',
    phone: '1-770-736-8031 x56442',
    website: 'kbtu.edu.kz',
    address: Address(
      street: 'Street',
      suite: 'Apt',
      city: city,
      zipcode: '1',
      geo: const Geo(lat: 1, lng: 2),
    ),
    company: (name: 'Company', catchPhrase: 'Phrase'),
  );
}
