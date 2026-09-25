import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/drive.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../core/totp.dart';
import '../l10n/l10n.dart';
import 'mobile_page.dart' show askFingerprint;
import 'vault_page.dart' show SiteAvatar;

/// Logins for a web page ([site]) or an app ([app]). An app has no address:
/// only logins kept under its own `androidapp://package` are offered by
/// themselves — a look-alike app must not get the bank's login; the search
/// screen finds any other.
List<VaultEntry> autofillMatches(Vault vault, String site, String app) {
  final address = site.isNotEmpty ? site : 'androidapp://$app';
  return [
    ...vault.forSite(address).where((e) => !e.isCode),
    ...vault.codesForSite(address),
  ];
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
    final unpaired = wantsCode && !matches.any((e) => (vault.secretFor(e) ?? '').isNotEmpty)
        ? vault.unpairedCodes
        : const <VaultEntry>[];
    // A code field lists the codes; a login pointing at one would repeat it.
    final offered = wantsCode
        ? [...matches.where((e) => e.twoFactor.isEmpty), ...unpaired]
        : matches.where((e) => !e.isCode).toList();
    return [
      for (final e in offered)
        {
          'id': e.id,
          'title': e.title,
          'username': e.username,
          'password': e.password,
          'code': wantsCode && (vault.secretFor(e) ?? '').isNotEmpty ? await totpCode(vault.secretFor(e)!) : null,
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
        _message = t.openKeyholdFirst;
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
    // The whole vault on show: the fingerprint lock applies here too.
    if (_store.backup.fingerprintLock && !await askFingerprint()) {
      await _channel.invokeMethod('close');
      return;
    }
    setState(() => _loading = false);
  }

  /// Behind a two-factor suggestion: the code of this very moment, or —
  /// quietly — the next one when this one is in its last second.
  Future<void> _fillCode(String id) async {
    final e = _vault.entries[id];
    final secret = e == null ? null : _vault.secretFor(e);
    if (e == null || e.deleted || secret == null || secret.isEmpty) {
      await _channel.invokeMethod('close');
      return;
    }
    await _offerPin(e);
    final left = secondsLeft();
    if (left <= 1) await Future<void>.delayed(Duration(milliseconds: left * 1000 + 200));
    await _channel.invokeMethod('fill', {'code': await totpCode(secret)});
  }

  /// A code with no site yet: asks from the bottom of the screen whether it
  /// belongs to this site or app from now on.
  Future<void> _offerPin(VaultEntry e) async {
    if (!e.isCode || _vault.sitesOf(e).isNotEmpty) return;
    if (_store.backup.noPinAsk.contains(e.id)) return;
    final place = _site.isNotEmpty ? _site : ((_request['label'] as String?) ?? _app);
    var never = false;
    final pin = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.pinTo(e.title, place), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(t.pinHint),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: never,
                  onChanged: (v) => setSheet(() => never = v ?? false),
                  title: Text(t.doNotAskCode),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.notNow)),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.pin)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (never) {
      _store.backup.noPinAsk.add(e.id);
      _store.backup.saveSettings();
    }
    if (pin != true) return;
    _vault.addSite(e, _site.isNotEmpty ? 'https://$_site' : _address);
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
    final secret = _vault.secretFor(e);
    final wantsCode = _request['wantsCode'] == true && secret != null && secret.isNotEmpty;
    if (wantsCode) await _offerPin(e);
    final code = wantsCode ? await totpCode(secret) : null;
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

    final existing = _vault.loginAt(_address, username);
    if (existing != null) {
      if (existing.password != password) {
        existing.password = password;
        _vault.put(existing);
      }
    } else {
      _vault.put(VaultEntry(
        id: newId(),
        title: _site.isNotEmpty ? _site : (label.isNotEmpty ? label : _app),
        username: username,
        password: password,
        url: _site.isNotEmpty ? 'https://$_site' : _address,
        group: _site.isNotEmpty ? _vault.defaultGroup('Web', t.groupWeb) : _vault.defaultGroup('Apps', t.groupApps),
      ));
    }
    await _store.save(_vault);
    setState(() {
      _message = existing == null ? t.savedToKeyhold : t.passwordUpdated;
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
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchAllLogins,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    _search.text.isNotEmpty
                        ? t.nothingFound
                        : _site.isNotEmpty
                            ? t.noLoginForSite
                            : t.noLoginForApp,
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  children: [
                    for (final e in shown)
                      ListTile(
                        leading: SiteAvatar(entry: e, icons: _store.icons),
                        title: Text(e.title.isEmpty ? t.noTitle : e.title),
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
