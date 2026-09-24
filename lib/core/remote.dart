import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

import '../l10n/l10n.dart';

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

  Future<String> upload(File file, String name) async {
    final client = await _connect();
    try {
      final sftp = await client.sftp();
      await _ensureDir(sftp, config.remoteDir);

      final remotePath = '${config.remoteDir}/$name';
      final handle = await sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );
      await handle.write(file.openRead().cast<Uint8List>());
      await handle.close();
      return remotePath;
    } finally {
      client.close();
    }
  }

  Future<List<String>> list() async {
    final client = await _connect();
    try {
      final sftp = await client.sftp();
      final items = await sftp.listdir(config.remoteDir);
      return items
          .map((e) => e.filename)
          .where((n) => n.endsWith('.khd'))
          .toList()
        ..sort();
    } finally {
      client.close();
    }
  }

  Future<void> trim(int keep) async {
    final names = await list();
    if (names.length <= keep) return;

    final client = await _connect();
    try {
      final sftp = await client.sftp();
      for (final name in names.take(names.length - keep)) {
        await sftp.remove('${config.remoteDir}/$name');
      }
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
