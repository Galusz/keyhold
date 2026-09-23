import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

import 'models.dart';

/// Site icons shown instead of letters.
///
/// Fetched straight from each site or device — never through a third-party
/// icon service, which would learn every site the user has an account on —
/// and kept on disk next to the vault, not inside it.
class Favicons {
  Favicons(this._dir) {
    if (!_dir.existsSync()) _dir.createSync(recursive: true);
  }

  final Directory _dir;
  static const _size = 64;
  static const _retryAfter = Duration(days: 1);
  static const _parallel = 4;

  /// Bumped whenever an icon arrives, so lists can redraw.
  final changed = ValueNotifier<int>(0);

  final _images = <String, MemoryImage?>{};
  final _queue = <(String, String)>[];
  final _busy = <String>{};
  var _running = 0;

  /// The icon for [address] (a URL, or a bare host with an optional port),
  /// or null while there is none; a missing one is fetched in the background.
  MemoryImage? of(String address) {
    final key = keyOf(address);
    if (key.isEmpty) return null;
    if (_images.containsKey(key)) return _images[key];

    final file = _file(key, 'png');
    if (file.existsSync()) {
      return _images[key] = MemoryImage(file.readAsBytesSync());
    }
    final none = _file(key, 'none');
    if (none.existsSync() && DateTime.now().difference(none.lastModifiedSync()) < _retryAfter) {
      return _images[key] = null;
    }
    _images[key] = null;
    if (_busy.add(key)) {
      _queue.add((key, address));
      _pump();
    }
    return null;
  }

  /// Where an entry's icon comes from: its address, or a title that is one.
  static String addressOf(VaultEntry e) => e.url.isNotEmpty ? e.url : e.title;

  /// Starts fetching every missing icon, so the extension has them too.
  void fetchAll(Iterable<VaultEntry> entries) {
    for (final e in entries) {
      of(addressOf(e));
    }
  }

  /// PNG bytes of an icon already on disk, for the browser extension.
  Uint8List? bytesOf(String address) {
    final key = keyOf(address);
    if (key.isEmpty) return null;
    final file = _file(key, 'png');
    return file.existsSync() ? file.readAsBytesSync() : null;
  }

