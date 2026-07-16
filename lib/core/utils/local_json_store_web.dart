import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalJsonStoreBackend {
  LocalJsonStoreBackend._();

  static const _prefix = 'oasis_json_';

  static Future<String?> readRawString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_composeKey(key));
  }

  static Future<void> writeRawString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_composeKey(key), value);
  }

  static Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_composeKey(key));
  }

  static Future<int> sizeInBytes(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_composeKey(key));
    if (raw == null) {
      return 0;
    }
    return utf8.encode(raw).length;
  }

  static String _composeKey(String key) {
    final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '$_prefix$safeKey';
  }
}
