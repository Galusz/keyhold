import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
    required this.loginState,
    required this.storeLogin,
    required this.neverSave,
    required this.autoSave,
    this.port = 19919,
  });

  /// How long a caught login waits for the user's answer.
  static const offerTime = Duration(minutes: 2);

  final Vault Function() vault;
  final String token;
  final int port;

  /// 'same', 'changed' or 'new' for a login caught on a form.
  final String Function(String url, String username, String password) loginState;

  /// Writes a login the user kept; returns 'saved' or 'updated'.
  final Future<String> Function(String url, String username, String password) storeLogin;

  /// The sites where saving is switched off; changes are saved by the owner.
  final List<String> Function() neverSave;
  void Function(String host, bool never)? onNever;

  final bool Function() autoSave;
  void Function(bool on)? onAutoSave;

  /// Caught logins stay in memory only — nothing reaches the vault, the disk
  /// or Drive until the user keeps them — and are forgotten after [offerTime].
  final _offers = <String, _Offer>{};

  HttpServer? _server;

  bool get running => _server != null;

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handle, onError: (_) {});
  }

  Future<void> stop() async {
    _drop((_) => true);
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
          final never = payload['never'] == true;
          if (host.isNotEmpty) onNever?.call(host, never);
          if (never) _drop((o) => o.host == host);
          await _json(response, HttpStatus.ok, {'never': neverSave().contains(host)});
        case '/autosave':
          onAutoSave?.call(payload['on'] == true);
          await _json(response, HttpStatus.ok, {'autoSave': autoSave()});
        case '/save':
          await _json(response, HttpStatus.ok, _offer(payload));
        case '/offers':
          final now = DateTime.now();
          await _json(response, HttpStatus.ok, {
            'offers': _offers.entries
                .map((o) => {
                      'id': o.key,
                      'host': o.value.host,
                      'username': o.value.username,
                      'changed': o.value.changed,
                      'left': offerTime.inSeconds - now.difference(o.value.at).inSeconds,
                    })
                .toList(),
          });
        case '/review':
          final offer = _offers.remove(payload['id'] as String? ?? '');
          offer?.expiry.cancel();
          final String outcome;
          if (offer == null) {
            outcome = 'missing';
          } else if (payload['keep'] == true) {
            outcome = await storeLogin(offer.url, offer.username, offer.password);
          } else {
            outcome = 'dropped';
          }
          await _json(response, HttpStatus.ok, {'result': outcome});
        default:
          await _json(response, HttpStatus.notFound, {'error': 'unknown'});
      }
    } catch (e) {
      await _json(response, HttpStatus.internalServerError, {'error': '$e'});
    }
  }

  Map<String, dynamic> _offer(Map<String, dynamic> payload) {
    final url = payload['url'] as String? ?? '';
    final username = payload['username'] as String? ?? '';
    final password = payload['password'] as String? ?? '';
    final host = _hostOf(url);
    if (password.isEmpty || host.isEmpty) return {'result': 'ignored'};
    if (neverSave().contains(host)) return {'result': 'blocked'};

    final state = loginState(url, username, password);
    if (state == 'same') return {'result': 'same'};

    // A retry on the same site replaces the earlier attempt.
    _drop((o) => o.host == host && o.username == username);
    final id = _newId();
    _offers[id] = _Offer(
      url: url,
      host: host,
      username: username,
      password: password,
      changed: state == 'changed',
      expiry: Timer(offerTime, () => _offers.remove(id)),
    );
    return {'result': 'offered', 'id': id, 'autoSave': autoSave()};
  }

  void _drop(bool Function(_Offer offer) test) {
    _offers.removeWhere((_, offer) {
      if (!test(offer)) return false;
      offer.expiry.cancel();
      return true;
    });
  }

  final _random = Random.secure();

  String _newId() =>
      List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

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
      'autoSave': autoSave(),
      'entries': matches
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'username': e.username,
                'group': e.group,
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

class _Offer {
  _Offer({
    required this.url,
    required this.host,
    required this.username,
    required this.password,
    required this.changed,
    required this.expiry,
  });

  final String url;
  final String host;
  final String username;
  final String password;

  /// A new password for a login the vault already has.
  final bool changed;
  final Timer expiry;
  final at = DateTime.now();
}
