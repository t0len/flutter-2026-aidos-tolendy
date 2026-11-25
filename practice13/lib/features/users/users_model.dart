import 'package:flutter/foundation.dart';
import 'package:prac13/core/api/api_exception.dart';
import 'package:prac13/features/users/user.dart';
import 'package:prac13/features/users/user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;
  bool fromCache = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      items = result.items;
      fromCache = result.fromCache;
    } on ApiException catch (e) {
      error = e;
      fromCache = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<User> create(User draft) async {
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items];
      fromCache = false;
      return created;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
