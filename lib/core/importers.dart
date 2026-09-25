import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:csv/csv.dart';
import 'package:pointycastle/export.dart' as pc;

import '../l10n/l10n.dart';
import 'crypto.dart';
import 'keepass.dart';
import 'models.dart';
import 'qr.dart';
import 'storage.dart';

/// What a file brought in: logins (a login may carry its two-factor key)
/// and codes, and what was left out.
class Imported {
  Imported(this.format, this.entries, {this.unsupported = 0, this.skipped = 0});

  /// Where it came from, as the user knows it: "Bitwarden", "Aegis"…
  final String format;
  final List<VaultEntry> entries;

  /// Codes Keyhold cannot make: 8 digits, SHA-256, 60 seconds, counters, Steam.
  final int unsupported;

  /// Records with nothing to keep, or of a kind Keyhold does not hold (cards, identities).
  final int skipped;
}

/// The file opens only with its own password.
class ImportNeedsPassword implements Exception {
  ImportNeedsPassword(this.format);
  final String format;
}

class ImportWrongPassword implements Exception {}

/// A file Keyhold cannot read, with the reason to show.
class ImportFailed implements Exception {
  ImportFailed(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Reads an export of another password manager or authenticator, a KeePass
/// database or another Keyhold vault. The kind is told from the content, not
/// from the file name. [password] is asked for only when the file needs it.
Future<Imported> readImport(Uint8List bytes, VaultStore store, {String password = ''}) async {
  if (bytes.length > 5 && String.fromCharCodes(bytes.sublist(0, 5)) == 'KHLD1') {
    final vault = await store.openCopy(bytes, password);
    if (vault == null) throw password.isEmpty ? ImportNeedsPassword('Keyhold') : ImportWrongPassword();
    return _Builder('Keyhold').vault(vault);
  }
  if (isKeePass(bytes)) {
    if (password.isEmpty) throw ImportNeedsPassword('KeePass');
    try {
      return _Builder('KeePass').keePass(await Isolate.run(() => readKeePass(bytes, password)));
    } on KeePassWrongPassword {
      throw ImportWrongPassword();
    } on KeePassUnsupported {
      throw ImportFailed(t.keePassUnsupported);
    }
  }
  if (bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B) return _onePassword(bytes);

  final text = utf8.decode(bytes, allowMalformed: true).replaceFirst('﻿', '').trim();
  if (text.startsWith('{') || text.startsWith('[')) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw ImportFailed(t.importUnknown);
    }
    return _json(json, password);
  }
  // A list of links, one per line; a CSV may hold links in a column.
  final lines = text.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).where((l) => l.isNotEmpty);
  if (lines.every((l) => l.startsWith('otpauth'))) return _Builder(t.otpLinks).links(text);
  return _Builder('CSV').csv(text);
}

/// A vault's entries as new ones for another vault, codes inside their logins.
List<VaultEntry> entriesOf(Vault v) => _Builder('Keyhold').vault(v).entries;

// ---------- two-factor keys ----------

final _base32Chars = RegExp(r'^[A-Z2-7]+$');

/// A two-factor key Keyhold can make codes for (6 digits every 30 seconds
/// with SHA-1): null with [unsupported] set when it cannot.
({String? secret, bool unsupported}) _key(
  String raw, {
  int digits = 6,
  int period = 30,
  String algorithm = 'SHA1',
  String type = 'TOTP',
}) {
  final value = raw.trim();
  if (value.isEmpty) return (secret: null, unsupported: false);
  if (value.startsWith('otpauth://')) {
    final read = parseOtp(value);
    if (read.codes.isNotEmpty) return (secret: read.codes.first.secret, unsupported: false);
    return (secret: null, unsupported: true);
  }
  // KeeOtp and some KeePass plugins: "key=…&size=6&step=30".
  if (value.startsWith('key=')) {
    final q = Uri.splitQueryString(value);
    return _key(q['key'] ?? '',
        digits: int.tryParse(q['size'] ?? '') ?? 6,
        period: int.tryParse(q['step'] ?? '') ?? 30,
        algorithm: q['otpHashMode'] ?? 'SHA1');
  }
  final secret = value.toUpperCase().replaceAll(RegExp(r'[\s=-]'), '');
  if (!_base32Chars.hasMatch(secret) || decodeBase32Key(secret).isEmpty) return (secret: null, unsupported: true);
  final ok = digits == 6 &&
      period == 30 &&
      algorithm.toUpperCase().replaceAll('-', '').replaceAll('HMAC', '') == 'SHA1' &&
      type.toUpperCase() == 'TOTP';
  return ok ? (secret: secret, unsupported: false) : (secret: null, unsupported: true);
}

