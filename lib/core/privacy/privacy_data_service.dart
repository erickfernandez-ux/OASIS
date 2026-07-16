import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/local_json_store.dart';
import 'privacy_cipher.dart';
import 'privacy_pin_service.dart';
import 'privacy_store_manifest.dart';

class PrivacyStorageStat {
  const PrivacyStorageStat({
    required this.key,
    required this.label,
    required this.bytes,
  });

  final String key;
  final String label;
  final int bytes;
}

class PrivacyBackupResult {
  const PrivacyBackupResult({
    required this.fileName,
    required this.filePath,
    required this.bytes,
  });

  final String fileName;
  final String filePath;
  final List<int> bytes;
}

class PrivacyDataService {
  PrivacyDataService._();

  static Future<List<PrivacyStorageStat>> collectStats() async {
    final stats = <PrivacyStorageStat>[];
    for (final entry in PrivacyStoreManifest.storageLabels.entries) {
      final bytes = await LocalJsonStore.sizeInBytes(entry.key);
      stats.add(PrivacyStorageStat(
        key: entry.key,
        label: entry.value,
        bytes: bytes,
      ));
    }
    return stats;
  }

  static Future<PrivacyBackupResult> exportEncryptedBackup() async {
    const payloadKeys = PrivacyStoreManifest.backupKeys;
    final payloads = await LocalJsonStore.exportPayloads(payloadKeys);
    final encrypted = await PrivacyCipher.encryptString(
      jsonEncode({
        'format': 'oasis_backup_v1',
        'exportedAt': DateTime.now().toIso8601String(),
        'payloads': payloads,
      }),
    );

    const fileName = 'OASIS_Backup.enc';
    if (kIsWeb) {
      final bytes = utf8.encode(encrypted);
      return PrivacyBackupResult(
        fileName: fileName,
        filePath: fileName,
        bytes: bytes,
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    final bytes = utf8.encode(encrypted);
    await file.writeAsBytes(bytes, flush: true);
    return PrivacyBackupResult(
      fileName: fileName,
      filePath: file.path,
      bytes: bytes,
    );
  }

  static Future<void> wipeAllUserData() async {
    await LocalJsonStore.writeList(PrivacyStoreManifest.journalKey, const <dynamic>[]);
    await LocalJsonStore.writeList(PrivacyStoreManifest.notesKey, const <dynamic>[]);
    await LocalJsonStore.writeList(PrivacyStoreManifest.medicationsKey, const <dynamic>[]);
    await LocalJsonStore.writeMap(PrivacyStoreManifest.safetyPlanKey, {
      'warningSigns': const <String>[],
      'selfActions': const <String>[],
      'safePlaces': const <String>[],
      'contacts': const <dynamic>[],
      'professionals': const <dynamic>[],
      'reasonsToStay': const <String>[],
      'crisisMode': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await LocalJsonStore.writeMap(PrivacyStoreManifest.wellbeingStateKey, {
      'dailyGoalMl': 2000,
      'completedPomodoroSessions': 0,
      'pomodoroRunning': false,
      'waterEntries': const <dynamic>[],
      'medicationLog': const <dynamic>[],
    });
    await LocalJsonStore.writeList(PrivacyStoreManifest.agendaTasksKey, const <dynamic>[]);
    await LocalJsonStore.writeList(PrivacyStoreManifest.calendarEventsKey, const <dynamic>[]);
    await LocalJsonStore.delete(PrivacyStoreManifest.ritualsStateKey);
    await PrivacyPinService.clearPin();
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String platformProtectionDescription() {
    if (kIsWeb) {
      return 'En web, OASIS usa el backend disponible del navegador y no cuenta con Android Keystore ni Keychain.';
    }
    return 'En Android la clave se protege con Android Keystore y en iOS con Keychain mediante flutter_secure_storage.';
  }
}
