import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'privacy_platform.dart';

class PrivacyStorageKeyStore {
  PrivacyStorageKeyStore._();

  static const _masterKeyName = 'oasis_master_key_v1';
  static const _pinHashName = 'oasis_pin_hash_v1';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static final _random = Random.secure();
  static final Map<String, String> _memoryStore = {};

  static bool get _useSecureStorage {
    return isMobilePrivacyPlatform();
  }

  static Future<List<int>> getOrCreateMasterKey() async {
    if (!_useSecureStorage) {
      final existing = _memoryStore[_masterKeyName];
      if (existing != null && existing.isNotEmpty) {
        return base64Decode(existing);
      }
      return List<int>.generate(32, (index) => index + 1, growable: false);
    }

    final existing = await _storage.read(key: _masterKeyName);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }

    final generated = List<int>.generate(32, (_) => _random.nextInt(256), growable: false);
    await _storage.write(
      key: _masterKeyName,
      value: base64Encode(generated),
    );
    return generated;
  }

  static Future<void> writePinHash(String hash) async {
    if (!_useSecureStorage) {
      _memoryStore[_pinHashName] = hash;
      return;
    }
    await _storage.write(key: _pinHashName, value: hash);
  }

  static Future<String?> readPinHash() async {
    if (!_useSecureStorage) {
      return _memoryStore[_pinHashName];
    }
    return _storage.read(key: _pinHashName);
  }

  static Future<void> clearPinHash() async {
    if (!_useSecureStorage) {
      _memoryStore.remove(_pinHashName);
      return;
    }
    await _storage.delete(key: _pinHashName);
  }

  static Future<void> clearAllSecrets() async {
    if (!_useSecureStorage) {
      _memoryStore.remove(_masterKeyName);
      _memoryStore.remove(_pinHashName);
      return;
    }
    await _storage.delete(key: _masterKeyName);
    await _storage.delete(key: _pinHashName);
  }
}
