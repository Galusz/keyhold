import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:xml/xml.dart';

/// One entry of a KeePass database, as KeePass keeps it: named strings.
class KeePassEntry {
  KeePassEntry(this.fields, this.group);

  final Map<String, String> fields;

  /// The group path under the root group, "Web/Shops"; empty at the root.
  final String group;
}

class KeePassWrongPassword implements Exception {}

class KeePassUnsupported implements Exception {
  KeePassUnsupported(this.what);
  final String what;
}

bool isKeePass(Uint8List b) => b.length > 12 && _u32(b, 0) == 0x9AA2D903 && _u32(b, 4) == 0xB54BFB67;

int _u16(Uint8List b, int at) => b[at] | (b[at + 1] << 8);
int _u32(Uint8List b, int at) => b[at] | (b[at + 1] << 8) | (b[at + 2] << 16) | (b[at + 3] << 24);
int _u64(Uint8List b, int at) => _u32(b, at) + _u32(b, at + 4) * 0x100000000;

Uint8List _le64(int v) => Uint8List(8)..buffer.asByteData().setUint64(0, v, Endian.little);

String _hex(Uint8List b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

Future<Uint8List> _sha256(List<int> b) async => Uint8List.fromList((await Sha256().hash(b)).bytes);
Future<Uint8List> _sha512(List<int> b) async => Uint8List.fromList((await Sha512().hash(b)).bytes);
Future<Uint8List> _hmac(List<int> key, List<int> data) async =>
    Uint8List.fromList((await Hmac.sha256().calculateMac(data, secretKey: SecretKey(key))).bytes);

bool _same(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

const _aes = '31c1f2e6bf714350be5805216afc5aff';
const _chacha = 'd6038a2b8b6f4cb5a524339a31dbb59a';
const _aesKdf = 'c9d9f39a628a4460bf740d08c18a4fea';
const _argon2d = 'ef636ddf8c29444b91f7a9a403e30a0c';
const _argon2id = '9e298b1956db4773b23dfc3ec6f0a1e6';

/// KDBX 4 keeps its settings as typed name–value pairs.
Map<String, Object> _variants(Uint8List b) {
  final out = <String, Object>{};
  var at = 2;
  while (at < b.length) {
    final type = b[at++];
    if (type == 0) break;
    final nameLength = _u32(b, at);
    at += 4;
    final name = utf8.decode(b.sublist(at, at + nameLength));
    at += nameLength;
    final size = _u32(b, at);
    at += 4;
    final value = b.sublist(at, at + size);
    at += size;
    out[name] = switch (type) {
      0x04 || 0x0C => _u32(value, 0),
      0x05 || 0x0D => _u64(value, 0),
      0x08 => value[0] != 0,
      0x18 => utf8.decode(value),
      _ => value,
    };
  }
  return out;
}

/// The old way: the key encrypted with AES over and over.
Uint8List _aesRounds(Uint8List key, Uint8List seed, int rounds) {
  final aes = pc.AESEngine()..init(true, pc.KeyParameter(seed));
  final out = Uint8List.fromList(key);
  for (var i = 0; i < rounds; i++) {
    aes.processBlock(out, 0, out, 0);
    aes.processBlock(out, 16, out, 16);
  }
  return out;
}

Future<Uint8List> _transform(Uint8List composite, String kdf, Map<String, Object> p) async {
  if (kdf == _aesKdf) {
    return _sha256(_aesRounds(composite, p['S'] as Uint8List, p['R'] as int));
  }
  if (kdf == _argon2d || kdf == _argon2id) {
    final state = DartArgon2State(
      mode: kdf == _argon2d ? DartArgon2Mode.argon2d : DartArgon2Mode.argon2id,
      parallelism: p['P'] as int,
      memory: (p['M'] as int) ~/ 1024,
      iterations: p['I'] as int,
      hashLength: 32,
      version: (p['V'] as int?) ?? 0x13,
    );
    try {
      return Uint8List.fromList(await state.deriveKeyBytes(
        password: composite,
        nonce: p['S'] as Uint8List,
        optionalSecret: (p['K'] as Uint8List?) ?? const [],
        associatedData: (p['A'] as Uint8List?) ?? const [],
      ));
    } finally {
      state.tryReleaseMemory();
    }
  }
  throw KeePassUnsupported('KDF $kdf');
}

Uint8List _decrypt(String cipher, Uint8List key, Uint8List iv, Uint8List data) {
  if (cipher == _aes) {
    final aes = pc.PaddedBlockCipherImpl(pc.PKCS7Padding(), pc.CBCBlockCipher(pc.AESEngine()))
      ..init(false, pc.PaddedBlockCipherParameters(pc.ParametersWithIV(pc.KeyParameter(key), iv), null));
    try {
      return aes.process(data);
    } on ArgumentError {
      throw KeePassWrongPassword();
    } on StateError {
      throw KeePassWrongPassword();
    }
  }
  if (cipher == _chacha) {
    final chacha = pc.ChaCha7539Engine()..init(false, pc.ParametersWithIV(pc.KeyParameter(key), iv));
    return chacha.process(data);
  }
  throw KeePassUnsupported('cipher');
}

/// Opens a KeePass database (KDBX 3.1 or 4) with its master password and
/// lists its entries, leaving out the recycle bin and old versions.
Future<List<KeePassEntry>> readKeePass(Uint8List data, String password) async {
  final major = _u16(data, 10);
  if (major < 3 || major > 4) throw KeePassUnsupported('version $major');

  var at = 12;
  final fields = <int, Uint8List>{};
  while (true) {
    final id = data[at++];
    final size = major >= 4 ? _u32(data, at) : _u16(data, at);
    at += major >= 4 ? 4 : 2;
    final value = data.sublist(at, at + size);
    at += size;
    if (id == 0) break;
    fields[id] = value;
  }
  final headerEnd = at;

  final composite = await _sha256(await _sha256(utf8.encode(password)));
  final Map<String, Object> kdfParams;
  final String kdf;
  if (major >= 4) {
    kdfParams = _variants(fields[11]!);
    kdf = _hex(kdfParams[r'$UUID'] as Uint8List);
  } else {
    kdf = _aesKdf;
    kdfParams = {'S': fields[5]!, 'R': _u64(fields[6]!, 0)};
  }
  final transformed = await _transform(composite, kdf, kdfParams);
  final masterSeed = fields[4]!;
  final key = await _sha256([...masterSeed, ...transformed]);
  final cipher = _hex(fields[2]!);
  final iv = fields[7]!;
  final gzipped = fields[3] != null && _u32(fields[3]!, 0) == 1;

  Uint8List payload;
  int streamId;
  Uint8List streamKey;
  if (major >= 4) {
    if (!_same(await _sha256(data.sublist(0, headerEnd)), data.sublist(headerEnd, headerEnd + 32))) {
      throw KeePassUnsupported('damaged header');
    }
    final hmacKey = await _sha512([...masterSeed, ...transformed, 1]);
    Future<Uint8List> blockKey(int index) => _sha512([..._le64(index), ...hmacKey]);
    final headerMac = await _hmac(await blockKey(0xFFFFFFFFFFFFFFFF), data.sublist(0, headerEnd));
    if (!_same(headerMac, data.sublist(headerEnd + 32, headerEnd + 64))) throw KeePassWrongPassword();

    final blocks = BytesBuilder(copy: false);
    var p = headerEnd + 64;
    for (var index = 0;; index++) {
      final mac = data.sublist(p, p + 32);
      final size = _u32(data, p + 32);
      final block = data.sublist(p + 36, p + 36 + size);
      final expected = await _hmac(await blockKey(index), [..._le64(index), ...data.sublist(p + 32, p + 36), ...block]);
      if (!_same(mac, expected)) throw KeePassUnsupported('damaged block');
      p += 36 + size;
      if (size == 0) break;
      blocks.add(block);
    }
    var plain = _decrypt(cipher, key, iv, blocks.takeBytes());
    if (gzipped) plain = Uint8List.fromList(gzip.decode(plain));

    // The inner header: how protected values are hidden, then attachments.
    var q = 0;
    streamId = 0;
    streamKey = Uint8List(0);
    while (true) {
      final id = plain[q];
      final size = _u32(plain, q + 1);
      final value = plain.sublist(q + 5, q + 5 + size);
      q += 5 + size;
      if (id == 0) break;
      if (id == 1) streamId = _u32(value, 0);
      if (id == 2) streamKey = value;
    }
    payload = plain.sublist(q);
  } else {
    final plain = _decrypt(cipher, key, iv, data.sublist(headerEnd));
    if (plain.length < 32 || !_same(plain.sublist(0, 32), fields[9]!)) throw KeePassWrongPassword();
    final blocks = BytesBuilder(copy: false);
    var p = 32;
    while (p + 40 <= plain.length) {
      final size = _u32(plain, p + 36);
      if (size == 0) break;
      blocks.add(plain.sublist(p + 40, p + 40 + size));
      p += 40 + size;
    }
    payload = blocks.takeBytes();
    if (gzipped) payload = Uint8List.fromList(gzip.decode(payload));
    streamId = _u32(fields[10]!, 0);
    streamKey = fields[8]!;
  }

  // Protected values (passwords) are XORed with one key stream, in document order.
  final pc.StreamCipher stream;
  if (streamId == 2) {
    stream = pc.Salsa20Engine()
      ..init(false, pc.ParametersWithIV(pc.KeyParameter(await _sha256(streamKey)),
          Uint8List.fromList([0xE8, 0x30, 0x09, 0x4B, 0x97, 0x20, 0x5D, 0x2A])));
  } else if (streamId == 3) {
    final h = await _sha512(streamKey);
    stream = pc.ChaCha7539Engine()..init(false, pc.ParametersWithIV(pc.KeyParameter(h.sublist(0, 32)), h.sublist(32, 44)));
  } else {
    throw KeePassUnsupported('inner stream $streamId');
  }

  final doc = XmlDocument.parse(utf8.decode(payload, allowMalformed: true));
  for (final e in doc.descendants.whereType<XmlElement>()) {
    if (e.getAttribute('Protected')?.toLowerCase() != 'true') continue;
    final hidden = base64.decode(e.innerText.trim());
    final shown = utf8.decode(stream.process(Uint8List.fromList(hidden)), allowMalformed: true);
    e.children
      ..clear()
      ..add(XmlText(shown));
  }

  final file = doc.rootElement;
  final meta = file.getElement('Meta');
  final binOn = meta?.getElement('RecycleBinEnabled')?.innerText.toLowerCase() != 'false';
  final bin = binOn ? meta?.getElement('RecycleBinUUID')?.innerText.trim() : null;
  final entries = <KeePassEntry>[];

  void walk(XmlElement group, String path) {
    if (bin != null && group.getElement('UUID')?.innerText.trim() == bin) return;
    for (final entry in group.findElements('Entry')) {
      final strings = <String, String>{
        for (final s in entry.findElements('String'))
          s.getElement('Key')?.innerText ?? '': s.getElement('Value')?.innerText ?? '',
      };
      entries.add(KeePassEntry(strings, path));
    }
    for (final sub in group.findElements('Group')) {
      final name = sub.getElement('Name')?.innerText.trim() ?? '';
      walk(sub, path.isEmpty ? name : '$path/$name');
    }
  }

  final top = file.getElement('Root')?.getElement('Group');
  if (top != null) walk(top, '');
  return entries;
}
