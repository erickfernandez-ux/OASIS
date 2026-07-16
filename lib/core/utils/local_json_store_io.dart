import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalJsonStoreBackend {
  LocalJsonStoreBackend._();

  static bool get _isTest {
    return const bool.fromEnvironment('FLUTTER_TEST') ||
        Platform.environment.containsKey('FLUTTER_TEST');
  }

  static Future<String?> readRawString(String key) async {
    if (_isTest) return null;
    final file = await _fileFor(key);
    if (!await file.exists()) {
      return null;
    }

    try {
      return file.readAsString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeRawString(String key, String value) async {
    if (_isTest) return;
    final file = await _fileFor(key);
    await file.writeAsString(value, flush: true);
  }

  static Future<void> delete(String key) async {
    if (_isTest) return;
    final file = await _fileFor(key);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<int> sizeInBytes(String key) async {
    if (_isTest) return 0;
    final file = await _fileFor(key);
    if (!await file.exists()) {
      return 0;
    }
    return file.length();
  }

  static Future<File> _fileFor(String key) async {
    final supportDir = await getApplicationSupportDirectory();
    final storageDir = Directory(
      '${supportDir.path}${Platform.pathSeparator}oasis_storage',
    );
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }

    final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File(
      '${storageDir.path}${Platform.pathSeparator}$safeKey.json',
    );
  }
}
