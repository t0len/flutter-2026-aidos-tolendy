import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  const SecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) {
    return _storage.write(key: 'token', value: token);
  }

  Future<String?> readToken() => _storage.read(key: 'token');

  Future<void> clear() => _storage.delete(key: 'token');
}
