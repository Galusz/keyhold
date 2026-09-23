import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto.dart';
import 'models.dart';
import 'storage.dart';

// Passed at build time (--dart-define-from-file), so the repository holds no
// Google keys and a fork can use its own Google project.
const _clientId = String.fromEnvironment('KEYHOLD_GOOGLE_CLIENT_ID');
const _clientSecret = String.fromEnvironment('KEYHOLD_GOOGLE_CLIENT_SECRET');
const _scope = 'https://www.googleapis.com/auth/drive.file';
const _folderName = 'Keyhold';
const _fileName = 'vault.khd';

class DriveError implements Exception {
  DriveError(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

class SyncResult {
  SyncResult({
    this.vault,
    this.changedHere = false,
    this.uploaded = false,
    this.needsPassword = false,
  });

  /// The merged vault when this device got something new.
  final Vault? vault;
  final bool changedHere;
  final bool uploaded;

  /// Drive holds a vault from another device; its master password unlocks it.
  final bool needsPassword;
}

/// Keeps the encrypted vault file in a "Keyhold" folder in the user's own
/// Google Drive and merges it with the local vault.
class DriveSync {
  DriveSync(this.store);

  final VaultStore store;
  String? _access;
  DateTime _accessUntil = DateTime(0);
  String? lastError;

  static bool get available => _clientId.isNotEmpty && _clientSecret.isNotEmpty;

  bool get connected => store.backup.driveToken.isNotEmpty;
  String get email => store.backup.driveEmail;
  DateTime? get syncedAt => store.backup.driveSyncedAt;

  String? get _refresh {
    final stored = store.backup.driveToken;
    if (stored.isEmpty) return null;
    return utf8.decode(store.unprotect(base64.decode(stored)));
  }

  set _refresh(String? token) {
    store.backup.driveToken =
        token == null ? '' : base64.encode(store.protect(Uint8List.fromList(utf8.encode(token))));
  }

  // ---------- sign in ----------

  /// Opens Google sign-in in the browser and waits for the answer on a
  /// one-off local address, as Google asks desktop apps to do.
  Future<void> connect() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirect = 'http://127.0.0.1:${server.port}';
    final verifier = _random(32);
    final challenge = _b64(
        (await Sha256().hash(utf8.encode(verifier))).bytes);
    final state = _random(16);

    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': _clientId,
      'redirect_uri': redirect,
      'response_type': 'code',
      'scope': _scope,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
      'state': state,
      'access_type': 'offline',
      'prompt': 'consent',
    });
    await Process.start('rundll32', ['url.dll,FileProtocolHandler', url.toString()]);

