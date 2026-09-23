import 'dart:convert';
import 'dart:typed_data';

class VaultEntry {
  final String id;
  String title;
  String username;
  String password;
  String url;
  String notes;
  String group;
  String? totpSecret;
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
        updatedAt: (j['updatedAt'] ?? 0) as int,
        deleted: (j['deleted'] ?? false) as bool,
      );

  void touch() => updatedAt = DateTime.now().millisecondsSinceEpoch;
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

class Vault {
  static const int formatVersion = 1;

  final Map<String, VaultEntry> entries;
  final Map<String, VaultFile> files;

  Vault({Map<String, VaultEntry>? entries, Map<String, VaultFile>? files})
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

    return Vault(entries: entryMap, files: fileMap);
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

    return Vault(entries: entryMap, files: fileMap);
  }
}
