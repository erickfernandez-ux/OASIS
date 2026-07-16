import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'privacy_storage_key_store.dart';

class PrivacyCipher {
  PrivacyCipher._();

  static const _marker = 'oasis_enc_v1';
  static final _cipher = AesGcm.with256bits();
  static final _random = Random.secure();

  static Future<String> encryptString(String plainText) async {
    final keyBytes = await PrivacyStorageKeyStore.getOrCreateMasterKey();
    final secretKey = SecretKey(keyBytes);
    final nonce = List<int>.generate(12, (_) => _random.nextInt(256), growable: false);
    final secretBox = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: nonce,
    );

    return jsonEncode({
      'marker': _marker,
      'alg': 'aes-256-gcm',
      'nonce': base64Encode(secretBox.nonce),
      'cipherText': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  static Future<String> decryptString(String encoded) async {
    final envelope = jsonDecode(encoded);
    if (envelope is! Map) {
      throw const FormatException('Invalid encrypted payload');
    }
    final json = envelope.cast<String, dynamic>();
    if (json['marker'] != _marker) {
      throw const FormatException('Payload is not encrypted');
    }

    final keyBytes = await PrivacyStorageKeyStore.getOrCreateMasterKey();
    final secretKey = SecretKey(keyBytes);
    final secretBox = SecretBox(
      base64Decode((json['cipherText'] as String?) ?? ''),
      nonce: base64Decode((json['nonce'] as String?) ?? ''),
      mac: Mac(base64Decode((json['mac'] as String?) ?? '')),
    );

    final clear = await _cipher.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clear);
  }

  static bool isEncryptedPayload(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map && decoded['marker'] == _marker;
    } catch (_) {
      return false;
    }
  }
}
