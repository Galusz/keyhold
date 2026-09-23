import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';

import 'backup.dart';
import 'crypto.dart';
import 'favicons.dart';
import 'models.dart';

class VaultStore {
  late final Directory _dir;
  late final File _vaultFile;
  late final File _keyFile;
  Uint8List? _key;
  late final BackupService backup;
  late final Favicons icons;

  /// Returns false when the vault is locked by a password this machine does not know yet.
  Future<bool> init() async {
    final base = await getApplicationSupportDirectory();
    _dir = Directory('${base.path}${Platform.pathSeparator}keyhold');
    if (!_dir.existsSync()) _dir.createSync(recursive: true);
    _vaultFile = File('${_dir.path}${Platform.pathSeparator}vault.khd');
    _keyFile = File('${_dir.path}${Platform.pathSeparator}key.bin');
    icons = Favicons(Directory('${_dir.path}${Platform.pathSeparator}icons'));
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
    return unprotect(_keyFile.readAsBytesSync());
  }

  Future<void> _storeKey(Uint8List key) async {
    _keyFile.writeAsBytesSync(await protect(key));
  }

  String get vaultPath => _vaultFile.path;

  static const _magic = [0x4B, 0x48, 0x4C, 0x44, 0x31];

  Uint8List? _salt;
  Uint8List? _wrapped;
  int _wrapChangedAt = 0;

  bool get hasPassword => _salt != null && _wrapped != null;

  static ({Uint8List? salt, Uint8List? wrapped, Uint8List payload}) _parse(
      Uint8List bytes) {
    final hasMagic = bytes.length > _magic.length &&
        List<int>.generate(_magic.length, (i) => bytes[i]).toString() ==
            _magic.toString();
    if (!hasMagic) return (salt: null, wrapped: null, payload: bytes);

    var offset = _magic.length;
    final flag = bytes[offset++];
    Uint8List? salt;
    Uint8List? wrapped;
    if (flag == 1) {
      salt = Uint8List.fromList(bytes.sublist(offset, offset + 16));
      offset += 16;
      final length = (bytes[offset] << 8) | bytes[offset + 1];
      offset += 2;
      wrapped = Uint8List.fromList(bytes.sublist(offset, offset + length));
      offset += length;
    }
    return (salt: salt, wrapped: wrapped, payload: Uint8List.fromList(bytes.sublist(offset)));
  }

  ({Uint8List payload}) _split(Uint8List bytes) {
    final parts = _parse(bytes);
    if (parts.salt != null) {
      _salt = parts.salt;
      _wrapped = parts.wrapped;
    }
    return (payload: parts.payload);
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

  /// Whether [password] opens this vault's key.
  Future<bool> checkPassword(String password) async {
    if (!hasPassword) return true;
    try {
      await unwrapKey(_wrapped!, password, _salt!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPassword(String password) async {
    // Read first: loading takes the header from disk.
    final vault = await load();
    final salt = randomBytes(16);
    _wrapped = await wrapKey(_key!, password, salt);
    _salt = salt;
    _wrapChangedAt = DateTime.now().millisecondsSinceEpoch;
    await save(vault);
  }

  /// Brings the header and [vault] to whichever password change is newer.
  void syncKeyWrap(Vault vault) {
    final w = vault.keyWrap;
    if (w != null && w.changedAt > _wrapChangedAt) {
      _salt = w.salt;
      _wrapped = w.wrapped;
      _wrapChangedAt = w.changedAt;
    }
    if (hasPassword) {
      vault.keyWrap = KeyWrap(salt: _salt!, wrapped: _wrapped!, changedAt: _wrapChangedAt);
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
    final vault = Vault.decode(await unseal(_key!, parts.payload));
    final w = vault.keyWrap;
    if (w != null && w.changedAt > _wrapChangedAt) _wrapChangedAt = w.changedAt;
    return vault;
  }

  Future<void> save(Vault vault) async {
    syncKeyWrap(vault);
    await _write(await seal(_key!, vault.encode()));
  }

  /// What the vault file holds for [vault], header included, without writing it.
  Future<Uint8List> fileFor(Vault vault) async {
    syncKeyWrap(vault);
    return Uint8List.fromList([..._buildHeader(), ...await seal(_key!, vault.encode())]);
  }

  /// Opens a vault file from another device that shares this vault's key.
  Future<Vault> open(Uint8List bytes) async {
    final payload = _parse(bytes).payload;
    if (payload.isEmpty) return Vault();
    return Vault.decode(await unseal(_key!, payload));
  }

  /// Takes over the key of a vault created on another device, unlocked
  /// with its master password. The caller saves the merged vault afterwards.
  Future<bool> adopt(Uint8List bytes, String password) async {
    final parts = _parse(bytes);
    if (parts.salt == null || parts.wrapped == null) return false;
    try {
      final dek = await unwrapKey(parts.wrapped!, password, parts.salt!);
      await _storeKey(dek);
      _key = dek;
      _salt = parts.salt;
      _wrapped = parts.wrapped;
      return true;
    } catch (_) {
      return false;
    }
  }

  static const _keystore = MethodChannel('keyhold/keystore');

  /// Seals secrets for this user on this device: DPAPI on Windows, the
  /// Android Keystore on a phone.
  Future<Uint8List> protect(Uint8List input) async {
    if (Platform.isAndroid) return (await _keystore.invokeMethod<Uint8List>('protect', input))!;
    return _dpapi(input, protect: true);
  }

  Future<Uint8List> unprotect(Uint8List input) async {
    if (Platform.isAndroid) return (await _keystore.invokeMethod<Uint8List>('unprotect', input))!;
    return _dpapi(input, protect: false);
  }

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