    String? code;
    try {
      await for (final request in server.timeout(const Duration(minutes: 5))) {
        final query = request.uri.queryParameters;
        if (query['state'] != state) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          continue;
        }
        code = query['code'];
        request.response.headers.contentType = ContentType.html;
        request.response.write(_page(code != null
            ? 'Keyhold is connected to Google Drive. You can close this tab.'
            : 'Google Drive was not connected. You can close this tab.'));
        await request.response.close();
        break;
      }
    } on TimeoutException {
      throw DriveError('Google sign-in took too long — try again');
    } finally {
      await server.close(force: true);
    }
    if (code == null) throw DriveError('Google sign-in was cancelled');

    final tokens = await _tokenRequest({
      'code': code,
      'code_verifier': verifier,
      'redirect_uri': redirect,
      'grant_type': 'authorization_code',
    });
    final refresh = tokens['refresh_token'] as String?;
    if (refresh == null) throw DriveError('Google did not allow offline access');
    _refresh = refresh;
    _setAccess(tokens);

    final about = await _json('GET', _api('/drive/v3/about', {'fields': 'user(emailAddress)'}));
    store.backup.driveEmail = (about['user']?['emailAddress'] ?? '') as String;
    store.backup.saveSettings();
  }

  Future<void> disconnect() async {
    final refresh = _refresh;
    _refresh = null;
    _access = null;
    store.backup
      ..driveEmail = ''
      ..driveSyncedAt = null
      ..saveSettings();
    if (refresh != null) {
      try {
        await _send('POST', Uri.https('oauth2.googleapis.com', '/revoke', {'token': refresh}));
      } catch (_) {
        // the token is gone from this device either way
      }
    }
  }

  // ---------- sync ----------

  /// Merges the vault in Drive with [local]: newest change of every entry
  /// wins, on both sides. [password] is only needed the first time this
  /// device meets a vault made elsewhere. The caller saves [SyncResult.vault].
  Future<SyncResult> sync(Vault local, {String? password}) async {
    if (!connected) return SyncResult();
    try {
      final result = await _sync(local, password);
      lastError = null;
      store.backup
        ..driveSyncedAt = DateTime.now()
        ..saveSettings();
      return result;
    } on DriveError catch (e) {
      lastError = e.message;
      rethrow;
    } on SocketException {
      lastError = 'No internet connection';
      throw DriveError(lastError!);
    }
  }

  Future<SyncResult> _sync(Vault local, String? password) async {
    final folder = await _folder();
    final remote = await _findFile(folder);

    if (remote == null) {
      if (!store.hasPassword) {
        throw DriveError('Set a master password first — a new device needs it to open the vault');
      }
      await _upload(folder, null, await store.fileFor(local));
      return SyncResult(uploaded: true);
    }

    final bytes = await _download(remote);
    Vault theirs;
    var adopted = false;
    try {
      theirs = await store.open(bytes);
    } catch (_) {
      if (password == null) return SyncResult(needsPassword: true);
      if (!await store.adopt(bytes, password)) throw DriveError('Wrong master password');
      theirs = await store.open(bytes);
      adopted = true;
    }

    final merged = Vault.merge(local, theirs);
    final changedHere = adopted || _hasNewer(theirs, local);
    final changedThere = _hasNewer(local, theirs);

    if (changedThere) await _upload(folder, remote, await store.fileFor(merged));

    return SyncResult(
      vault: changedHere ? merged : null,
      changedHere: changedHere,
      uploaded: changedThere,
    );
  }

  /// Whether [a] holds an entry or file that [b] lacks or has older.
  bool _hasNewer(Vault a, Vault b) {
    for (final e in a.entries.values) {
      final other = b.entries[e.id];
      if (other == null || e.updatedAt > other.updatedAt) return true;
    }
    for (final f in a.files.values) {
      final other = b.files[f.id];
      if (other == null || f.updatedAt > other.updatedAt) return true;
    }
    return false;
  }

  // ---------- Drive files ----------

  Future<String> _folder() async {
    final found = await _json('GET', _api('/drive/v3/files', {
      'q': "name = '$_folderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      'fields': 'files(id)',
      'spaces': 'drive',
    }));
    final files = found['files'] as List<dynamic>;
    if (files.isNotEmpty) return files.first['id'] as String;

    final created = await _json('POST', _api('/drive/v3/files', {'fields': 'id'}),
        body: {'name': _folderName, 'mimeType': 'application/vnd.google-apps.folder'});
    return created['id'] as String;
  }

  Future<String?> _findFile(String folder) async {
    final found = await _json('GET', _api('/drive/v3/files', {
      'q': "name = '$_fileName' and '$folder' in parents and trashed = false",
      'fields': 'files(id)',
      'orderBy': 'modifiedTime desc',
      'spaces': 'drive',
    }));
    final files = found['files'] as List<dynamic>;
    return files.isEmpty ? null : files.first['id'] as String;
  }

  Future<Uint8List> _download(String id) async {
    final (status, body) = await _authorized('GET', _api('/drive/v3/files/$id', {'alt': 'media'}));
    if (status != 200) throw DriveError('Google Drive refused the download ($status)');
    return body;
  }

  Future<void> _upload(String folder, String? id, Uint8List bytes) async {
    if (id != null) {
      final (status, _) = await _authorized(
        'PATCH',
        Uri.https('www.googleapis.com', '/upload/drive/v3/files/$id', {'uploadType': 'media'}),
        headers: {'content-type': 'application/octet-stream'},
        body: bytes,
      );
      if (status != 200) throw DriveError('Google Drive refused the upload ($status)');
      return;
    }

    const boundary = 'keyhold-boundary-7f3a';
    final meta = jsonEncode({'name': _fileName, 'parents': [folder]});
    final body = BytesBuilder()
      ..add(utf8.encode('--$boundary\r\ncontent-type: application/json; charset=UTF-8\r\n\r\n$meta\r\n'))
      ..add(utf8.encode('--$boundary\r\ncontent-type: application/octet-stream\r\n\r\n'))
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--\r\n'));
    final (status, _) = await _authorized(
      'POST',
      Uri.https('www.googleapis.com', '/upload/drive/v3/files', {'uploadType': 'multipart'}),
      headers: {'content-type': 'multipart/related; boundary=$boundary'},
      body: body.takeBytes(),
    );
    if (status != 200) throw DriveError('Google Drive refused the upload ($status)');
  }

  // ---------- HTTP ----------

  Uri _api(String path, Map<String, String> query) =>
      Uri.https('www.googleapis.com', path, query);

  Future<Map<String, dynamic>> _json(String method, Uri uri, {Object? body}) async {
    final (status, bytes) = await _authorized(
      method,
      uri,
      headers: body == null ? const {} : {'content-type': 'application/json'},
      body: body == null ? null : utf8.encode(jsonEncode(body)),
    );
    if (status < 200 || status >= 300) throw DriveError('Google Drive answered $status');
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  Future<(int, Uint8List)> _authorized(String method, Uri uri,
      {Map<String, String> headers = const {}, List<int>? body}) async {
    var result = await _send(method, uri,
        headers: {...headers, 'authorization': 'Bearer ${await _token()}'}, body: body);
    if (result.$1 == 401) {
      _access = null;
      result = await _send(method, uri,
          headers: {...headers, 'authorization': 'Bearer ${await _token()}'}, body: body);
    }
    return result;
  }

  Future<String> _token() async {
    if (_access != null && DateTime.now().isBefore(_accessUntil)) return _access!;
    final refresh = _refresh;
    if (refresh == null) throw DriveError('Google Drive is not connected');
    try {
      _setAccess(await _tokenRequest({'refresh_token': refresh, 'grant_type': 'refresh_token'}));
    } on DriveError catch (e) {
      // 400/401: revoked, or expired while the Google project was still in testing
      if (e.status == 400 || e.status == 401) {
        await disconnect();
        throw DriveError('Google Drive access ended — connect again');
      }
      rethrow;
    }
    return _access!;
  }

  void _setAccess(Map<String, dynamic> tokens) {
    _access = tokens['access_token'] as String;
    final seconds = (tokens['expires_in'] as num?)?.toInt() ?? 3600;
    _accessUntil = DateTime.now().add(Duration(seconds: seconds - 60));
  }

  Future<Map<String, dynamic>> _tokenRequest(Map<String, String> fields) async {
    final (status, bytes) = await _send(
      'POST',
      Uri.https('oauth2.googleapis.com', '/token'),
      headers: {'content-type': 'application/x-www-form-urlencoded'},
      body: utf8.encode(Uri(queryParameters: {
        ...fields,
        'client_id': _clientId,
        'client_secret': _clientSecret,
      }).query),
    );
    if (status != 200) throw DriveError('Google sign-in failed ($status)', status: status);
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  Future<(int, Uint8List)> _send(String method, Uri uri,
      {Map<String, String> headers = const {}, List<int>? body}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.openUrl(method, uri);
      headers.forEach(request.headers.set);
      if (body != null) {
        request.contentLength = body.length;
        request.add(body);
      }
      final response = await request.close().timeout(const Duration(seconds: 60));
      final bytes = BytesBuilder();
      await response.forEach(bytes.add);
      return (response.statusCode, bytes.takeBytes());
    } finally {
      client.close();
    }
  }

  static String _b64(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');
  static String _random(int length) => _b64(randomBytes(length));

  static String _page(String text) => '<!doctype html><meta charset="utf-8"><title>Keyhold</title>'
      '<body style="font:18px system-ui;background:#0E1715;color:#E6F2EE;display:grid;place-items:center;height:90vh">'
      '<p>$text</p></body>';
}
