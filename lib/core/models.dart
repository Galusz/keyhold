import 'dart:convert';

class VaultEntry {
  final String id;
  String title;
  String username;
  String password;
  String url;
  String notes;
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
        totpSecret: j['totp'] as String?,
        updatedAt: (j['updatedAt'] ?? 0) as int,
        deleted: (j['deleted'] ?? false) as bool,
      );

  void touch() => updatedAt = DateTime.now().millisecondsSinceEpoch;
}

class Vault {
  static const int formatVersion = 1;

  final Map<String, VaultEntry> entries;

  Vault({Map<String, VaultEntry>? entries}) : entries = entries ?? {};

  List<VaultEntry> get visible {
    final list = entries.values.where((e) => !e.deleted).toList();
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
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
      });

  factory Vault.decode(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;
    final list = (root['entries'] as List<dynamic>? ?? const []);
    final map = <String, VaultEntry>{};
    for (final raw in list) {
      final e = VaultEntry.fromJson(raw as Map<String, dynamic>);
      map[e.id] = e;
    }
    return Vault(entries: map);
  }

  static Vault merge(Vault local, Vault remote) {
    final map = <String, VaultEntry>{};
    for (final e in local.entries.values) {
      map[e.id] = e;
    }
    for (final e in remote.entries.values) {
      final mine = map[e.id];
      if (mine == null || e.updatedAt > mine.updatedAt) {
        map[e.id] = e;
      }
    }
    return Vault(entries: map);
  }
}
