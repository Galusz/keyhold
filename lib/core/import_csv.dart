import 'package:csv/csv.dart';

import 'models.dart';

class ImportResult {
  ImportResult({required this.entries, required this.skipped, this.error});

  final List<VaultEntry> entries;
  final int skipped;
  final String? error;
}

const _titleNames = ['name', 'title', 'account'];
const _userNames = ['username', 'login', 'user', 'login_username', 'email'];
const _passwordNames = ['password', 'login_password', 'pass'];
const _urlNames = ['url', 'website', 'login_uri', 'origin', 'web site'];
const _noteNames = ['note', 'notes', 'comment'];

int _indexOf(List<String> header, List<String> candidates) {
  for (var i = 0; i < header.length; i++) {
    if (candidates.contains(header[i])) return i;
  }
  return -1;
}

String _cell(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) return '';
  return (row[index] ?? '').toString().trim();
}

String _hostOf(String url) {
  final uri = Uri.tryParse(url);
  final host = uri?.host ?? '';
  return host.startsWith('www.') ? host.substring(4) : host;
}

ImportResult parseCsv(String source) {
  final rows = csv.decode(source.replaceAll('\r\n', '\n'));

  if (rows.isEmpty) {
    return ImportResult(entries: [], skipped: 0, error: 'The file is empty');
  }

  final header = rows.first
      .map((c) => c.toString().trim().toLowerCase().replaceAll('"', ''))
      .toList();

  final titleAt = _indexOf(header, _titleNames);
  final userAt = _indexOf(header, _userNames);
  final passwordAt = _indexOf(header, _passwordNames);
  final urlAt = _indexOf(header, _urlNames);
  final noteAt = _indexOf(header, _noteNames);

  if (passwordAt < 0 && userAt < 0) {
    return ImportResult(
      entries: [],
      skipped: 0,
      error: 'No username or password column found in this file',
    );
  }

  final entries = <VaultEntry>[];
  var skipped = 0;

  for (final row in rows.skip(1)) {
    final username = _cell(row, userAt);
    final password = _cell(row, passwordAt);
    final url = _cell(row, urlAt);

    if (username.isEmpty && password.isEmpty) {
      skipped++;
      continue;
    }

    var title = _cell(row, titleAt);
    if (title.isEmpty) title = _hostOf(url);
    if (title.isEmpty) title = username;

    entries.add(VaultEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}-${entries.length}',
      title: title,
      username: username,
      password: password,
      url: url,
      notes: _cell(row, noteAt),
    ));
  }

  return ImportResult(entries: entries, skipped: skipped);
}
