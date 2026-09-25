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

  /// The same 7 slots as in a folder.
  Future<void> backup(Uint8List bytes, String tag) async {
    final client = await _connect();
    try {
      final sftp = await client.sftp();
      await _ensureDir(sftp, config.remoteDir);
      await BackupService.keepCopy(_ServerPlace(sftp, config.remoteDir), tag, bytes);
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

class _ServerPlace implements CopyPlace {
  _ServerPlace(this.sftp, this.dir);

  final SftpClient sftp;
  final String dir;

  String _path(String name) => '$dir/$name';

  @override
  Future<Map<String, DateTime?>> files() async => {
        for (final f in await sftp.listdir(dir))
          if (!f.attr.isDirectory && f.filename != '.' && f.filename != '..')
            f.filename: f.attr.modifyTime == null ? null : DateTime.fromMillisecondsSinceEpoch(f.attr.modifyTime! * 1000),
      };

  @override
  Future<void> move(String from, String to) async {
    try {
      await sftp.remove(_path(to));
    } catch (_) {
      // nothing there yet
    }
    await sftp.rename(_path(from), _path(to));
  }

  @override
  Future<void> write(String name, Uint8List bytes) async {
    final handle = await sftp.open(
      _path(name),
      mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate,
    );
    await handle.writeBytes(bytes);
    await handle.close();
  }

  @override
  Future<void> delete(String name) => sftp.remove(_path(name));
}
