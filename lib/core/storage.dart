import 'dart:ffi';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
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

    Uint8List? payload;
    if (_vaultFile.existsSync()) {
      payload = _split(await _vaultFile.readAsBytes()).payload;
    }

    // A key this Windows account or phone can no longer open (a reset account,
    // an app restored onto a new phone) counts as none: the master password
    // opens the vault instead.
    Uint8List? stored;
    try {
      stored = await _readStoredKey();
    } catch (_) {
      stored = null;
    }
    if (stored != null && await _opens(stored, payload)) {
      _key = stored;
      return true;
    }

    if (hasPassword || _headerRecovery != null) {
      return false;
    }

    // Nothing here opens this vault: it is put aside, never overwritten, and a new one begins.
    if (payload != null && payload.isNotEmpty) {
      _vaultFile.renameSync(
          '${_dir.path}${Platform.pathSeparator}vault-unreadable-${DateTime.now().millisecondsSinceEpoch}.khd');
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

  /// A vault file opened only to look inside: with this vault's key, or with
  /// the copy's recovery key or master password. Nothing here changes.
  Future<Vault?> openCopy(Uint8List bytes, [String typed = '']) async {
    final parts = _parse(bytes);
    if (parts.payload.isEmpty) return null;
    Uint8List? byPassword;
    if (typed.isNotEmpty && parts.salt != null && parts.wrapped != null) {
      try {
        byPassword = await unwrapKey(parts.wrapped!, typed, parts.salt!);
      } catch (_) {
        byPassword = null;
      }
    }
    for (final key in [_key, await _keyFromCode(parts.recovery, typed), byPassword]) {
      if (key == null) continue;
      try {
        return Vault.decode(await unseal(key, parts.payload));
      } catch (_) {
        // not this key
      }
    }
    return null;
  }

  /// Whether [bytes] is this very vault (a copy of it opens with its key).
  Future<bool> opens(Uint8List bytes) async => _key != null && await _opens(_key!, _parse(bytes).payload);

  /// A short mark of this vault's key in the names of its backup copies:
  /// tidying up old copies never touches another vault's.
  Future<String> _tag() async {
    final hash = await Sha256().hash(_key!);
    return hash.bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<bool> _opens(Uint8List key, Uint8List? payload) async {
    if (payload == null || payload.isEmpty) return true;
    try {
      await unseal(key, payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _storeKey(Uint8List key) async {
    _keyFile.writeAsBytesSync(await protect(key));
  }

  String get vaultPath => _vaultFile.path;

  /// Erases this device's vault: the file, its key, the settings and the icons.
  void deleteLocal() {
    for (final entity in _dir.listSync()) {
      entity.deleteSync(recursive: true);
    }
    _key = null;
  }

  static const _magic = [0x4B, 0x48, 0x4C, 0x44, 0x31];

  Uint8List? _salt;
  Uint8List? _wrapped;
  int _wrapChangedAt = 0;

  /// The vault's key sealed by the recovery code: as read from the file, and
  /// with its code once the vault itself was opened.
  Uint8List? _headerRecovery;
  RecoveryWrap? _recovery;

  bool get hasPassword => _salt != null && _wrapped != null;

  /// Header: magic, a flag byte, then the key sealed by the master password
  /// (flag bit 1: salt, length, bytes) and by the recovery code (bit 2: length, bytes).
  static ({Uint8List? salt, Uint8List? wrapped, Uint8List? recovery, Uint8List payload}) _parse(
      Uint8List bytes) {
    final hasMagic = bytes.length > _magic.length &&
        List<int>.generate(_magic.length, (i) => bytes[i]).toString() ==
            _magic.toString();
    if (!hasMagic) return (salt: null, wrapped: null, recovery: null, payload: bytes);

    var offset = _magic.length;
    final flag = bytes[offset++];
    Uint8List? salt;
    Uint8List? wrapped;
    Uint8List? recovery;
    if (flag & 1 != 0) {
      salt = Uint8List.fromList(bytes.sublist(offset, offset + 16));
      offset += 16;
      final length = (bytes[offset] << 8) | bytes[offset + 1];
      offset += 2;
      wrapped = Uint8List.fromList(bytes.sublist(offset, offset + length));
      offset += length;
    }
    if (flag & 2 != 0) {
      final length = (bytes[offset] << 8) | bytes[offset + 1];
      offset += 2;
      recovery = Uint8List.fromList(bytes.sublist(offset, offset + length));
      offset += length;
    }
    return (salt: salt, wrapped: wrapped, recovery: recovery, payload: Uint8List.fromList(bytes.sublist(offset)));
  }

  ({Uint8List payload}) _split(Uint8List bytes) {
    final parts = _parse(bytes);
    if (parts.salt != null) {
      _salt = parts.salt;
      _wrapped = parts.wrapped;
    }
    if (parts.recovery != null) _headerRecovery = parts.recovery;
    return (payload: parts.payload);
  }

  Uint8List _buildHeader() {
    final recovery = _recovery?.sealed ?? _headerRecovery;
    return Uint8List.fromList([
      ..._magic,
      (hasPassword ? 1 : 0) | (recovery != null ? 2 : 0),
      if (hasPassword) ...[
        ..._salt!,
        (_wrapped!.length >> 8) & 0xFF,
        _wrapped!.length & 0xFF,
        ..._wrapped!,
      ],
      if (recovery != null) ...[
        (recovery.length >> 8) & 0xFF,
        recovery.length & 0xFF,
        ...recovery,
      ],
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

  /// Brings the header and [vault] to whichever password change is newer,
  /// and to the recovery key, which every device keeps in the header.
  void syncKeyWrap(Vault vault) {
    final r = vault.recovery;
    if (r != null && (_recovery == null || r.changedAt > _recovery!.changedAt)) _recovery = r;
    if (_recovery != null) vault.recovery = _recovery;

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

  /// The vault's recovery code, made the first time it is asked for.
  Future<String> recoveryCode() async {
    final vault = await load();
    syncKeyWrap(vault);
    if (_recovery != null) return _recovery!.code;
    final code = await newRecoveryCode();
    _recovery = RecoveryWrap(
      code: code,
      sealed: await sealForRecovery(_key!, code),
      changedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await save(vault);
    return code;
  }

  /// The vault's key from [sealed] when [typed] is its recovery code.
  Future<Uint8List?> _keyFromCode(Uint8List? sealed, String typed) async {
    if (sealed == null) return null;
    final code = await readRecoveryCode(typed);
    return code == null ? null : openWithRecovery(sealed, code);
  }

  Future<bool> unlockWithPassword(String password) async {
    if (!_vaultFile.existsSync()) return false;
    _split(await _vaultFile.readAsBytes());
    final byCode = await _keyFromCode(_headerRecovery, password);
    if (byCode != null) {
      await _storeKey(byCode);
      _key = byCode;
      return true;
    }
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

  Future<void> _writing = Future.value();

  /// One write at a time, each through a file of its own that then replaces
  /// the vault in one step: a crash leaves the old vault whole.
  Future<void> _write(Uint8List payload) {
    final bytes = Uint8List.fromList([..._buildHeader(), ...payload]);
    final done = _writing.then((_) async {
      final tmp = File('${_vaultFile.path}.$pid.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      tmp.renameSync(_vaultFile.path);
      await backup.run(_vaultFile, await _tag());
    });
    _writing = done.catchError((_) {});
    return done;
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
    final r = vault.recovery;
    if (r != null && (_recovery == null || r.changedAt > _recovery!.changedAt)) _recovery = r;
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
  /// with its master password. This device's entries are sealed with that key
  /// before its own key is let go: whatever fails in between, the master
  /// password still opens the file here.
  Future<bool> adopt(Uint8List bytes, String password) async {
    final parts = _parse(bytes);
    // The recovery code opens it as well as the master password does.
    var dek = await _keyFromCode(parts.recovery, password);
    if (dek == null) {
      if (parts.salt == null || parts.wrapped == null) return false;
      try {
        dek = await unwrapKey(parts.wrapped!, password, parts.salt!);
      } catch (_) {
        return false;
      }
    }
    final mine = await load();
    _key = dek;
    _salt = parts.salt;
    _wrapped = parts.wrapped;
    _headerRecovery = parts.recovery;
    await save(mine);
    await _storeKey(dek);
    return true;
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
