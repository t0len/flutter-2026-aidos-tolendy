import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:prac12/core/api/api_exception.dart';
import 'package:prac12/features/users/user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    final encoded = jsonEncode([for (final user in list) user.toJson()]);
    await file.writeAsString(encoded);
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final raw = jsonDecode(await file.readAsString());
    if (raw is! List) {
      throw const BadResponseException('users.json');
    }
    try {
      return [
        for (final item in raw)
          User.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (e) {
      throw BadResponseException('users.json: $e');
    }
  }
}
