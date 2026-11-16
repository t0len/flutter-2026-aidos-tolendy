import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required this.dark,
    required this.city,
    this.avatarPath,
  });

  final SharedPreferencesAsync _prefs;
  bool dark;
  String? city;
  String? avatarPath;

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();
    await _prefs.setBool('darkMode', value);
  }

  Future<void> setCity(String? value) async {
    city = value;
    notifyListeners();
    if (value == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', value);
    }
  }

  Future<void> setAvatar(String path) async {
    avatarPath = path;
    notifyListeners();
    await _prefs.setString('avatarPath', path);
  }
}
