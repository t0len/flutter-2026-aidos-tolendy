import 'dart:convert';

import 'package:prac12/core/api/api_client.dart';
import 'package:prac12/core/api/api_exception.dart';
import 'package:prac12/features/users/user.dart';
import 'package:prac12/features/users/users_cache.dart';

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<({List<User> items, bool fromCache})> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<User> getById(int id) async {
    final uri = Uri.https(_api.host, '/users/$id');
    final response = await _api.get(uri);
    return _user(response.body, 'users/$id');
  }

  Future<User> create(User draft) async {
    final uri = Uri.https(_api.host, '/users');
    final response = await _api.post(uri, body: jsonEncode(draft.toJson()));
    if (response.statusCode != 201) {
      throw BadResponseException('users: ${response.statusCode}');
    }
    return _user(response.body, 'users');
  }

  Future<List<User>> _fetch() async {
    final uri = Uri.https(_api.host, '/users');
    final response = await _api.get(uri);
    return _users(response.body, 'users');
  }

  List<User> _users(dynamic decoded, String where) {
    try {
      final list = decoded as List<dynamic>;
      return [
        for (final item in list) User.fromJson(item as Map<String, dynamic>),
      ];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException('$where: $e');
    }
  }

  User _user(dynamic decoded, String where) {
    try {
      return User.fromJson(decoded as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