  /// "ha.zkv.pl", "192.168.68.15:2283" — one icon per site, whatever the path.
  static String keyOf(String address) {
    var text = address.trim().toLowerCase();
    if (text.isEmpty || text.contains(' ')) return '';
    if (!text.contains('://')) text = 'https://$text';
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.host.contains('.') && uri.host != 'localhost') return '';
    final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    return uri.hasPort ? '$host:${uri.port}' : host;
  }

  File _file(String key, String ext) =>
      File('${_dir.path}${Platform.pathSeparator}${key.replaceAll(':', '_')}.$ext');

  void _pump() {
    while (_running < _parallel && _queue.isNotEmpty) {
      final (key, address) = _queue.removeAt(0);
      _running++;
      _load(key, address).whenComplete(() {
        _running--;
        _busy.remove(key);
        _pump();
      });
    }
  }

  Future<void> _load(String key, String address) async {
    Uint8List? png;
    try {
      png = await _find(address).timeout(const Duration(seconds: 20));
      // Login pages on a subdomain (id.…, passport.…) often have no icon of their own.
      final parent = _parentOf(address);
      if (png == null && parent != null) {
        png = await _find(parent).timeout(const Duration(seconds: 20));
      }
    } catch (_) {
      png = null;
    }
    if (png == null) {
      _file(key, 'none').writeAsStringSync('');
      return;
    }
    _file(key, 'png').writeAsBytesSync(png);
    final none = _file(key, 'none');
    if (none.existsSync()) none.deleteSync();
    _images[key] = MemoryImage(png);
    changed.value++;
  }

  String? _parentOf(String address) {
    final text = address.contains('://') ? address : 'https://$address';
    final host = Uri.tryParse(text)?.host ?? '';
    final labels = host.split('.');
    if (labels.length < 3 || RegExp(r'^[\d.]+$').hasMatch(host)) return null;
    return labels.sublist(1).join('.');
  }

  /// Tries the address as given first, then the other scheme: home devices
  /// often answer only on http, or on https with a self-signed certificate.
  Future<Uint8List?> _find(String address) async {
    var text = address.trim();
    final given = text.contains('://');
    if (!given) text = 'https://$text';
    final first = Uri.parse(text);
    final other = first.replace(scheme: first.scheme == 'http' ? 'https' : 'http');

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 4)
      ..userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Keyhold'
      // Only an image is fetched, nothing is sent, so a home device's own
      // certificate is fine here.
      ..badCertificateCallback = (_, _, _) => true;
    try {
      for (final uri in [first, other]) {
        final origin = uri.replace(path: '/', query: null, fragment: null);
        // Some shops refuse the page to anything but a real browser, yet still
        // hand out /favicon.ico.
        final page = await _get(client, origin, 512 * 1024);
        final candidates = [
          if (page != null) ..._links(utf8.decode(page.$1, allowMalformed: true), page.$2),
          (page?.$2 ?? origin).resolve('/favicon.ico'),
        ];
        for (final candidate in candidates) {
          final icon = await _get(client, candidate, 1024 * 1024);
          final png = icon == null ? null : _toPng(icon.$1);
          if (png != null) return png;
        }
        if (page != null) return null;
      }
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Body (up to [limit] bytes) and the address it finally came from.
  Future<(Uint8List, Uri)?> _get(HttpClient client, Uri uri, int limit) async {
    try {
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode >= 400) {
        await response.drain<void>();
        return null;
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.timeout(const Duration(seconds: 6))) {
        builder.add(chunk);
        if (builder.length > limit) break;
      }
      final landed = response.redirects.isEmpty ? uri : uri.resolveUri(response.redirects.last.location);
      return (builder.takeBytes(), landed);
    } catch (_) {
      return null;
    }
  }

  static final _linkTag = RegExp(r'<link\b[^>]*>', caseSensitive: false);

  /// Icons the page names itself, the larger and the more touch-friendly first.
  List<Uri> _links(String html, Uri base) {
    final found = <(int, Uri)>[];
    for (final match in _linkTag.allMatches(html)) {
      final tag = match.group(0)!;
      final rel = _attr(tag, 'rel')?.toLowerCase() ?? '';
      final href = _attr(tag, 'href');
      if (!rel.contains('icon') || href == null || href.isEmpty) continue;
      if (href.toLowerCase().contains('.svg') || href.startsWith('data:')) continue;
      final sizes = _attr(tag, 'sizes') ?? '';
      var score = int.tryParse(RegExp(r'(\d+)x').firstMatch(sizes)?.group(1) ?? '') ?? 32;
      if (rel.contains('apple-touch')) score += 1000;
      found.add((score, base.resolve(href)));
    }
    found.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final f in found) f.$2];
  }

  String? _attr(String tag, String name) {
    final match = RegExp('\\b$name\\s*=\\s*("([^"]*)"|\'([^\']*)\'|([^\\s>]+))', caseSensitive: false)
        .firstMatch(tag);
    if (match == null) return null;
    return match.group(2) ?? match.group(3) ?? match.group(4);
  }

  Uint8List? _toPng(Uint8List bytes) {
    try {
      final decoder = img.findDecoderForData(bytes);
      if (decoder == null) return null;
      final image = decoder is img.IcoDecoder ? decoder.decodeImageLargest(bytes) : decoder.decode(bytes);
      if (image == null || image.width < 16 || image.height < 16) return null;
      final square = img.copyResize(
        image,
        width: _size,
        height: _size,
        maintainAspect: true,
        interpolation: img.Interpolation.average,
      );
      return img.encodePng(square);
    } catch (_) {
      return null;
    }
  }
}
