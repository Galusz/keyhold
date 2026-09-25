import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

import '../l10n/l10n.dart';
import 'backup.dart';

class RemoteConfig {
  RemoteConfig({
    this.host = '',
    this.port = 22,
    this.user = '',
    this.keyPath = '',
    this.remoteDir = 'keyhold',
  });

  String host;
  int port;
  String user;
  String keyPath;
  String remoteDir;

  bool get configured => host.isNotEmpty && user.isNotEmpty && keyPath.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'user': user,
        'keyPath': keyPath,
        'remoteDir': remoteDir,
      };

  factory RemoteConfig.fromJson(Map<String, dynamic> json) => RemoteConfig(
        host: (json['host'] ?? '') as String,
        port: (json['port'] ?? 22) as int,
        user: (json['user'] ?? '') as String,
        keyPath: (json['keyPath'] ?? '') as String,
        remoteDir: (json['remoteDir'] ?? 'keyhold') as String,
      );
}

class RemoteClient {
  RemoteClient(this.config);

  final RemoteConfig config;

  Future<SSHClient> _connect() async {
    final keyText = await File(config.keyPath).readAsString();
    final socket = await SSHSocket.connect(config.host, config.port,
        timeout: const Duration(seconds: 15));
    return SSHClient(
      socket,
      username: config.user,
      identities: SSHKeyPair.fromPem(keyText),
    );
  }

  /// The same 7 slots as in a folder: each copy moves one slot on when its
  /// slot is due, then the latest save goes up.
  Future<void> backup(File vault, String tag) async {
    final client = await _connect();
    try {
      final sftp = await client.sftp();
      await _ensureDir(sftp, config.remoteDir);
      String path(int slot) => '${config.remoteDir}/${BackupService.slotName(tag, slot)}';
      Future<DateTime?> heldSince(int slot) async {
        try {
          final seconds = (await sftp.stat(path(slot))).modifyTime;
          return seconds == null ? null : DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        } catch (_) {
          return null;
        }
      }

      for (var i = BackupService.slots.length - 1; i >= 1; i--) {
        if (await heldSince(i - 1) == null) continue;
        if (!BackupService.movesOn(await heldSince(i), i)) continue;
        try {
          await sftp.remove(path(i));
        } catch (_) {
          // the slot was empty
        }
        await sftp.rename(path(i - 1), path(i));
      }
      final handle = await sftp.open(
        path(0),
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate,
      );
      await handle.write(vault.openRead().cast<Uint8List>());
      await handle.close();
    } finally {
      client.close();
    }
  }

  Future<void> _ensureDir(SftpClient sftp, String path) async {
    final parts = path.split('/').where((p) => p.isNotEmpty);
    var current = path.startsWith('/') ? '' : '.';
    for (final part in parts) {
      current = current == '.' ? part : '$current/$part';
      try {
        await sftp.stat(current);
      } catch (_) {
        await sftp.mkdir(current);
      }
    }
  }

  Future<String> test() async {
    final client = await _connect();
    try {
      final sftp = await client.sftp();
      await _ensureDir(sftp, config.remoteDir);
      final probe = '${config.remoteDir}/.keyhold-test';
      final handle = await sftp.open(probe,
          mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
      await handle.write(Stream.value(utf8.encode('ok')).cast<Uint8List>());
      await handle.close();
      await sftp.remove(probe);
      return t.serverWritable('${config.user}@${config.host}');
    } finally {
      client.close();
    }
  }
}
