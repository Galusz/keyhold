import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import 'models.dart';

const maxWatchedFileBytes = 25 * 1024 * 1024;

class WatchResult {
  WatchResult({
    required this.added,
    required this.updated,
    required this.skipped,
  });

  final int added;
  final int updated;
  final List<String> skipped;

  bool get changed => added + updated > 0;
}

Future<String> _sha256(List<int> bytes) async {
  final digest = await Sha256().hash(bytes);
  return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

Iterable<File> _filesUnder(String path) sync* {
  for (final entity in Directory(path).listSync(recursive: true, followLinks: false)) {
    if (entity is File) yield entity;
  }
}

/// Copies every file of the watched folders into the vault when it is new
/// or its content changed. Files removed from disk stay in the vault on
/// purpose — that is the backup — and a folder that is not there (a drive
/// not plugged in) is simply passed over.
Future<WatchResult> scanWatched(Vault vault, List<String> watched) async {
  var added = 0;
  var updated = 0;
  final skipped = <String>[];

  final bySource = <String, VaultFile>{
    for (final f in vault.files.values)
      if (f.source != null && !f.deleted) f.source!: f,
  };

  for (final root in watched) {
    if (!FileSystemEntity.isDirectorySync(root)) continue;

    for (final file in _filesUnder(root)) {
      final path = file.path;
      final List<int> bytes;
      try {
        if (file.lengthSync() > maxWatchedFileBytes) {
          skipped.add(path);
          continue;
        }
        bytes = await file.readAsBytes();
      } catch (_) {
        skipped.add(path);
        continue;
      }

      final hash = await _sha256(bytes);
      final known = bySource[path];
      if (known != null && known.hash == hash) continue;

      if (known == null) {
        vault.putFile(VaultFile(
          id: 'w-${hash.substring(0, 12)}-${DateTime.now().microsecondsSinceEpoch}',
          name: file.uri.pathSegments.last,
          data: base64Encode(bytes),
          size: bytes.length,
          source: path,
          hash: hash,
        ));
        added++;
      } else {
        known
          ..data = base64Encode(bytes)
          ..size = bytes.length
          ..hash = hash;
        vault.putFile(known);
        updated++;
      }
    }
  }

  return WatchResult(added: added, updated: updated, skipped: skipped);
}

