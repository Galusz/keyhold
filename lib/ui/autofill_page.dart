import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/drive.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../core/totp.dart';
import 'vault_page.dart' show SiteAvatar;

/// Logins for a web page ([site]) or an app ([app]). An app has no address:
/// its logins are kept under `androidapp://package`, or found under its
/// website — pl.mbank.android → mbank.pl.
List<VaultEntry> autofillMatches(Vault vault, String site, String app) {
  if (site.isNotEmpty) return vault.forSite(site);
  final found = vault.forSite('androidapp://$app');
  final parts = app.split('.');
  if (parts.length >= 2) {
    for (final e in vault.forSite('${parts[1]}.${parts[0]}')) {
      if (!found.contains(e)) found.add(e);
    }
  }
  return found;
}

/// Answers the phone's autofill service, which runs this without a screen to
/// put the logins right under the field.
Future<void> serveAutofillLookups() async {
  DartPluginRegistrant.ensureInitialized();
  const channel = MethodChannel('keyhold/autofill-lookup');
  final store = VaultStore();
  final opened = store.init();

  channel.setMethodCallHandler((call) async {
    if (call.method != 'lookup' || !await opened) return <Object>[];
    final args = call.arguments as Map;
    // Read afresh every time: the app or a sync may have changed the vault.
    final vault = await store.load();
    final wantsCode = args['wantsCode'] == true;
    final matches = autofillMatches(vault, args['domain'] as String? ?? '', args['app'] as String? ?? '');
    // A code field with no code for this site: the codes not tied to any site yet.
    final unpaired = wantsCode && !matches.any((e) => (e.totpSecret ?? '').isNotEmpty)
        ? vault.unpairedCodes
        : const <VaultEntry>[];
    return [
      for (final e in [...matches, ...unpaired])
        {
          'id': e.id,
          'title': e.title,
          'username': e.username,
          'password': e.password,
          'code': wantsCode && (e.totpSecret ?? '').isNotEmpty ? await totpCode(e.totpSecret!) : null,
          'unpaired': unpaired.contains(e),
        },
    ];
  });
  await channel.invokeMethod('ready');
}

/// Behind the "Keyhold" suggestion Android shows under a login field: pick
/// the login to fill, or keep one Android offered to save.
class AutofillPage extends StatefulWidget {
  const AutofillPage({super.key});

  @override
  State<AutofillPage> createState() => _AutofillPageState();
}

class _AutofillPageState extends State<AutofillPage> {
  static const _channel = MethodChannel('keyhold/autofill');

  final _store = VaultStore();
  final _search = TextEditingController();
  Map<String, dynamic> _request = {};
  Vault _vault = Vault();
  bool _loading = true;
  String? _message;

  String get _site => _request['domain'] as String? ?? '';
  String get _app => _request['app'] as String? ?? '';

  /// Apps have no address; their logins are kept under `androidapp://package`.
  String get _address => _site.isNotEmpty ? _site : 'androidapp://$_app';

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    _request = await _channel.invokeMapMethod<String, dynamic>('request') ?? {};
    if (!await _store.init()) {
      setState(() {
        _message = 'Open Keyhold once and enter the master password, then try again.';
        _loading = false;
      });
      return;
    }
    _vault = await _store.load();
    if (_request['mode'] == 'save') {
      await _keep();
      return;
    }
    final entry = _request['entry'] as String?;
    if (entry != null) {
      await _fillCode(entry);
      return;
    }
    setState(() => _loading = false);
  }

  /// Behind a two-factor suggestion: the code of this very moment, or —
  /// quietly — the next one when this one is in its last second.
  Future<void> _fillCode(String id) async {
    final e = _vault.entries[id];
    final secret = e?.totpSecret;
    if (e == null || e.deleted || secret == null || secret.isEmpty) {
      await _channel.invokeMethod('close');
      return;
    }
    final left = secondsLeft();
    if (left <= 1) await Future<void>.delayed(Duration(milliseconds: left * 1000 + 200));
    await _pair(e);
    await _channel.invokeMethod('fill', {'code': await totpCode(secret)});
  }

  /// A code with no site yet belongs to this site or app from now on.
  Future<void> _pair(VaultEntry e) async {
    if ((e.totpSecret ?? '').isEmpty || hostOf(e.url).isNotEmpty) return;
    e.url = _site.isNotEmpty ? 'https://$_site' : _address;
    _vault.put(e);
    await _store.save(_vault);
  }

  List<VaultEntry> get _shown {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return autofillMatches(_vault, _site, _app);
    return _vault.visible
        .where((e) => '${e.title} ${e.username} ${e.url}'.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _pick(VaultEntry e) async {
    final secret = e.totpSecret;
    final code = _request['wantsCode'] == true && secret != null && secret.isNotEmpty
        ? await totpCode(secret)
        : null;
    if (code != null) await _pair(e);
    await _channel.invokeMethod('fill', {
      'username': e.username,
      'password': e.password,
      'code': code,
    });
  }

  /// Android asked "Save to Keyhold?" and the user agreed.
  Future<void> _keep() async {
    final username = _request['username'] as String? ?? '';
    final password = _request['password'] as String? ?? '';
    final label = _request['label'] as String? ?? '';

    final existing = _vault.forSite(_address).where((e) => e.username == username).firstOrNull;
    if (existing != null) {
      if (existing.password != password) {
        existing.password = password;
        _vault.put(existing);
      }
    } else {
      _vault.put(VaultEntry(
        id: UniqueKey().toString(),
        title: _site.isNotEmpty ? _site : (label.isNotEmpty ? label : _app),
        username: username,
        password: password,
        url: _site.isNotEmpty ? 'https://$_site' : _address,
        group: _site.isNotEmpty ? 'Web' : 'Apps',
      ));
    }
    await _store.save(_vault);
    setState(() {
      _message = existing == null ? 'Saved to Keyhold' : 'Password updated in Keyhold';
      _loading = false;
    });

    // Straight on to the computer, not only when the app is opened next.
    final drive = DriveSync(_store);
    if (drive.connected) {
      try {
        final result = await drive.sync(_vault);
        final theirs = result.vault;
        if (theirs != null) await _store.save(Vault.merge(_vault, theirs));
      } catch (_) {
        // the app syncs again when it is opened
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _channel.invokeMethod('close');
  }

  @override
  Widget build(BuildContext context) {
    // Filling a two-factor code: nothing to see.
    if (_request['entry'] != null) return const SizedBox.shrink();
    final title = _site.isNotEmpty ? _site : (_request['label'] as String? ?? 'Keyhold');
    return Scaffold(
      appBar: AppBar(
        title: Text(title.isEmpty ? 'Keyhold' : title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _channel.invokeMethod('close'),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_message != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_message!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        ),
      );
    }

    final shown = _shown;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search all logins',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _search.text.isEmpty
                        ? 'No login for this ${_site.isNotEmpty ? 'site' : 'app'} yet. Search above, or log in and Android will offer to save it.'
                        : 'Nothing found.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  children: [
                    for (final e in shown)
                      ListTile(
                        leading: SiteAvatar(entry: e, icons: _store.icons),
                        title: Text(e.title.isEmpty ? '(no title)' : e.title),
                        subtitle: Text(e.username),
                        onTap: () => _pick(e),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
