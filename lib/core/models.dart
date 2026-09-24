import 'dart:convert';
import 'dart:typed_data';

/// "example.com" from any address, without "www.".
String hostOf(String url) {
  var text = url.trim();
  if (text.isEmpty) return '';
  if (!text.contains('://')) text = 'https://$text';
  final host = Uri.tryParse(text)?.host.toLowerCase() ?? '';
  return host.startsWith('www.') ? host.substring(4) : host;
}

class VaultEntry {
  final String id;
  String title;
  String username;
  String password;
  String url;
  String notes;
  String group;
  String? totpSecret;

  /// On a login: the id of its two-factor code entry, '' for none. The id,
  /// not the name — two codes may be called the same.
  String twoFactor;
  int updatedAt;
  bool deleted;

  VaultEntry({
    required this.id,
    this.title = '',
    this.username = '',
    this.password = '',
    this.url = '',
    this.notes = '',
    this.group = '',
    this.totpSecret,
    this.twoFactor = '',
    int? updatedAt,
    this.deleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'username': username,
        'password': password,
        'url': url,
        'notes': notes,
        if (group.isNotEmpty) 'group': group,
        if (totpSecret != null) 'totp': totpSecret,
        if (twoFactor.isNotEmpty) 'twoFactor': twoFactor,
        'updatedAt': updatedAt,
        if (deleted) 'deleted': true,
      };

  factory VaultEntry.fromJson(Map<String, dynamic> j) => VaultEntry(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        username: (j['username'] ?? '') as String,
        password: (j['password'] ?? '') as String,
        url: (j['url'] ?? '') as String,
        notes: (j['notes'] ?? '') as String,
        group: (j['group'] ?? '') as String,
        totpSecret: j['totp'] as String?,
        twoFactor: (j['twoFactor'] ?? '') as String,
        updatedAt: (j['updatedAt'] ?? 0) as int,
        deleted: (j['deleted'] ?? false) as bool,
      );

  void touch() => updatedAt = DateTime.now().millisecondsSinceEpoch;

  /// A two-factor code on its own — name, key, note, address — not a login.
  bool get isCode => (totpSecret ?? '').isNotEmpty && password.isEmpty;
}

/// A file kept inside the vault — recovery codes, keys, scans.
class VaultFile {
  final String id;
  String name;
  String data;
  int size;
  int updatedAt;
  bool deleted;

  /// Where the file lives on disk when it is picked up by a watched folder.
  String? source;

  /// SHA-256 of the content, so an unchanged file is not stored again.
  String? hash;

  VaultFile({
    required this.id,
    required this.name,
    required this.data,
    required this.size,
    int? updatedAt,
    this.deleted = false,
    this.source,
    this.hash,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Uint8List get bytes => base64Decode(data);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'data': data,
        'size': size,
        'updatedAt': updatedAt,
        if (deleted) 'deleted': true,
        if (source != null) 'source': source,
        if (hash != null) 'hash': hash,
      };

  factory VaultFile.fromJson(Map<String, dynamic> j) => VaultFile(
        id: j['id'] as String,
        name: (j['name'] ?? '') as String,
        data: (j['data'] ?? '') as String,
        size: (j['size'] ?? 0) as int,
        updatedAt: (j['updatedAt'] ?? 0) as int,
        deleted: (j['deleted'] ?? false) as bool,
        source: j['source'] as String?,
        hash: j['hash'] as String?,
      );
}

/// The vault key sealed with the master password, as it stands in the file
/// header. It also travels inside the vault, so every device learns about a
/// password change and none of them brings an older one back.
class KeyWrap {
  KeyWrap({required this.salt, required this.wrapped, required this.changedAt});

  final Uint8List salt;
  final Uint8List wrapped;
  final int changedAt;

  Map<String, dynamic> toJson() => {
        'salt': base64Encode(salt),
        'wrapped': base64Encode(wrapped),
        'changedAt': changedAt,
      };

  factory KeyWrap.fromJson(Map<String, dynamic> j) => KeyWrap(
        salt: base64Decode(j['salt'] as String),
        wrapped: base64Decode(j['wrapped'] as String),
        changedAt: (j['changedAt'] ?? 0) as int,
      );
}

class Vault {
  static const int formatVersion = 1;

