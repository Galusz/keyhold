import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

import 'backup.dart';
import 'crypto.dart';
import 'models.dart';

class VaultStore {
  late final Directory _dir;
  late final File _vaultFile;
  late final File _keyFile;
  Uint8List? _key;
  late final BackupService backup;

  /// Returns false when the vault is locked by a password this machine does not know yet.
  Future<bool> init() async {
    final base = await getApplicationSupportDirectory();
    _dir = Directory('${base.path}${Platform.pathSeparator}keyhold');
    if (!_dir.existsSync()) _dir.createSync(recursive: true);
    _vaultFile = File('${_dir.path}${Platform.pathSeparator}vault.khd');
    _keyFile = File('${_dir.path}${Platform.pathSeparator}key.bin');
    backup = BackupService(
      File('${_dir.path}${Platform.pathSeparator}settings.json'),
    )..loadSettings();

    if (_vaultFile.existsSync()) {
      _split(await _vaultFile.readAsBytes());
    }

    final stored = await _readStoredKey();
    if (stored != null) {
      _key = stored;
      return true;
    }

    if (hasPassword) {
      return false;
    }

    final fresh = newKey();
    await _storeKey(fresh);
    _key = fresh;
    return true;
  }

  String ensureBridgeToken() {
    if (backup.bridgeToken.isEmpty) {
      backup.bridgeToken = encodeBase32(randomBytes(20));
      backup.saveSettings();
    }
    return backup.bridgeToken;
  }

  Future<Uint8List?> _readStoredKey() async {
    if (!_keyFile.existsSync()) return null;
    return _unprotect(_keyFile.readAsBytesSync());
  }

  Future<void> _storeKey(Uint8List key) async {
    _keyFile.writeAsBytesSync(_protect(key));
  }

  String get vaultPath => _vaultFile.path;

  static const _magic = [0x4B, 0x48, 0x4C, 0x44, 0x31];

  Uint8List? _salt;
  Uint8List? _wrapped;

  bool get hasPassword => _salt != null && _wrapped != null;

  ({Uint8List header, Uint8List payload}) _split(Uint8List bytes) {
    final hasMagic = bytes.length > _magic.length &&
        List<int>.generate(_magic.length, (i) => bytes[i]).toString() ==
            _magic.toString();
    if (!hasMagic) {
      return (header: Uint8List(0), payload: bytes);
    }
    var offset = _magic.length;
    final flag = bytes[offset++];
    if (flag == 1) {
      _salt = Uint8List.fromList(bytes.sublist(offset, offset + 16));
      offset += 16;
      final length = (bytes[offset] << 8) | bytes[offset + 1];
      offset += 2;
      _wrapped = Uint8List.fromList(bytes.sublist(offset, offset + length));
      offset += length;
    }
    return (
      header: Uint8List.fromList(bytes.sublist(0, offset)),
      payload: Uint8List.fromList(bytes.sublist(offset)),
    );
  }

  Uint8List _buildHeader() {
    if (!hasPassword) return Uint8List.fromList([..._magic, 0]);
    return Uint8List.fromList([
      ..._magic,
      1,
      ..._salt!,
      (_wrapped!.length >> 8) & 0xFF,
      _wrapped!.length & 0xFF,
      ..._wrapped!,
    ]);
  }

  Future<void> setPassword(String password) async {
    final salt = randomBytes(16);
    _wrapped = await wrapKey(_key!, password, salt);
    _salt = salt;
    if (_vaultFile.existsSync()) {
      final parts = _split(await _vaultFile.readAsBytes());
      await _write(parts.payload);
    }
  }

  Future<bool> unlockWithPassword(String password) async {
    if (!_vaultFile.existsSync()) return false;
    _split(await _vaultFile.readAsBytes());
    if (!hasPassword) return false;
    try {
      final dek = await unwrapKey(_wrapped!, password, _salt!);
      await _storeKey(dek);
      _key = dek;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _write(Uint8List payload) async {
    final bytes = Uint8List.fromList([..._buildHeader(), ...payload]);
    final tmp = File('${_vaultFile.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (_vaultFile.existsSync()) _vaultFile.deleteSync();
    tmp.renameSync(_vaultFile.path);
    await backup.run(_vaultFile);
  }

  Future<Vault> load() async {
    if (!_vaultFile.existsSync()) return Vault();
    final bytes = await _vaultFile.readAsBytes();
    if (bytes.isEmpty) return Vault();
    final parts = _split(bytes);
    if (parts.payload.isEmpty) return Vault();
    final json = await unseal(_key!, parts.payload);
    return Vault.decode(json);
  }

  Future<void> save(Vault vault) async {
    await _write(await seal(_key!, vault.encode()));
  }

  Uint8List _protect(Uint8List input) => _dpapi(input, protect: true);
  Uint8List _unprotect(Uint8List input) => _dpapi(input, protect: false);

  Uint8List _dpapi(Uint8List input, {required bool protect}) {
    if (!Platform.isWindows) return input;

    final inBlob = calloc<CRYPT_INTEGER_BLOB>();
    final outBlob = calloc<CRYPT_INTEGER_BLOB>();
    final data = calloc<Uint8>(input.length);
    try {
      data.asTypedList(input.length).setAll(0, input);
      inBlob.ref.cbData = input.length;
      inBlob.ref.pbData = data;

      final result = protect
          ? CryptProtectData(inBlob, null, null, null, 0, outBlob)
          : CryptUnprotectData(inBlob, null, null, null, 0, outBlob);

      if (!result.value) {
        throw StateError('DPAPI failed (protect=$protect)');
      }
      final bytes = Uint8List.fromList(
        outBlob.ref.pbData.asTypedList(outBlob.ref.cbData),
      );
      HLOCAL(outBlob.ref.pbData).close();
      return bytes;
    } finally {
      calloc.free(data);
      calloc.free(inBlob);
      calloc.free(outBlob);
    }
  }

}
