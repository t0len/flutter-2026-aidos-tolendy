import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:prac11/core/api/api_client.dart';
import 'package:prac11/core/api/api_exception.dart';
import 'package:prac11/features/users/user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final uri = Uri.https(_api.host, '/users');
    final http.Response response = await _api.get(uri);
    return _users(response, 'users');
  }

  Future<User> getById(int id) async {
    final uri = Uri.https(_api.host, '/users/$id');
    final http.Response response = await _api.get(uri);
    return _user(response, 'users/$id');
  }

  Future<User> create(User draft) async {
    final uri = Uri.https(_api.host, '/users');
    final http.Response response = await _api.post(
      uri,
      body: jsonEncode(draft.toJson()),
    );
    if (response.statusCode != 201) {
      throw BadResponseException('users: ${response.statusCode}');
    }
    return _user(response, 'users');
  }

  List<User> _users(http.Response response, String where) {
    try {
      final decoded = _api.decode(response);
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

  User _user(http.Response response, String where) {
    try {
      final decoded = _api.decode(response);
      return User.fromJson(decoded as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
