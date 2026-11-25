import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:prac13/core/api/api_exception.dart';
import 'package:prac13/core/storage/secure_store.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  factory ApiClient.connected(
    SecureStore store, {
    String host = 'jsonplaceholder.typicode.com',
  }) {
    return ApiClient(http.Client(), store, host: host);
  }

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<({int statusCode, dynamic body})> get(Uri uri) async {
    final headers = await _headers();
    final response = await _send(() => _client.get(uri, headers: headers));
    _check(response);
    return (statusCode: response.statusCode, body: _decode(response));
  }

  Future<({int statusCode, dynamic body})> post(
    Uri uri, {
    required String body,
  }) async {
    final headers = await _headers(json: true);
    final response = await _send(
      () => _client.post(uri, headers: headers, body: body),
    );
    _check(response);
    return (statusCode: response.statusCode, body: _decode(response));
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _store.readToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token case final t?) 'Authorization': 'Bearer $t',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      assert(() {
        log(
          '${response.request?.method} ${response.statusCode} '
          '${response.request?.url}',
          name: 'api',
        );
        return true;
      }());
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response) {
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (response.statusCode == 404) {
      throw const NotFoundException();
    }
    if (response.statusCode >= 500) {
      throw ServerException(response.statusCode);
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }
}