String _codeName(String issuer, String account) => issuer.isEmpty
    ? account
    : account.isEmpty
        ? issuer
        : '$issuer ($account)';

/// Collects entries the way every format needs them.
class _Builder {
  _Builder(this.format);

  final String format;
  final entries = <VaultEntry>[];
  var unsupported = 0;
  var skipped = 0;

  Imported get done => Imported(format, entries, unsupported: unsupported, skipped: skipped);

  /// A login, with its two-factor key when it has one Keyhold can use.
  void login({
    required String title,
    String username = '',
    String password = '',
    String url = '',
    String notes = '',
    String group = '',
    ({String? secret, bool unsupported})? code,
  }) {
    if (code?.unsupported ?? false) unsupported++;
    final secret = code?.secret;
    if (username.isEmpty && password.isEmpty && secret == null && notes.isEmpty) {
      skipped++;
      return;
    }
    var name = title.trim();
    if (name.isEmpty) name = hostOf(url);
    if (name.isEmpty) name = username;
    entries.add(VaultEntry(
      id: newId(),
      title: name,
      username: username,
      password: password,
      url: url,
      notes: notes,
      group: group,
      totpSecret: secret,
    ));
  }

  /// A code on its own, as an authenticator keeps it.
  void code(String issuer, String account, ({String? secret, bool unsupported}) key, {String group = ''}) {
    if (key.secret == null) {
      if (key.unsupported) {
        unsupported++;
      } else {
        skipped++;
      }
      return;
    }
    entries.add(VaultEntry(id: newId(), title: _codeName(issuer, account), totpSecret: key.secret, group: group));
  }

  Imported vault(Vault v) {
    for (final e in v.visible) {
      final copy = VaultEntry.fromJson({...e.toJson(), 'id': newId(), 'twoFactor': ''});
      // A login points at its code by id: the key comes along inside the login.
      if (!e.isCode) copy.totpSecret ??= v.secretFor(e);
      entries.add(copy);
    }
    return done;
  }

  Imported links(String text) {
    for (final line in text.split(RegExp(r'[\r\n]+'))) {
      final value = line.trim();
      if (!value.startsWith('otpauth')) continue;
      final read = parseOtp(value);
      unsupported += read.unsupported;
      for (final c in read.codes) {
        entries.add(VaultEntry(id: newId(), title: _codeName(c.issuer, c.account), totpSecret: c.secret));
      }
    }
    return done;
  }

  Imported keePass(List<KeePassEntry> list) {
    for (final e in list) {
      final f = e.fields;
      final otp = f['otp'] ?? '';
      final timeOtp = f['TimeOtp-Secret-Base32'] ?? '';
      final seed = f['TOTP Seed'] ?? '';
      final settings = (f['TOTP Settings'] ?? '').split(';');
      final code = otp.isNotEmpty
          ? _key(otp)
          : timeOtp.isNotEmpty
              ? _key(timeOtp,
                  digits: int.tryParse(f['TimeOtp-Length'] ?? '') ?? 6,
                  period: int.tryParse(f['TimeOtp-Period'] ?? '') ?? 30,
                  algorithm: f['TimeOtp-Algorithm'] ?? 'SHA1')
              : seed.isNotEmpty
                  ? _key(seed,
                      period: int.tryParse(settings.first) ?? 30,
                      digits: settings.length > 1 ? int.tryParse(settings[1]) ?? 6 : 6)
                  : null;
      login(
        title: f['Title'] ?? '',
        username: f['UserName'] ?? '',
        password: f['Password'] ?? '',
        url: f['URL'] ?? '',
        notes: f['Notes'] ?? '',
        group: e.group,
        code: code,
      );
    }
    return done;
  }

