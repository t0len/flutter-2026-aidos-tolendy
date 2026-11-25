import 'dart:convert';

import 'package:prac14/core/api/api_client.dart';
import 'package:prac14/core/api/api_exception.dart';
import 'package:prac14/features/users/user.dart';
import 'package:prac14/features/users/users_cache.dart';

class UsersResult {
  const UsersResult({required this.items, required this.fromCache});

  final List<User> items;
  final bool fromCache;
}

abstract interface class UserRepository {
  Future<UsersResult> getAll();
  Future<User> getById(int id);
  Future<User> create(User draft);
}

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  @override
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return UsersResult(items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return UsersResult(items: saved, fromCache: true);
    }
  }

  @override
  Future<User> getById(int id) async {
    final uri = _api.uri('/users/$id');
    final response = await _api.get(uri);
    return _one(response.body, 'users/$id');
  }

  @override
  Future<User> create(User draft) async {
    final uri = _api.uri('/users');
    final response = await _api.post(uri, body: jsonEncode(draft.toJson()));
    if (response.statusCode != 201) {
      throw BadResponseException('users: ${response.statusCode}');
    }
    return _one(response.body, 'users');
  }

  Future<List<User>> _fetch() async {
    final uri = _api.uri('/users');
    final response = await _api.get(uri);
    return _users(response.body, 'users');
  }

  List<User> _users(dynamic decoded, String where) {
    try {
      final list = decoded as List<dynamic>;
      return [for (final item in list) _one(item, where)];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException('$where: $e');
    }
  }

  User _one(dynamic decoded, String where) {
    try {
      final json = Map<String, dynamic>.from(decoded as Map);
      return User.fromJson(json);
    } on ApiException {
      rethrow;
    } on TypeError catch (e) {
      throw BadResponseException(_detail(decoded, where, e));
    } catch (e) {
      throw BadResponseException('$where: $e');
    }
  }

  String _detail(dynamic decoded, String where, TypeError error) {
    if (decoded is Map) {
      final address = decoded['address'];
      if (address is Map) {
        final geo = address['geo'];
        if (geo is Map && geo['lat'] is! String) {
          return '$where: lat is not a String';
        }
      }
    }
    return '$where: $error';
  }
}
