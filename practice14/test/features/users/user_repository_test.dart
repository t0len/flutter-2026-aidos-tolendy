import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prac14/core/api/api_client.dart';
import 'package:prac14/core/api/api_exception.dart';
import 'package:prac14/core/storage/secure_store.dart';
import 'package:prac14/features/users/user_repository.dart';
import 'package:prac14/features/users/users_cache.dart';

void main() {
  test('404 maps to NotFoundException', () async {
    final repo = _repo((request) async {
      return http.Response('{"error":"gone"}', 404);
    });
    await expectLater(repo.getById(99), throwsA(isA<NotFoundException>()));
  });

  test('500 maps to ServerException', () async {
    final repo = _repo((request) async {
      return http.Response('{"error":"down"}', 500);
    });
    await expectLater(repo.getById(1), throwsA(isA<ServerException>()));
  });

  test('socket failure maps to NoConnectionException', () async {
    final repo = _repo((request) async {
      throw const SocketException('down');
    });
    await expectLater(repo.getById(1), throwsA(isA<NoConnectionException>()));
  });

  test('a numeric lat maps to BadResponseException', () async {
    final list = jsonDecode(_user1List) as List<dynamic>;
    final geo =
        ((list.first as Map)['address'] as Map)['geo'] as Map<String, dynamic>;
    geo['lat'] = -37.3159;
    final repo = _repo((request) async {
      return http.Response(jsonEncode(list), 200);
    });
    await expectLater(
      repo.getAll(),
      throwsA(
        isA<BadResponseException>().having(
          (error) => error.detail,
          'detail',
          'users: lat is not a String',
        ),
      ),
    );
  });
}

HttpUserRepository _repo(
  Future<http.Response> Function(http.Request request) handler,
) {
  return HttpUserRepository(
    ApiClient(MockClient(handler), _MemoryStore()),
    UsersCache(),
  );
}

class _MemoryStore extends SecureStore {
  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> clear() async {}
}

const _user1List = '''
[
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "address": {
      "street": "Kulas Light",
      "suite": "Apt. 556",
      "city": "Gwenborough",
      "zipcode": "92998-3874",
      "geo": {
        "lat": "-37.3159",
        "lng": "81.1496"
      }
    },
    "phone": "1-770-736-8031 x56442",
    "website": "hildegard.org",
    "company": {
      "name": "Romaguera-Crona",
      "catchPhrase": "Multi-layered client-server neural-net",
      "bs": "harness real-time e-markets"
    }
  }
]
''';