  Imported csv(String text) {
    final rows = const CsvDecoder().convert(text.replaceAll('\r\n', '\n'));
    if (rows.length < 2) throw ImportFailed(t.fileEmpty);
    final header = rows.first.map((c) => c.toString().trim().toLowerCase()).toList();
    int at(List<String> names) => header.indexWhere(names.contains);
    String cell(List<dynamic> row, int i) => i < 0 || i >= row.length ? '' : '${row[i] ?? ''}'.trim();

    final titleAt = at(['name', 'title', 'account']);
    final userAts = [for (final n in ['username', 'login', 'user', 'login_username', 'email']) at([n])]
        .where((i) => i >= 0)
        .toList();
    final passwordAt = at(['password', 'login_password', 'pass']);
    final urlAt = at(['url', 'website', 'login_uri', 'origin', 'web site', 'uri']);
    final noteAt = at(['note', 'notes', 'comment', 'extra']);
    final groupAt = at(['group', 'folder', 'grouping', 'vault']);
    final totpAt = at(['totp', 'login_totp', 'otpauth', 'otp', 'otpsecret', 'otpurl', 'one-time password', '2fa']);
    if (passwordAt < 0 && userAts.isEmpty) throw ImportFailed(t.noLoginColumns);

    for (final row in rows.skip(1)) {
      var group = cell(row, groupAt);
      // KeePassXC writes the whole path with the root first: "Root/Web".
      if (groupAt >= 0 && header[groupAt] == 'group') {
        final slash = group.indexOf('/');
        group = slash < 0 ? '' : group.substring(slash + 1);
      }
      login(
        title: cell(row, titleAt),
        username: userAts.map((i) => cell(row, i)).firstWhere((v) => v.isNotEmpty, orElse: () => ''),
        password: cell(row, passwordAt),
        url: cell(row, urlAt),
        notes: cell(row, noteAt),
        group: group,
        code: totpAt < 0 ? null : _key(cell(row, totpAt)),
      );
    }
    return done;
  }
}

// ---------- JSON exports ----------

Future<Imported> _json(Object? json, String password) async {
  if (json is List) {
    // andOTP: a plain list of accounts.
    final b = _Builder('andOTP');
    for (final a in json.whereType<Map<String, dynamic>>()) {
      b.code(
        '${a['issuer'] ?? ''}',
        '${a['label'] ?? ''}',
        _key('${a['secret'] ?? ''}',
            digits: _int(a['digits'], 6),
            period: _int(a['period'], 30),
            algorithm: '${a['algorithm'] ?? 'SHA1'}',
            type: '${a['type'] ?? 'TOTP'}'),
      );
    }
    return b.done;
  }
  if (json is! Map<String, dynamic>) throw ImportFailed(t.importUnknown);

  if (json['header'] is Map && json.containsKey('db')) return _aegis(json, password);
  if (json.containsKey('services') || json.containsKey('servicesEncrypted')) return _twoFas(json, password);
  if (json['tokens'] is List) return _freeOtp(json);
  if (json['items'] is List || json['encrypted'] == true) return _bitwarden(json, password);
  throw ImportFailed(t.importUnknown);
}

int _int(Object? v, int fallback) => v is int ? v : int.tryParse('$v') ?? fallback;

Future<Imported> _bitwarden(Map<String, dynamic> json, String password) async {
  var data = json;
  if (json['encrypted'] == true) {
    if (json['passwordProtected'] != true) throw ImportFailed(t.bitwardenAccountLocked);
    if (password.isEmpty) throw ImportNeedsPassword('Bitwarden');
    final plain = await Isolate.run(() => _bitwardenOpen(json, password));
    if (plain == null) throw ImportWrongPassword();
    data = jsonDecode(plain) as Map<String, dynamic>;
  }
  final folders = {for (final f in (data['folders'] as List? ?? const [])) f['id']: '${f['name'] ?? ''}'};
  final b = _Builder('Bitwarden');
  for (final item in (data['items'] as List? ?? const []).whereType<Map<String, dynamic>>()) {
    final type = item['type'];
    final group = folders[item['folderId']] ?? '';
    if (type == 1) {
      final login = (item['login'] as Map<String, dynamic>?) ?? const {};
      final uris = (login['uris'] as List? ?? const []);
      b.login(
        title: '${item['name'] ?? ''}',
        username: '${login['username'] ?? ''}',
        password: '${login['password'] ?? ''}',
        url: uris.isEmpty ? '' : '${uris.first['uri'] ?? ''}',
        notes: '${item['notes'] ?? ''}',
        group: group,
        code: _key('${login['totp'] ?? ''}'),
      );
    } else if (type == 2) {
      b.login(title: '${item['name'] ?? ''}', notes: '${item['notes'] ?? ''}', group: group);
    } else {
      b.skipped++;
    }
  }
  return b.done;
}

