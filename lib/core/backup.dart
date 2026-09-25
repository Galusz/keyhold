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

/// A vault this device had open before another one was opened or made; its
/// file stays here and opens again with its own master password.
class ClosedVault {
  ClosedVault({required this.tag, required this.name, required this.count, required this.at});

  final String tag;
  final String name;
  final int count;
  final DateTime at;

  Map<String, dynamic> toJson() => {'tag': tag, 'name': name, 'count': count, 'at': at.toIso8601String()};

  factory ClosedVault.fromJson(Map<String, dynamic> j) => ClosedVault(
        tag: j['tag'] as String,
        name: (j['name'] ?? '') as String,
        count: (j['count'] ?? 0) as int,
        at: DateTime.tryParse((j['at'] ?? '') as String) ?? DateTime(2000),
      );
}

class BackupService {
  BackupService(this._settingsFile);

  final File _settingsFile;

  /// The copies kept of a vault in every place: the latest save, then one
  /// roughly an hour, a day, a week, a month, a quarter and a year old.
  /// Not every moment survives, but there is always some history.
  static const slots = [
    ('0-latest', Duration.zero),
    ('1-hour', Duration(hours: 1)),
    ('2-day', Duration(days: 1)),
    ('3-week', Duration(days: 7)),
    ('4-month', Duration(days: 30)),
    ('5-quarter', Duration(days: 90)),
    ('6-year', Duration(days: 365)),
  ];

  static String slotName(String tag, int slot) => 'vault-$tag-${slots[slot].$1}.khd';

  /// A slot takes the next newer copy once its own is older than its age;
  /// an empty slot fills straight away.
  static bool movesOn(DateTime? held, int slot) =>
      held == null || DateTime.now().difference(held) >= slots[slot].$2;

  /// Folders that get a copy of every save; the user picks them.
  List<String> targets = [];

  // Early builds put these in for everyone; they stay only where they really exist.
  static const _earlyDefaults = [r'E:\ACCESS\keyhold', r'D:\_KOPIA_ACCESS\keyhold'];

  RemoteConfig remote = RemoteConfig();
  String bridgeToken = '';
  List<String>? watched;

  /// Sites where the browser extension never saves logins.
  List<String> neverSave = [];

  /// A login that clearly worked is saved without asking in the browser.
  bool autoSave = false;

  /// Two-factor codes (by id) this device no longer offers to pin to a site.
  List<String> noPinAsk = [];

  /// The phone app opens only with a fingerprint (or the phone's PIN).
  bool fingerprintLock = false;

  /// Google Drive sync: the refresh token is kept DPAPI-protected, base64.
  String driveToken = '';
  String driveEmail = '';
  DateTime? driveSyncedAt;
  BackupStatus status = BackupStatus.empty();

  /// Vaults closed on this device, newest first.
  List<ClosedVault> closed = [];

  void loadSettings() {
    if (!_settingsFile.existsSync()) return;
    try {
      final raw = jsonDecode(_settingsFile.readAsStringSync()) as Map<String, dynamic>;
      final list = (raw['backupTargets'] as List<dynamic>?)?.cast<String>();
      if (list != null) {
        targets = list.where((p) => !_earlyDefaults.contains(p) || Directory(p).existsSync()).toList();
      }

      final remoteJson = raw['remote'] as Map<String, dynamic>?;
      if (remoteJson != null) remote = RemoteConfig.fromJson(remoteJson);

      bridgeToken = (raw['bridgeToken'] ?? '') as String;
      watched = (raw['watched'] as List<dynamic>?)?.cast<String>();
      neverSave = (raw['neverSave'] as List<dynamic>?)?.cast<String>() ?? [];
      autoSave = (raw['autoSave'] ?? false) as bool;
      noPinAsk = (raw['noPinAsk'] as List<dynamic>?)?.cast<String>() ?? [];
      fingerprintLock = (raw['fingerprintLock'] ?? false) as bool;
      driveToken = (raw['driveToken'] ?? '') as String;
      driveEmail = (raw['driveEmail'] ?? '') as String;
      driveSyncedAt = DateTime.tryParse((raw['driveSyncedAt'] ?? '') as String);
      closed = [
        for (final c in (raw['closed'] as List<dynamic>? ?? const [])) ClosedVault.fromJson(c as Map<String, dynamic>),
      ];

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
      if (neverSave.isNotEmpty) 'neverSave': neverSave,
      if (autoSave) 'autoSave': true,
      if (noPinAsk.isNotEmpty) 'noPinAsk': noPinAsk,
      if (fingerprintLock) 'fingerprintLock': true,
      if (driveToken.isNotEmpty) 'driveToken': driveToken,
      if (driveEmail.isNotEmpty) 'driveEmail': driveEmail,
      if (driveSyncedAt != null) 'driveSyncedAt': driveSyncedAt!.toIso8601String(),
      if (closed.isNotEmpty) 'closed': [for (final c in closed) c.toJson()],
      'lastBackupAt': status.at?.toIso8601String(),
      'lastBackupTargets': status.targets,
    }));
  }

  Future<BackupStatus> run(File vault, String tag) async {
    final done = <String>[];
    final errors = <String>[];

    for (final target in targets) {
      try {
        final dir = Directory(target);
        dir.createSync(recursive: true);
        _rotate(dir, tag);
        await vault.copy('${dir.path}${Platform.pathSeparator}${slotName(tag, 0)}');
        done.add(target);
      } catch (e) {
        errors.add('$target: $e');
      }
    }

    if (remote.configured) {
      try {
        await RemoteClient(remote).backup(vault, tag).timeout(const Duration(seconds: 40));
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

  /// Removes the copies of one vault from the backup folders; other vaults' copies stay.
  void deleteCopies(String tag) {
    for (final target in targets) {
      final dir = Directory(target);
      if (!dir.existsSync()) continue;
      for (final f in dir.listSync().whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (name.startsWith('vault-$tag-') && name.endsWith('.khd')) f.deleteSync();
      }
    }
  }

  /// Moves each copy one slot on when its slot is due, oldest slots first, and
  /// drops the dated copies this vault made before there were slots.
  void _rotate(Directory dir, String tag) {
    final sep = Platform.pathSeparator;
    for (var i = slots.length - 1; i >= 1; i--) {
      final newer = File('${dir.path}$sep${slotName(tag, i - 1)}');
      if (!newer.existsSync()) continue;
      final slot = File('${dir.path}$sep${slotName(tag, i)}');
      if (!movesOn(slot.existsSync() ? slot.lastModifiedSync() : null, i)) continue;
      newer.renameSync(slot.path);
    }
    final dated = RegExp('^vault-$tag-\\d{8}-\\d{4}\\.khd\$');
    for (final f in dir.listSync().whereType<File>()) {
      if (!dated.hasMatch(f.uri.pathSegments.last)) continue;
      try {
        f.deleteSync();
      } catch (_) {
        // a locked file just stays until the next run
      }
    }
  }
}
