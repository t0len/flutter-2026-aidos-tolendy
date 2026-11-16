import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:prac12/core/api/api_client.dart';
import 'package:prac12/core/api/api_exception.dart';
import 'package:prac12/core/storage/secure_store.dart';
import 'package:prac12/features/users/user.dart';
import 'package:prac12/features/users/user_repository.dart';
import 'package:prac12/features/users/users_cache.dart';

void main() {
  test(
    'ApiClient adds Authorization and omits it when there is no token',
    () async {
      FlutterSecureStorage.setMockInitialValues({'token': 'tok_7'});
      final headers = <String?>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        headers.add(request.headers.value('authorization'));
        request.response.statusCode = 200;
        request.response.write('[]');
        await request.response.close();
      });
      addTearDown(() => server.close(force: true));
      final store = const SecureStore();
      final uri = Uri.parse('http://127.0.0.1:${server.port}/users');
      await _live(() => ApiClient.connected(store).get(uri));
      FlutterSecureStorage.setMockInitialValues({});
      await _live(() => ApiClient.connected(store).get(uri));
      expect(headers, ['Bearer tok_7', isNull]);
    },
  );

  test(
    'getAll returns the cache offline and rethrows when nothing is saved',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final savedDir = Directory.systemTemp.createTempSync('users-saved');
      PathProviderPlatform.instance = _FakePaths(savedDir.path);
      await UsersCache().save([_user(1, 'Gwenborough')]);
      final saved = await _live(
        () => UserRepository(
          ApiClient.connected(const SecureStore(), host: '127.0.0.1'),
          UsersCache(),
        ).getAll(),
      );
      expect(saved.fromCache, isTrue);
      expect(saved.items.single.name, 'User 1');

      final emptyDir = Directory.systemTemp.createTempSync('users-empty');
      PathProviderPlatform.instance = _FakePaths(emptyDir.path);
      await _live(
        () async => expect(
          () => UserRepository(
            ApiClient.connected(const SecureStore(), host: '127.0.0.1'),
            UsersCache(),
          ).getAll(),
          throwsA(isA<NoConnectionException>()),
        ),
      );
    },
  );
}

Future<T> _live<T>(Future<T> Function() body) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (context) => _DirectHttp().createHttpClient(context),
  );
}

class _DirectHttp extends HttpOverrides {}

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
