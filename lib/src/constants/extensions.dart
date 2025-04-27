import 'package:shared_preferences/shared_preferences.dart';

extension SharedPrefsExtension on SharedPreferences {
  Future<void> setTyped(String key, dynamic value) async {
    if (value is String) {
      await setString(key, value);
    } else if (value is int) await setInt(key, value);
    else if (value is bool) await setBool(key, value);
    else if (value is double) await setDouble(key, value);
    else if (value is List<String>) await setStringList(key, value);
  }

  dynamic getTyped(String key) {
    return get(key);
  }
}
