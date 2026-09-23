import 'dart:convert';
import 'dart:io';

import 'remote.dart';

class BackupStatus {
  BackupStatus({required this.at, required this.targets, required this.errors});

  final DateTime? at;
  final List<String> targets;
  final List<String> errors;

  bool get healthy => errors.isEmpty && at != null;

  bool get stale =>
      at == null || DateTime.now().difference(at!) > const Duration(days: 1);

  static BackupStatus empty() =>
      BackupStatus(at: null, targets: const [], errors: const []);
}

class BackupService {
  BackupService(this._settingsFile);

  final File _settingsFile;
  static const int keepCopies = 30;

  List<String> targets = [
    r'E:\ACCESS\keyhold',
    r'D:\_KOPIA_ACCESS\keyhold',
  ];

  RemoteConfig remote = RemoteConfig();
  String bridgeToken = '';
  List<String>? watched;

  /// Google Drive sync: the refresh token is kept DPAPI-protected, base64.
  String driveToken = '';
  String driveEmail = '';
  DateTime? driveSyncedAt;
  BackupStatus status = BackupStatus.empty();

  void loadSettings() {
    if (!_settingsFile.existsSync()) return;
    try {
      final raw = jsonDecode(_settingsFile.readAsStringSync()) as Map<String, dynamic>;
      final list = (raw['backupTargets'] as List<dynamic>?)?.cast<String>();
      if (list != null && list.isNotEmpty) targets = list;

      final remoteJson = raw['remote'] as Map<String, dynamic>?;
      if (remoteJson != null) remote = RemoteConfig.fromJson(remoteJson);

      bridgeToken = (raw['bridgeToken'] ?? '') as String;
      watched = (raw['watched'] as List<dynamic>?)?.cast<String>();
      driveToken = (raw['driveToken'] ?? '') as String;
      driveEmail = (raw['driveEmail'] ?? '') as String;
      driveSyncedAt = DateTime.tryParse((raw['driveSyncedAt'] ?? '') as String);

      final at = raw['lastBackupAt'] as String?;
      status = BackupStatus(
        at: at == null ? null : DateTime.tryParse(at),
        targets: (raw['lastBackupTargets'] as List<dynamic>?)?.cast<String>() ?? const [],
        errors: const [],
      );
    } catch (_) {
      // a broken settings file must never stop the app from opening
    }
  }

  void saveSettings() {
    _settingsFile.writeAsStringSync(jsonEncode({
      'backupTargets': targets,
      'remote': remote.toJson(),
      'bridgeToken': bridgeToken,
      if (watched != null) 'watched': watched,
      if (driveToken.isNotEmpty) 'driveToken': driveToken,
      if (driveEmail.isNotEmpty) 'driveEmail': driveEmail,
      if (driveSyncedAt != null) 'driveSyncedAt': driveSyncedAt!.toIso8601String(),
      'lastBackupAt': status.at?.toIso8601String(),
      'lastBackupTargets': status.targets,
    }));
  }

  Future<BackupStatus> run(File vault) async {
    final stamp = DateTime.now()
        .toIso8601String()
        .substring(0, 16)
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('T', '-');

    final name = 'vault-$stamp.khd';
    final done = <String>[];
    final errors = <String>[];

    for (final target in targets) {
      try {
        final dir = Directory(target);
        dir.createSync(recursive: true);
        await vault.copy('${dir.path}${Platform.pathSeparator}$name');
        _trim(dir);
        done.add(target);
      } catch (e) {
        errors.add('$target: $e');
      }
    }

    if (remote.configured) {
      try {
        final client = RemoteClient(remote);
        await client.upload(vault, name).timeout(const Duration(seconds: 25));
        await client.trim(keepCopies).timeout(const Duration(seconds: 25));
        done.add(remote.host);
      } catch (e) {
        errors.add('${remote.host}: $e');
      }
    }

    status = BackupStatus(at: DateTime.now(), targets: done, errors: errors);
    try {
      saveSettings();
    } catch (_) {
      // settings are a convenience, not a reason to fail a backup
    }
    return status;
  }

  void _trim(Directory dir) {
    final copies = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('vault-') && f.path.endsWith('.khd'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in copies.skip(keepCopies)) {
      try {
        old.deleteSync();
      } catch (_) {
        // a locked file just stays until the next run
      }
    }
  }
}
