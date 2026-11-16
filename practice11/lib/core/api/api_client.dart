import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  factory ApiClient.connected() => ApiClient(http.Client());

  final http.Client _client;
  final String host;

  Map<String, String> get headers => const {'Accept': 'application/json'};

  Future<http.Response> get(Uri uri) async {
    final response = await _send(() => _client.get(uri, headers: headers));
    _check(response);
    return response;
  }

  Future<http.Response> post(Uri uri, {required String body}) async {
    final response = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: body,
      ),
    );
    _check(response);
    return response;
  }

  dynamic decode(http.Response response) => _decode(response);

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      assert(() {
        log(
          '${response.request?.method} ${response.statusCode} ${response.request?.url}',
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

  void _check(http.Response r) {
    if (r.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (r.statusCode == 404) {
      throw const NotFoundException();
    }
    if (r.statusCode >= 500) {
      throw ServerException(r.statusCode);
    }
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }
}