/// A password-protected Bitwarden export: the key from the password (PBKDF2
/// or Argon2id), stretched into an encryption and a MAC key, AES-CBC inside.
Future<String?> _bitwardenOpen(Map<String, dynamic> json, String password) async {
  final salt = utf8.encode('${json['salt']}');
  final List<int> master;
  if (json['kdfType'] == 1) {
    master = await Argon2id(
      parallelism: _int(json['kdfParallelism'], 4),
      memory: _int(json['kdfMemory'], 64) * 1024,
      iterations: _int(json['kdfIterations'], 3),
      hashLength: 32,
    ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: (await Sha256().hash(salt)).bytes).then((k) => k.extractBytes());
  } else {
    master = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: _int(json['kdfIterations'], 600000), bits: 256)
        .deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt)
        .then((k) => k.extractBytes());
  }
  Future<List<int>> expand(String info) async =>
      (await Hmac.sha256().calculateMac([...utf8.encode(info), 1], secretKey: SecretKey(master))).bytes;
  final enc = await expand('enc');
  final mac = await expand('mac');

  Future<String?> open(String encString) async {
    final parts = encString.substring(encString.indexOf('.') + 1).split('|');
    if (parts.length != 3) return null;
    final iv = base64.decode(parts[0]);
    final data = base64.decode(parts[1]);
    final expected = (await Hmac.sha256().calculateMac([...iv, ...data], secretKey: SecretKey(mac))).bytes;
    if (base64.encode(expected) != base64.encode(base64.decode(parts[2]))) return null;
    final plain = await AesCbc.with256bits(macAlgorithm: MacAlgorithm.empty)
        .decrypt(SecretBox(data, nonce: iv, mac: Mac.empty), secretKey: SecretKey(enc));
    return utf8.decode(plain);
  }

  final check = json['encKeyValidation_DO_NOT_EDIT'];
  if (check is String && await open(check) == null) return null;
  return open('${json['data']}');
}

Future<Imported> _onePassword(Uint8List bytes) async {
  final Map<String, dynamic> data;
  try {
    final file = ZipDecoder().decodeBytes(bytes).findFile('export.data');
    if (file == null) throw ImportFailed(t.importUnknown);
    data = jsonDecode(utf8.decode(file.content)) as Map<String, dynamic>;
  } on FormatException {
    throw ImportFailed(t.importUnknown);
  }
  final b = _Builder('1Password');
  for (final account in (data['accounts'] as List? ?? const [])) {
    for (final vault in (account['vaults'] as List? ?? const [])) {
      final group = '${vault['attrs']?['name'] ?? ''}';
      for (final raw in (vault['items'] as List? ?? const [])) {
        final item = (raw['item'] ?? raw) as Map<String, dynamic>;
        if (item['state'] == 'archived' || item['trashed'] == true) continue;
        final overview = (item['overview'] as Map<String, dynamic>?) ?? const {};
        final details = (item['details'] as Map<String, dynamic>?) ?? const {};
        var username = '';
        var password = '${details['password'] ?? ''}';
        for (final f in (details['loginFields'] as List? ?? const [])) {
          if (f['designation'] == 'username') username = '${f['value'] ?? ''}';
          if (f['designation'] == 'password') password = '${f['value'] ?? ''}';
        }
        String? totp;
        for (final section in (details['sections'] as List? ?? const [])) {
          for (final field in (section['fields'] as List? ?? const [])) {
            final value = field['value'];
            if (value is Map && value['totp'] != null) totp ??= '${value['totp']}';
          }
        }
        final urls = overview['urls'] as List? ?? const [];
        b.login(
          title: '${overview['title'] ?? ''}',
          username: username,
          password: password,
          url: '${overview['url'] ?? (urls.isEmpty ? '' : urls.first['url'] ?? '')}',
          notes: '${details['notesPlain'] ?? ''}',
          group: group,
          code: totp == null ? null : _key(totp),
        );
      }
    }
  }
  return b.done;
}

Future<Imported> _aegis(Map<String, dynamic> json, String password) async {
  var db = json['db'];
  if (db is String) {
    if (password.isEmpty) throw ImportNeedsPassword('Aegis');
    final header = json['header'] as Map<String, dynamic>;
    final plain = await Isolate.run(() => _aegisOpen(header, db as String, password));
    if (plain == null) throw ImportWrongPassword();
    db = jsonDecode(plain);
  }
  final groups = {for (final g in ((db as Map)['groups'] as List? ?? const [])) g['uuid']: '${g['name'] ?? ''}'};
  final b = _Builder('Aegis');
  for (final e in (db['entries'] as List? ?? const []).whereType<Map<String, dynamic>>()) {
    final info = (e['info'] as Map<String, dynamic>?) ?? const {};
    final inGroups = (e['groups'] as List? ?? const []);
    b.code(
      '${e['issuer'] ?? ''}',
      '${e['name'] ?? ''}',
      _key('${info['secret'] ?? ''}',
          digits: _int(info['digits'], 6),
          period: _int(info['period'], 30),
          algorithm: '${info['algo'] ?? 'SHA1'}',
          type: '${e['type'] ?? 'totp'}'),
      group: inGroups.isEmpty ? '' : groups[inGroups.first] ?? '',
    );
  }
  return b.done;
}