  final Map<String, VaultEntry> entries;
  final Map<String, VaultFile> files;
  KeyWrap? keyWrap;

  Vault({Map<String, VaultEntry>? entries, Map<String, VaultFile>? files, this.keyWrap})
      : entries = entries ?? {},
        files = files ?? {};

  List<VaultFile> get visibleFiles {
    final list = files.values.where((f) => !f.deleted).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  void putFile(VaultFile f) {
    f.updatedAt = DateTime.now().millisecondsSinceEpoch;
    files[f.id] = f;
  }

  void removeFile(String id) {
    final f = files[id];
    if (f == null) return;
    f.deleted = true;
    f.data = '';
    f.size = 0;
    f.updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  List<VaultEntry> get visible {
    final list = entries.values.where((e) => !e.deleted).toList();
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  /// Logins for a site. Only those for this very host (and port, when the
  /// address names one) if there are any: on a home domain every subdomain is
  /// another service. Otherwise ones for its parent domain or a subdomain
  /// (login.bank.pl ↔ bank.pl).
  List<VaultEntry> forSite(String address) {
    final host = hostOf(address);
    if (host.isEmpty) return [];
    final port = _portOf(address);
    final withAddress = visible.where((e) => hostOf(e.url).isNotEmpty);

    final exact = withAddress
        .where((e) => hostOf(e.url) == host && (port == null || _portOf(e.url) == port))
        .toList();
    if (exact.isNotEmpty) return exact;
    return withAddress.where((e) {
      final entryHost = hostOf(e.url);
      return entryHost == host || host.endsWith('.$entryHost') || entryHost.endsWith('.$host');
    }).toList();
  }

  /// Every two-factor code in the vault.
  List<VaultEntry> get codes => visible.where((e) => e.isCode).toList();

  /// Codes not tied to any site yet: no address and no login pointing at
  /// them. On a code field with no code of its own these are offered.
  List<VaultEntry> get unpairedCodes {
    final linked = {for (final e in visible) if (e.twoFactor.isNotEmpty) e.twoFactor};
    return codes.where((e) => hostOf(e.url).isEmpty && !linked.contains(e.id)).toList();
  }

  /// The key a login's code comes from: its own (older entries) or its linked code's.
  String? secretFor(VaultEntry e) {
    if ((e.totpSecret ?? '').isNotEmpty) return e.totpSecret;
    final code = entries[e.twoFactor];
    return code == null || code.deleted ? null : code.totpSecret;
  }

  /// The logins pointing at a code.
  List<VaultEntry> loginsOf(VaultEntry code) =>
      visible.where((e) => e.twoFactor == code.id).toList();

  /// Ties [login] to a code, or to none with ''. The code takes the login's
  /// address; the one let go loses it, unless another login still holds it.
  void setCode(VaultEntry login, String codeId) {
    final previous = entries[login.twoFactor];
    login.twoFactor = codeId;
    if (previous != null && previous.id != codeId && previous.url == login.url &&
        loginsOf(previous).every((e) => e.id == login.id)) {
      previous.url = '';
      put(previous);
    }
    final code = entries[codeId];
    if (code != null && code.url != login.url) {
      code.url = login.url;
      put(code);
    }
  }

  /// Once: codes kept inside logins become codes of their own, tied to the
  /// login; a code saved twice is kept once. True when anything changed.
  bool splitCodes() {
    var changed = false;
    final bySecret = <String, VaultEntry>{};
    for (final code in codes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt))) {
      final same = bySecret[code.totpSecret!];
      if (same == null) {
        bySecret[code.totpSecret!] = code;
        continue;
      }
      // The same key twice: logins pointing at the extra one move over.
      for (final login in loginsOf(code)) {
        login.twoFactor = same.id;
        put(login);
      }
      remove(code.id);
      changed = true;
    }

    for (final login in visible.toList()) {
      final secret = login.totpSecret;
      if (secret == null || secret.isEmpty || login.password.isEmpty) continue;
      var code = bySecret[secret];
      if (code == null) {
        // The same id on every device, so two devices splitting at once agree.
        code = VaultEntry(
          id: 'code-${login.id}',
          title: login.username.isEmpty || login.title.contains(login.username)
              ? login.title
              : '${login.title} (${login.username})',
          totpSecret: secret,
          url: login.url,
        );
        put(code);
        bySecret[secret] = code;
      }
      login.totpSecret = null;
      login.twoFactor = code.id;
      put(login);
      changed = true;
    }

    // Codes scanned with an account name keep it in their name.
    for (final code in codes) {
      if (code.username.isEmpty) continue;
      if (!code.title.contains(code.username)) code.title = '${code.title} (${code.username})';
      code.username = '';
      put(code);
      changed = true;
    }
    return changed;
  }

  /// Logins kept more than once: the same site (host and port; the title when
  /// there is no address) and the same username. Each group newest first.
  List<List<VaultEntry>> get duplicates {
    final bySite = <String, List<VaultEntry>>{};
    for (final e in visible) {
      if (e.isCode) continue;
      final host = hostOf(e.url);
      final site = host.isNotEmpty ? '$host:${_portOf(e.url) ?? ''}' : e.title.trim().toLowerCase();
      if (site.isEmpty) continue;
      bySite.putIfAbsent('$site\n${e.username.trim().toLowerCase()}', () => []).add(e);
    }
    return [
      for (final group in bySite.values)
        if (group.length > 1) group..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    ];
  }

  /// How an entry stands among its duplicates, for the list: the newest one,
  /// and whether its password matches the newest one's.
  static Map<String, String> duplicateNotes(List<List<VaultEntry>> groups) {
    final notes = <String, String>{};
    for (final group in groups) {
      final newest = group.first;
      for (final e in group) {
        final day = DateTime.fromMillisecondsSinceEpoch(e.updatedAt).toIso8601String().substring(0, 10);
        final password = e == newest
            ? 'newest'
            : e.password == newest.password
                ? 'same password as the newest'
                : 'different password';
        notes[e.id] = '${e.username.isEmpty ? '(no username)' : e.username} · $password · changed $day';
      }
    }
    return notes;
  }

  static int? _portOf(String url) {
    var text = url.trim();
    if (!text.contains('://')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    return uri != null && uri.hasPort ? uri.port : null;
  }

  List<String> get groups {
    final names = entries.values
        .where((e) => !e.deleted && e.group.isNotEmpty)
        .map((e) => e.group)
        .toSet()
        .toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  void put(VaultEntry e) {
    e.touch();
    entries[e.id] = e;
  }

  void remove(String id) {
    final e = entries[id];
    if (e == null) return;
    e.deleted = true;
    e.password = '';
    e.totpSecret = null;
    e.touch();
  }

  String encode() => jsonEncode({
        'version': formatVersion,
        'entries': entries.values.map((e) => e.toJson()).toList(),
        'files': files.values.map((f) => f.toJson()).toList(),
        if (keyWrap != null) 'keyWrap': keyWrap!.toJson(),
      });

  factory Vault.decode(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;

    final entryMap = <String, VaultEntry>{};
    for (final raw in (root['entries'] as List<dynamic>? ?? const [])) {
      final e = VaultEntry.fromJson(raw as Map<String, dynamic>);
      entryMap[e.id] = e;
    }

    final fileMap = <String, VaultFile>{};
    for (final raw in (root['files'] as List<dynamic>? ?? const [])) {
      final f = VaultFile.fromJson(raw as Map<String, dynamic>);
      fileMap[f.id] = f;
    }

    final wrap = root['keyWrap'] as Map<String, dynamic>?;
    return Vault(
      entries: entryMap,
      files: fileMap,
      keyWrap: wrap == null ? null : KeyWrap.fromJson(wrap),
    );
  }

  static Vault merge(Vault local, Vault remote) {
    final entryMap = <String, VaultEntry>{...local.entries};
    for (final e in remote.entries.values) {
      final mine = entryMap[e.id];
      if (mine == null || e.updatedAt > mine.updatedAt) entryMap[e.id] = e;
    }

    final fileMap = <String, VaultFile>{...local.files};
    for (final f in remote.files.values) {
      final mine = fileMap[f.id];
      if (mine == null || f.updatedAt > mine.updatedAt) fileMap[f.id] = f;
    }

    // The latest password change wins, like any other edit.
    final mine = local.keyWrap;
    final theirs = remote.keyWrap;
    final wrap = theirs != null && (mine == null || theirs.changedAt > mine.changedAt) ? theirs : mine;

    return Vault(entries: entryMap, files: fileMap, keyWrap: wrap);
  }
}
