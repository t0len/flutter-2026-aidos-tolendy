import 'package:flutter/foundation.dart';
import 'package:prac14/core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {String? token}) {
    _token = token;
  }

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) {
      throw const FormatException('Password is too short');
    }
    final token = 'tok_${email.hashCode}';
    await _store.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }

  Future<String?> readToken() => _store.readToken();
}
