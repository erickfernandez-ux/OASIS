import 'dart:convert';

import '../privacy/privacy_cipher.dart';
import '../privacy/privacy_store_manifest.dart';
import 'local_json_store_io.dart'
    if (dart.library.html) 'local_json_store_web.dart' as backend;

class LocalJsonStore {
  LocalJsonStore._();

  static Future<Map<String, dynamic>?> readMap(String key) async {
    final raw = await backend.LocalJsonStoreBackend.readRawString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final normalized = await _normalizedJsonString(key, raw);
    final decoded = jsonDecode(normalized);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    return null;
  }

  static Future<List<dynamic>?> readList(String key) async {
    final raw = await backend.LocalJsonStoreBackend.readRawString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final normalized = await _normalizedJsonString(key, raw);
    final decoded = jsonDecode(normalized);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    return null;
  }

  static Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await _writeJsonString(key, jsonEncode(value));
  }

  static Future<void> writeList(String key, List<dynamic> value) async {
    await _writeJsonString(key, jsonEncode(value));
  }

  static Future<void> delete(String key) async {
    await backend.LocalJsonStoreBackend.delete(key);
  }

  static Future<int> sizeInBytes(String key) async {
    return backend.LocalJsonStoreBackend.sizeInBytes(key);
  }

  static Future<Map<String, String>> exportPayloads(Iterable<String> keys) async {
    final entries = <String, String>{};
    for (final key in keys) {
      final raw = await backend.LocalJsonStoreBackend.readRawString(key);
      if (raw != null && raw.isNotEmpty) {
        entries[key] = raw;
      }
    }
    return entries;
  }

  static Future<void> deleteMany(Iterable<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  static Future<void> _writeJsonString(String key, String jsonString) async {
    final payload = PrivacyStoreManifest.isSensitiveKey(key)
        ? await PrivacyCipher.encryptString(jsonString)
        : jsonString;
    await backend.LocalJsonStoreBackend.writeRawString(key, payload);
  }

  static Future<String> _normalizedJsonString(String key, String raw) async {
    if (PrivacyCipher.isEncryptedPayload(raw)) {
      return PrivacyCipher.decryptString(raw);
    }

    if (PrivacyStoreManifest.isSensitiveKey(key)) {
      await _writeJsonString(key, raw);
    }

    return raw;
  }
}
