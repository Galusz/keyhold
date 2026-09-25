import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'remote.dart';

/// A place that keeps copies of the vault: a folder on this computer, a
/// folder picked on the phone, or the user's own server.
abstract class CopyPlace {
  /// The files there and when each was written; null when the place does not tell.
  Future<Map<String, DateTime?>> files();
  Future<void> move(String from, String to);
  Future<void> write(String name, Uint8List bytes);
  Future<void> delete(String name);
}

class FolderPlace implements CopyPlace {
  FolderPlace(this.dir);

  final Directory dir;

  String _path(String name) => '${dir.path}${Platform.pathSeparator}$name';

  @override
  Future<Map<String, DateTime?>> files() async {
    dir.createSync(recursive: true);
    return {for (final f in dir.listSync().whereType<File>()) f.uri.pathSegments.last: f.lastModifiedSync()};
  }

  @override
  Future<void> move(String from, String to) async => File(_path(from)).renameSync(_path(to));

  @override
  Future<void> write(String name, Uint8List bytes) => File(_path(name)).writeAsBytes(bytes, flush: true);

  @override
  Future<void> delete(String name) async => File(_path(name)).deleteSync();
}

/// A folder picked on the phone in Android's own folder window; reached
/// through Android, not through a path.
class PhoneFolderPlace implements CopyPlace {
  PhoneFolderPlace(this.tree);

  final String tree;

  static const _channel = MethodChannel('keyhold/folders');

  static bool owns(String target) => target.startsWith('content://');

  static Future<String?> pick() => _channel.invokeMethod<String>('pick');

  static Future<void> release(String tree) => _channel.invokeMethod('release', {'tree': tree});

  /// The folder as the user knows it: its path in the phone or on the card.
  static String label(String tree) {
    final id = Uri.decodeComponent(tree.split('/tree/').last);
    final colon = id.indexOf(':');
    if (colon < 0) return id;
    final path = id.substring(colon + 1);
    return path.isEmpty ? id.substring(0, colon) : path;
  }

  @override
  Future<Map<String, DateTime?>> files() async {
    final found = await _channel.invokeMapMethod<String, Object?>('files', {'tree': tree}) ?? {};
    return found.map((name, ms) => MapEntry(name, ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms as int)));
  }

  @override
  Future<void> move(String from, String to) => _channel.invokeMethod('move', {'tree': tree, 'from': from, 'to': to});

  @override
  Future<void> write(String name, Uint8List bytes) =>
      _channel.invokeMethod('write', {'tree': tree, 'name': name, 'bytes': bytes});

  @override
  Future<void> delete(String name) => _channel.invokeMethod('delete', {'tree': tree, 'name': name});
}

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

  static CopyPlace placeFor(String target) =>
      PhoneFolderPlace.owns(target) ? PhoneFolderPlace(target) : FolderPlace(Directory(target));

  /// Moves each copy one slot on when its slot is due, oldest slots first,
  /// puts the latest save in the first slot, and drops the dated copies this
  /// vault made before there were slots. The same in every place.
  static Future<void> keepCopy(CopyPlace place, String tag, Uint8List bytes) async {
    final files = await place.files();
    for (var i = slots.length - 1; i >= 1; i--) {
      final newer = slotName(tag, i - 1);
      if (!files.containsKey(newer)) continue;
      final slot = slotName(tag, i);
      // A place that does not tell a file's age keeps what it holds.
      final held = files.containsKey(slot) ? files[slot] ?? DateTime.now() : null;
      if (!movesOn(held, i)) continue;
      await place.move(newer, slot);
      files[slot] = files.remove(newer);
    }
    await place.write(slotName(tag, 0), bytes);
    final dated = RegExp('^vault-$tag-\\d{8}-\\d{4}\\.khd\$');
    for (final name in files.keys.where(dated.hasMatch)) {
      try {
        await place.delete(name);
      } catch (_) {
        // a locked file just stays until the next run
      }
    }
  }

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
        errors: (raw['lastBackupErrors'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
    } catch (_) {
      // a broken settings file must never stop the app from opening
    }
  }

  /// Written to a file of its own and then put in place in one step: a crash
  /// or a killed app never leaves half a settings file (which would forget the
  /// backup places, Google Drive and the fingerprint lock).
  void saveSettings() {
    final tmp = File('${_settingsFile.path}.${DateTime.now().microsecondsSinceEpoch}.tmp');
    tmp.writeAsStringSync(jsonEncode({
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
      if (status.errors.isNotEmpty) 'lastBackupErrors': status.errors,
    }), flush: true);
    tmp.renameSync(_settingsFile.path);
  }

  Future<BackupStatus> run(File vault, String tag) async {
    final done = <String>[];
    final errors = <String>[];
    final bytes = await vault.readAsBytes();

    for (final target in targets) {
      try {
        await keepCopy(placeFor(target), tag, bytes);
        done.add(target);
      } catch (e) {
        errors.add('$target: $e');
      }
    }

    if (remote.configured) {
      try {
        await RemoteClient(remote).backup(bytes, tag).timeout(const Duration(seconds: 40));
        done.add(remote.host);
      } catch (e) {
        errors.add('${remote.host}: $e');
      }
    }

    // The time of the last copy that did get somewhere: a run where every
    // place failed is no backup, and its errors stay on show.
    status = BackupStatus(at: done.isEmpty ? status.at : DateTime.now(), targets: done, errors: errors);
    try {
      saveSettings();
    } catch (_) {
      // settings are a convenience, not a reason to fail a backup
    }
    return status;
  }

  /// Removes the copies of one vault from the backup folders; other vaults' copies stay.
  Future<void> deleteCopies(String tag) async {
    for (final target in targets) {
      if (!PhoneFolderPlace.owns(target) && !Directory(target).existsSync()) continue;
      final place = placeFor(target);
      for (final name in (await place.files()).keys) {
        if (name.startsWith('vault-$tag-') && name.endsWith('.khd')) await place.delete(name);
      }
    }
  }

}