Uint8List _unhex(String s) =>
    Uint8List.fromList([for (var i = 0; i + 1 < s.length; i += 2) int.parse(s.substring(i, i + 2), radix: 16)]);

/// Aegis: each password slot holds the vault's master key, sealed with a key
/// scrypt makes from the password; the entries are sealed with the master key.
Future<String?> _aegisOpen(Map<String, dynamic> header, String db, String password) async {
  final gcm = AesGcm.with256bits();
  for (final slot in (header['slots'] as List? ?? const [])) {
    if (slot['type'] != 1) continue;
    final scrypt = pc.Scrypt()
      ..init(pc.ScryptParameters(_int(slot['n'], 32768), _int(slot['r'], 8), _int(slot['p'], 1), 32,
          _unhex('${slot['salt']}')));
    final derived = scrypt.process(Uint8List.fromList(utf8.encode(password)));
    final params = slot['key_params'] as Map<String, dynamic>;
    try {
      final master = await gcm.decrypt(
        SecretBox(_unhex('${slot['key']}'), nonce: _unhex('${params['nonce']}'), mac: Mac(_unhex('${params['tag']}'))),
        secretKey: SecretKey(derived),
      );
      final p = header['params'] as Map<String, dynamic>;
      final plain = await gcm.decrypt(
        SecretBox(base64.decode(db), nonce: _unhex('${p['nonce']}'), mac: Mac(_unhex('${p['tag']}'))),
        secretKey: SecretKey(master),
      );
      return utf8.decode(plain);
    } on SecretBoxAuthenticationError {
      continue;
    }
  }
  return null;
}

Future<Imported> _twoFas(Map<String, dynamic> json, String password) async {
  var services = json['services'] as List? ?? const [];
  final sealed = '${json['servicesEncrypted'] ?? ''}';
  if (sealed.isNotEmpty) {
    if (password.isEmpty) throw ImportNeedsPassword('2FAS');
    final plain = await Isolate.run(() => _twoFasOpen(sealed, password));
    if (plain == null) throw ImportWrongPassword();
    services = jsonDecode(plain) as List;
  }
  final groups = {for (final g in (json['groups'] as List? ?? const [])) g['id']: '${g['name'] ?? ''}'};
  final b = _Builder('2FAS');
  for (final s in services.whereType<Map<String, dynamic>>()) {
    final otp = (s['otp'] as Map<String, dynamic>?) ?? const {};
    b.code(
      '${otp['issuer'] ?? s['name'] ?? ''}',
      '${otp['account'] ?? ''}',
      _key('${s['secret'] ?? ''}',
          digits: _int(otp['digits'], 6),
          period: _int(otp['period'], 30),
          algorithm: '${otp['algorithm'] ?? 'SHA1'}',
          type: '${otp['tokenType'] ?? 'TOTP'}'),
      group: groups[s['groupId']] ?? '',
    );
  }
  return b.done;
}

/// 2FAS: "data:salt:iv" in base64, the key from the password by PBKDF2-SHA256.
Future<String?> _twoFasOpen(String sealed, String password) async {
  final parts = sealed.split(':');
  if (parts.length < 3) return null;
  final data = base64.decode(parts[0]);
  final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 10000, bits: 256)
      .deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: base64.decode(parts[1]));
  try {
    final plain = await AesGcm.with256bits().decrypt(
      SecretBox(data.sublist(0, data.length - 16), nonce: base64.decode(parts[2]), mac: Mac(data.sublist(data.length - 16))),
      secretKey: key,
    );
    return utf8.decode(plain);
  } on SecretBoxAuthenticationError {
    return null;
  }
}

Imported _freeOtp(Map<String, dynamic> json) {
  final b = _Builder('FreeOTP+');
  for (final token in (json['tokens'] as List).whereType<Map<String, dynamic>>()) {
    final raw = (token['secret'] as List? ?? const []).map((v) => (v as int) & 0xFF).toList();
    b.code(
      '${token['issuerExt'] ?? token['issuerInt'] ?? ''}',
      '${token['label'] ?? ''}',
      _key(encodeBase32(Uint8List.fromList(raw)),
          digits: _int(token['digits'], 6),
          period: _int(token['period'], 30),
          algorithm: '${token['algo'] ?? 'SHA1'}',
          type: '${token['type'] ?? 'TOTP'}'),
    );
  }
  return b.done;
}
