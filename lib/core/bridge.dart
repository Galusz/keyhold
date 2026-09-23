import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'models.dart';
import 'totp.dart';

/// Local endpoint the browser extension talks to.
///
/// Bound to the loopback interface only, so nothing outside this machine can
/// reach it, and every call must carry the pairing token shown in the app.
class BrowserBridge {
  BrowserBridge({
    required this.vault,
    required this.token,
    required this.onSave,
    this.port = 19919,
  });

  final Vault Function() vault;
  final String token;
  final int port;

  /// Called when the extension sends credentials captured on a login form.
  final Future<String> Function(String url, String username, String password)
      onSave;

  HttpServer? _server;

  bool get running => _server != null;

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handle, onError: (_) {});
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    final origin = request.headers.value('origin') ?? '';

    response.headers
      ..set('Access-Control-Allow-Origin', origin.isEmpty ? '*' : origin)
      ..set('Access-Control-Allow-Headers', 'content-type, x-keyhold-token')
      ..set('Access-Control-Allow-Methods', 'POST, OPTIONS');

    if (request.method == 'OPTIONS') {
      response.statusCode = HttpStatus.noContent;
      await response.close();
      return;
    }

    // Only the extension may call in; a web page has an http(s) origin.
    if (!_originAllowed(origin)) {
      await _json(response, HttpStatus.forbidden, {'error': 'origin'});
      return;
    }

    if (request.headers.value('x-keyhold-token') != token) {
      await _json(response, HttpStatus.unauthorized, {'error': 'token'});
      return;
    }

    try {
      final body = await utf8.decoder.bind(request).join();
      final payload = body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(body) as Map<String, dynamic>;

      switch (request.uri.path) {
        case '/lookup':
          await _json(response, HttpStatus.ok, _lookup(payload['url'] as String? ?? ''));
        case '/fill':
          await _json(response, HttpStatus.ok, await _fill(payload['id'] as String? ?? ''));
        case '/save':
          final outcome = await onSave(
            payload['url'] as String? ?? '',
            payload['username'] as String? ?? '',
            payload['password'] as String? ?? '',
          );
          await _json(response, HttpStatus.ok, {'result': outcome});
        default:
          await _json(response, HttpStatus.notFound, {'error': 'unknown'});
      }
    } catch (e) {
      await _json(response, HttpStatus.internalServerError, {'error': '$e'});
    }
  }

  bool _originAllowed(String origin) =>
      origin.startsWith('chrome-extension://') ||
      origin.startsWith('moz-extension://');

  Map<String, dynamic> _lookup(String pageUrl) {
    final host = _hostOf(pageUrl);
    if (host.isEmpty) return {'entries': <dynamic>[]};

    final matches = vault().visible.where((e) {
      final entryHost = _hostOf(e.url);
      if (entryHost.isEmpty) return false;
      return entryHost == host ||
          host.endsWith('.$entryHost') ||
          entryHost.endsWith('.$host');
    }).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return {
      'entries': matches
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'username': e.username,
                'hasCode': e.totpSecret != null && e.totpSecret!.isNotEmpty,
              })
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _fill(String id) async {
    final entry = vault().entries[id];
    if (entry == null || entry.deleted) return {'error': 'not found'};

    final secret = entry.totpSecret;
    return {
      'username': entry.username,
      'password': entry.password,
      'code': secret == null || secret.isEmpty ? null : await totpCode(secret),
    };
  }

  String _hostOf(String url) {
    var text = url.trim();
    if (text.isEmpty) return '';
    if (!text.contains('://')) text = 'https://$text';
    final host = Uri.tryParse(text)?.host.toLowerCase() ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  Future<void> _json(HttpResponse response, int status, Object body) async {
    response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await response.close();
  }
}
