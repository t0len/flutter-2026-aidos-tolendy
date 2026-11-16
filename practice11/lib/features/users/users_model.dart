import 'package:flutter/foundation.dart';
import 'package:prac11/core/api/api_exception.dart';
import 'package:prac11/features/users/user.dart';
import 'package:prac11/features/users/user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
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
      return created;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
