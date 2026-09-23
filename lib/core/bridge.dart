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
    required this.onReview,
    required this.neverSave,
    this.port = 19919,
  });

  final Vault Function() vault;
  final String token;
  final int port;

  /// Called when the extension sends credentials captured on a login form.
  /// A changed password is only written when [update] is set, after the
  /// user agreed in the browser.
  final Future<String> Function(
      String url, String username, String password, bool update) onSave;

  /// Keeps ([keep]) or removes an entry the extension saved on its own.
  final Future<String> Function(String id, bool keep) onReview;

  /// The sites where saving is switched off; changes are saved by the owner.
  final List<String> Function() neverSave;
  void Function(String host, bool never)? onNever;

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
        case '/code':
          await _json(response, HttpStatus.ok, await _code(payload['id'] as String? ?? ''));
        case '/never':
          final host = _hostOf(payload['url'] as String? ?? '');
          if (host.isNotEmpty) onNever?.call(host, payload['never'] == true);
          await _json(response, HttpStatus.ok, {'never': neverSave().contains(host)});
        case '/review':
          final outcome = await onReview(
            payload['id'] as String? ?? '',
            payload['keep'] == true,
          );
          await _json(response, HttpStatus.ok, {'result': outcome});
        case '/save':
          if (neverSave().contains(_hostOf(payload['url'] as String? ?? ''))) {
            await _json(response, HttpStatus.ok, {'result': 'blocked'});
            break;
          }
          final outcome = await onSave(
            payload['url'] as String? ?? '',
            payload['username'] as String? ?? '',
            payload['password'] as String? ?? '',
            payload['update'] == true,
          );
          // "created:<id>" carries the new entry, so the extension can confirm
          // or remove it once it sees whether the login worked.
          final parts = outcome.split(':');
          await _json(response, HttpStatus.ok, {
            'result': parts.first,
            if (parts.length > 1) 'id': parts.sublist(1).join(':'),
          });
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
      'never': neverSave().contains(host),
      'entries': matches
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'username': e.username,
                'group': e.group,
                'pending': e.pending,
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

  Future<Map<String, dynamic>> _code(String id) async {
    final entry = vault().entries[id];
    final secret = entry?.totpSecret;
    if (entry == null || entry.deleted || secret == null || secret.isEmpty) {
      return {'error': 'not found'};
    }
    return {'code': await totpCode(secret), 'left': secondsLeft()};
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
