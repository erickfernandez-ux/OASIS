import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'privacy_storage_key_store.dart';

class PrivacyPinService {
  PrivacyPinService._();

  static final _sha256 = Sha256();

  static Future<void> savePin(String pin) async {
    final hash = await _hash(pin);
    await PrivacyStorageKeyStore.writePinHash(hash);
  }

  static Future<bool> hasPin() async {
    final value = await PrivacyStorageKeyStore.readPinHash();
    return value != null && value.isNotEmpty;
  }

  static Future<bool> verifyPin(String pin) async {
    final stored = await PrivacyStorageKeyStore.readPinHash();
    if (stored == null || stored.isEmpty) {
      return false;
    }
    return stored == await _hash(pin);
  }

  static Future<void> clearPin() async {
    await PrivacyStorageKeyStore.clearPinHash();
  }

  static Future<String> _hash(String value) async {
    final digest = await _sha256.hash(utf8.encode(value));
    return base64Encode(digest.bytes);
  }
}
