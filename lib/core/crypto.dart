import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

final _algorithm = AesGcm.with256bits();

Uint8List newKey() {
  final rnd = Random.secure();
  return Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));
}

Future<Uint8List> seal(Uint8List key, String plain) async {
  final box = await _algorithm.encryptString(
    plain,
    secretKey: SecretKey(key),
  );
  return Uint8List.fromList([...box.nonce, ...box.cipherText, ...box.mac.bytes]);
}

Future<String> unseal(Uint8List key, Uint8List blob) async {
  const nonceLength = 12;
  const macLength = 16;
  final box = SecretBox(
    blob.sublist(nonceLength, blob.length - macLength),
    nonce: blob.sublist(0, nonceLength),
    mac: Mac(blob.sublist(blob.length - macLength)),
  );
  return _algorithm.decryptString(box, secretKey: SecretKey(key));
}

const _base32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

String encodeBase32(Uint8List bytes) {
  final out = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final b in bytes) {
    buffer = (buffer << 8) | b;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      out.write(_base32[(buffer >> bits) & 0x1F]);
    }
  }
  if (bits > 0) {
    out.write(_base32[(buffer << (5 - bits)) & 0x1F]);
  }
  return out.toString();
}

Uint8List decodeBase32Key(String input) {
  final clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
  final out = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final char in clean.split('')) {
    final value = _base32.indexOf(char);
    if (value < 0) continue;
    buffer = (buffer << 5) | value;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      out.add((buffer >> bits) & 0xFF);
    }
  }
  return Uint8List.fromList(out);
}

String groupKey(String raw) {
  final chunks = <String>[];
  for (var i = 0; i < raw.length; i += 4) {
    chunks.add(raw.substring(i, i + 4 > raw.length ? raw.length : i + 4));
  }
  return chunks.join('-');
}

final _kdf = Argon2id(
  parallelism: 4,
  memory: 64 * 1024,
  iterations: 3,
  hashLength: 32,
);

Uint8List randomBytes(int length) {
  final rnd = Random.secure();
  return Uint8List.fromList(List<int>.generate(length, (_) => rnd.nextInt(256)));
}

Future<Uint8List> keyFromPassword(String password, Uint8List salt) async {
  final derived = await _kdf.deriveKey(
    secretKey: SecretKey(utf8.encode(password)),
    nonce: salt,
  );
  return Uint8List.fromList(await derived.extractBytes());
}

Future<Uint8List> wrapKey(Uint8List dek, String password, Uint8List salt) async {
  final wrapping = await keyFromPassword(password, salt);
  final box = await _algorithm.encrypt(dek, secretKey: SecretKey(wrapping));
  return Uint8List.fromList([...box.nonce, ...box.cipherText, ...box.mac.bytes]);
}

Future<Uint8List> unwrapKey(
    Uint8List wrapped, String password, Uint8List salt) async {
  final wrapping = await keyFromPassword(password, salt);
  const nonceLength = 12;
  const macLength = 16;
  final box = SecretBox(
    wrapped.sublist(nonceLength, wrapped.length - macLength),
    nonce: wrapped.sublist(0, nonceLength),
    mac: Mac(wrapped.sublist(wrapped.length - macLength)),
  );
  final plain = await _algorithm.decrypt(box, secretKey: SecretKey(wrapping));
  return Uint8List.fromList(plain);
}

/// A recovery code: 20 random bytes and 2 bytes of their SHA-256 against
/// typos, as 36 base32 characters shown in 3 rows of 3 groups of 4.
Future<String> newRecoveryCode() async {
  final secret = randomBytes(20);
  final check = (await Sha256().hash(secret)).bytes.sublist(0, 2);
  return encodeBase32(Uint8List.fromList([...secret, ...check])).substring(0, 36);
}

/// What the user typed, when it is a recovery code: spaces and dashes go,
/// 0, 1 and 8 read as O, I and B, and the typo check has to pass.
Future<String?> readRecoveryCode(String typed) async {
  final clean = typed
      .toUpperCase()
      .replaceAll('0', 'O')
      .replaceAll('1', 'I')
      .replaceAll('8', 'B')
      .replaceAll(RegExp(r'[^A-Z2-7]'), '');
  if (clean.length != 36) return null;
  final bytes = decodeBase32Key(clean);
  if (bytes.length < 22) return null;
  final check = (await Sha256().hash(bytes.sublist(0, 20))).bytes;
  return check[0] == bytes[20] && check[1] == bytes[21] ? clean : null;
}

/// The vault's key sealed by a recovery code (salt first).
Future<Uint8List> sealForRecovery(Uint8List dek, String code) async {
  final salt = randomBytes(16);
  return Uint8List.fromList([...salt, ...await wrapKey(dek, code, salt)]);
}

/// The vault's key back from [sealed] and a recovery code, or null.
Future<Uint8List?> openWithRecovery(Uint8List sealed, String code) async {
  if (sealed.length <= 16) return null;
  try {
    return await unwrapKey(sealed.sublist(16), code, sealed.sublist(0, 16));
  } catch (_) {
    return null;
  }
}
