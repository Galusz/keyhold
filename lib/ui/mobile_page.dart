import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/drive.dart';
import '../core/favicons.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../core/totp.dart';
import '../l10n/l10n.dart';
import 'entry_page.dart';
import 'password_page.dart';
import 'qr_page.dart';
import 'vault_page.dart' show SiteAvatar;

/// A fingerprint, or the phone's own PIN or pattern when that fails.
Future<bool> askFingerprint([String? hint]) async {
  try {
    return await const MethodChannel('keyhold/fingerprint')
            .invokeMethod<bool>('ask', {'title': t.fingerprintTitle, 'hint': hint ?? t.fingerprintUnlockHint}) ??
        false;
  } catch (_) {
    return false;
  }
}

/// Keyhold on a phone: mostly an authenticator, with the same vault as the
/// computer kept in step through the user's Google Drive.
class MobilePage extends StatefulWidget {
  const MobilePage({super.key});

  @override
  State<MobilePage> createState() => _MobilePageState();
}

class _MobilePageState extends State<MobilePage> with WidgetsBindingObserver {
  final _store = VaultStore();
  late final _drive = DriveSync(_store);
  final _search = TextEditingController();
  final _codes = <String, String>{};

  Vault _vault = Vault();
  bool _loading = true;
  bool _welcome = false;
  bool _codesOnly = true;
  int _codeWindow = -1;
  int _left = 30;
  Timer? _ticker;
  Timer? _syncSoon;
  bool _syncing = false;
  bool _syncAgain = false;

  /// Fingerprint lock: shown over everything until unlocked; set again when
  /// the screen goes dark or the app was left for more than a minute.
  bool _locked = false;
  bool _unlocking = false;
  DateTime? _leftAt;
  static const _lockChannel = MethodChannel('keyhold/lock');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockChannel.setMethodCallHandler((call) async {
      if (call.method == 'screenOff') _lock();
    });
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _syncSoon?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The fingerprint panel covering Keyhold is not leaving it.
    if (_unlocking) return;
    if (state == AppLifecycleState.paused) _leftAt = DateTime.now();
    if (state != AppLifecycleState.resumed) return;
    final left = _leftAt;
    _leftAt = null;
    if (left != null && DateTime.now().difference(left) > const Duration(minutes: 1)) _lock();
    unawaited(_resume());
  }

  void _lock() {
    if (!_store.backup.fingerprintLock || _locked) return;
    setState(() => _locked = true);
  }

  Future<void> _unlock() async {
    if (_unlocking) return;
    _unlocking = true;
    final ok = await askFingerprint();
    _unlocking = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  Future<void> _resume() async {
    // The autofill screen may have saved a login to the vault file meanwhile.
    if (!_loading) {
      _vault = Vault.merge(_vault, await _store.load());
      _codeWindow = -1;
      await _refreshCodes();
    }
    await _sync();
  }

  Future<void> _boot() async {
    final ready = await _store.init();
    if (!ready && mounted) {
      await Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (_) => PasswordPage(store: _store, unlockMode: true),
      ));
    }
    _vault = await _store.load();
    if (_vault.splitCodes()) await _store.save(_vault);
    // The fingerprint panel comes up only from the Unlock button.
    _locked = _store.backup.fingerprintLock;
    _store.icons.fetchAll(_vault.visible);
    _welcome = _vault.visible.isEmpty && !_drive.connected;
    setState(() => _loading = false);
    await _refreshCodes();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refreshCodes());
    unawaited(_sync());
  }

  Future<void> _refreshCodes() async {
    final window = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    if (window != _codeWindow) {
      _codeWindow = window;
      for (final e in _vault.visible) {
        final secret = e.totpSecret;
        if (secret == null || secret.isEmpty) continue;
        _codes[e.id] = await totpCode(secret);
      }
    }
    if (mounted) setState(() => _left = secondsLeft());
  }

  Future<void> _persist() async {
    _codeWindow = -1;
    await _store.save(_vault);
    await _refreshCodes();
    _syncSoon?.cancel();
    _syncSoon = Timer(const Duration(seconds: 3), _sync);
  }

  /// Same merge as on the computer: edits made while it runs are kept.
  Future<SyncResult?> _sync({String? password}) async {
    if (!_drive.connected) return null;
    if (_syncing) {
      _syncAgain = true;
      return null;
    }
    setState(() => _syncing = true);
    try {
      final result = await _drive.sync(_vault, password: password);
      final theirs = result.vault;
      if (theirs != null) {
        _vault = Vault.merge(_vault, theirs);
        // Another device may still keep codes inside logins.
        _vault.splitCodes();
        await _store.save(_vault);
        _codeWindow = -1;
        await _refreshCodes();
      }
      return result;
    } on DriveError {
      return null;
    } finally {
      if (mounted) setState(() => _syncing = false);
      if (_syncAgain) {
        _syncAgain = false;
        unawaited(_sync());
      }
    }
  }

  // ---------- Google Drive ----------

  Future<void> _connect() async {
    try {
      await _drive.connect();
    } catch (e) {
      _toast(t.driveNotConnected('$e'));
      return;
    }
    var result = await _sync();
    if (result != null && result.needsPassword) {
      final password = await _askPassword();
      if (password == null) return;
      result = await _sync(password: password);
    }
    if (_drive.lastError != null) {
      _toast(_drive.lastError!);
      return;
    }
    setState(() => _welcome = false);
  }

  Future<String?> _askPassword() {
    final field = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.masterPassword),
        content: TextField(
          controller: field,
          obscureText: true,
          decoration: InputDecoration(
            labelText: t.masterPasswordOfVault,
            helperText: t.masterPasswordFromComputer,
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, field.text), child: Text(t.open)),
        ],
      ),
    ).whenComplete(field.dispose);
  }

  // ---------- actions ----------

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 3)));
  }

  void _copy(String label, String value) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    _toast(t.copied(label));
  }

  Future<void> _add() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(t.scanQr),
              subtitle: Text(t.scanQrHint),
              onTap: () => Navigator.pop(context, 'qr'),
            ),
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: Text(t.newCode),
              subtitle: Text(t.newCodeHint),
              onTap: () => Navigator.pop(context, 'code'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(t.newLogin),
              onTap: () => Navigator.pop(context, 'new'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'qr') await _scanQr();
    if (choice == 'code') await _edit(VaultEntry(id: UniqueKey().toString()), isNew: true, code: true);
    if (choice == 'new') await _edit(VaultEntry(id: UniqueKey().toString()), isNew: true);
  }

  Future<void> _scanQr() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => QrPage(
        known: {
          for (final e in _vault.visible)
            if ((e.totpSecret ?? '').isNotEmpty) e.totpSecret!: e.title,
        },
        onSave: (code) async {
          // Named like in Google Authenticator: the service and the account.
          final name = code.issuer.isEmpty
              ? code.account
              : code.account.isEmpty
                  ? code.issuer
                  : '${code.issuer} (${code.account})';
          _vault.put(VaultEntry(id: UniqueKey().toString(), title: name, totpSecret: code.secret));
          await _persist();
          return name;
        },
      ),
    ));
    if (mounted) setState(() {});
  }


  /// True when the entry was deleted.
  Future<bool> _edit(VaultEntry entry, {required bool isNew, bool code = false}) async {
    final result = await Navigator.of(context).push(MaterialPageRoute<Object?>(
      builder: (_) => EntryPage(entry: entry, isNew: isNew, vault: _vault, code: code),
    ));
    if (result == 'delete') {
      _vault.remove(entry.id);
      await _persist();
      return true;
    }
    if (result == true) {
      _vault.put(entry);
      await _persist();
    }
    return false;
  }

  Future<void> _details(VaultEntry entry) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _Details(
        entry: entry,
        code: () => _codes[entry.id],
        left: () => _left,
        onCopy: _copy,
        onEdit: () => _edit(entry, isNew: false),
      ),
    ));
    setState(() {});
  }

  Future<void> _duplicates() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _Duplicates(
        vault: _vault,
        icons: _store.icons,
        onDelete: (e) async {
          _vault.remove(e.id);
          await _persist();
        },
      ),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _settings() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _Settings(store: _store, drive: _drive, onConnect: _connect, onSync: _sync),
    ));
    setState(() {});
  }

  // ---------- screens ----------

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              Text(t.locked, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _unlock,
                icon: const Icon(Icons.fingerprint),
                label: Text(t.unlock),
              ),
            ],
          ),
        ),
      );
    }
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_welcome) return _welcomeScreen();

    final q = _search.text.trim().toLowerCase();
    final items = _vault.visible.where((e) {
      final hasCode = e.totpSecret != null && e.totpSecret!.isNotEmpty;
      if (_codesOnly && !hasCode) return false;
      return q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.username.toLowerCase().contains(q) ||
          e.url.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyhold'),
        actions: [
          if (_syncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          if (_vault.duplicates.isNotEmpty)
            IconButton(
              tooltip: t.duplicates,
              icon: Badge(
                label: Text('${_vault.duplicates.fold<int>(0, (n, g) => n + g.length)}'),
                child: const Icon(Icons.content_copy_outlined),
              ),
              onPressed: _duplicates,
            ),
          IconButton(
            tooltip: t.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: _settings,
          ),
        ],
      ),
      bottomNavigationBar: _backupBar(),
      floatingActionButton: FloatingActionButton(
        tooltip: t.add,
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.search,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(t.codes), icon: const Icon(Icons.pin_outlined)),
                ButtonSegment(value: false, label: Text(t.everything), icon: const Icon(Icons.key_outlined)),
              ],
              selected: {_codesOnly},
              onSelectionChanged: (s) => setState(() => _codesOnly = s.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _sync(),
              child: items.isEmpty
                  ? ListView(children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(_codesOnly ? t.noCodesYet : t.nothingYet),
                      ),
                    ])
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _row(items[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _ago(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return t.justNow;
    if (diff.inMinutes < 60) return t.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return t.hoursAgo(diff.inHours);
    return t.daysAgo(diff.inDays);
  }

  /// Always on screen: losing the phone must never mean losing the codes.
  Widget _backupBar() {
    final theme = Theme.of(context);
    final synced = _drive.syncedAt;
    final (IconData icon, Color color, String text) = switch (_drive) {
      _ when !_drive.connected => (
          Icons.cloud_off_outlined,
          theme.colorScheme.error,
          t.notBackedUp,
        ),
      _ when _syncing => (Icons.cloud_sync_outlined, theme.hintColor, t.backingUp),
      _ when _drive.lastError != null => (
          Icons.sync_problem,
          theme.colorScheme.error,
          t.backupFailed(_drive.lastError!),
        ),
      _ when synced == null => (Icons.cloud_upload_outlined, theme.hintColor, t.waitingFirstBackup),
      _ => (Icons.cloud_done_outlined, theme.colorScheme.primary, t.backedUpToDrive(_ago(synced))),
    };

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: InkWell(
        onTap: _settings,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 10),
                Expanded(child: Text(text, style: TextStyle(color: color))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(VaultEntry e) {
    final code = _codes[e.id] ?? _codes[e.twoFactor];
    final pinnedTo = e.isCode ? {for (final s in _vault.sitesOf(e)) hostOf(s)}.where((h) => h.isNotEmpty).join(', ') : '';
    final warn = _left <= 5 ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      onTap: () => code != null ? _copy(t.code, code) : _details(e),
      onLongPress: () => _details(e),
      leading: SiteAvatar(
        entry: e,
        icons: _store.icons,
        address: e.isCode ? (_vault.sitesOf(e).firstOrNull ?? '') : null,
      ),
      title: Text(
        e.title.isEmpty ? t.noTitle : e.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: e.isCode
          ? (pinnedTo.isEmpty ? null : Text('📌 $pinnedTo', maxLines: 1, overflow: TextOverflow.ellipsis))
          : Text(
              e.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: code == null
          ? const Icon(Icons.chevron_right)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${code.substring(0, 3)} ${code.substring(3)}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 22, letterSpacing: 1, color: warn),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 90,
                  child: LinearProgressIndicator(value: _left / 30, minHeight: 2, color: warn),
                ),
              ],
            ),
    );
  }

  Widget _welcomeScreen() {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text('Keyhold', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                t.phoneWelcome,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.add_to_drive),
                label: Text(t.connectDrive),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _welcome = false),
                child: Text(t.startEmpty),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatefulWidget {
  const _Details({
    required this.entry,
    required this.code,
    required this.left,
    required this.onCopy,
    required this.onEdit,
  });

  final VaultEntry entry;
  final String? Function() code;
  final int Function() left;
  final void Function(String label, String value) onCopy;
  /// True when the entry was deleted.
  final Future<bool> Function() onEdit;

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  bool _showPassword = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Widget _field(String label, String value, {bool secret = false}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        secret && !_showPassword ? '••••••••••' : value,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secret)
            IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          IconButton(
            tooltip: t.copy,
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => widget.onCopy(label, value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final code = widget.code();
    return Scaffold(
      appBar: AppBar(
        title: Text(e.title.isEmpty ? t.noTitle : e.title),
        actions: [
          IconButton(
            tooltip: t.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final deleted = await widget.onEdit();
              if (!context.mounted) return;
              // A deleted entry has nothing left to show: back to the list.
              if (deleted) {
                Navigator.of(context).pop();
              } else {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (code != null)
            _field(t.codeSeconds(widget.left()), '${code.substring(0, 3)} ${code.substring(3)}'),
          _field(t.username, e.username),
          _field(t.password, e.password, secret: true),
          _field(t.address, e.url),
          _field(t.notes, e.notes),
        ],
      ),
    );
  }
}

class _Settings extends StatefulWidget {
  const _Settings({
    required this.store,
    required this.drive,
    required this.onConnect,
    required this.onSync,
  });

  final VaultStore store;
  final DriveSync drive;
  final Future<void> Function() onConnect;
  final Future<SyncResult?> Function() onSync;

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> with WidgetsBindingObserver {
  static const _autofill = MethodChannel('keyhold/autofill-settings');

  bool _busy = false;

  /// "on", "off" or "unsupported" — whether Keyhold is the phone's password filler.
  String _filler = 'unsupported';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkFiller();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from the system screen where the filler is chosen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkFiller();
  }

  Future<void> _checkFiller() async {
    final state = await _autofill.invokeMethod<String>('state') ?? 'unsupported';
    if (mounted) setState(() => _filler = state);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drive = widget.drive;
    final synced = drive.syncedAt;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Google Drive', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            !drive.connected
                ? t.driveOnlyPhone
                : synced == null
                    ? t.connectedAs(drive.email)
                    : t.connectedAsSynced(drive.email, TimeOfDay.fromDateTime(synced).format(context)),
            style: theme.textTheme.bodyMedium,
          ),
          if (drive.lastError != null) ...[
            const SizedBox(height: 4),
            Text(drive.lastError!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              if (!drive.connected)
                FilledButton.icon(
                  onPressed: _busy ? null : () => _run(widget.onConnect),
                  icon: const Icon(Icons.add_to_drive),
                  label: Text(t.connect),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _run(() async => widget.onSync()),
                  icon: const Icon(Icons.sync),
                  label: Text(t.syncNow),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _run(drive.disconnect),
                  child: Text(t.disconnect),
                ),
              ],
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
          const Divider(height: 40),
          Text(t.fingerprintLock, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: widget.store.backup.fingerprintLock,
            title: Text(t.fingerprintSwitch),
            subtitle: Text(t.fingerprintSwitchHint),
            onChanged: (on) async {
              // Turning it on or off both need the owner's finger.
              if (!await askFingerprint(t.fingerprintConfirmHint)) return;
              widget.store.backup
                ..fingerprintLock = on
                ..saveSettings();
              if (mounted) setState(() {});
            },
          ),
          if (_filler != 'unsupported') ...[
            const Divider(height: 40),
            Text(t.fillingPasswords, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              _filler == 'on' ? t.fillerOn : t.fillerOff,
              style: theme.textTheme.bodyMedium,
            ),
            if (_filler != 'on') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () => _autofill.invokeMethod('enable'),
                  icon: const Icon(Icons.password),
                  label: Text(t.fillWithKeyhold),
                ),
              ),
            ],
          ],
          const Divider(height: 40),
          Text(t.masterPassword, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            widget.store.hasPassword ? t.passwordSetPhone : t.passwordNotSetPhone,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () async {
                final changed = await Navigator.of(context).push(MaterialPageRoute<bool>(
                  builder: (_) => PasswordPage(store: widget.store, unlockMode: false),
                ));
                // Sends the new password to the other devices right away.
                if (changed == true) await widget.onSync();
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.lock_outline),
              label: Text(widget.store.hasPassword ? t.change : t.setMasterPassword),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logins kept more than once, side by side, so the extra ones can go.
class _Duplicates extends StatefulWidget {
  const _Duplicates({required this.vault, required this.icons, required this.onDelete});

  final Vault vault;
  final Favicons icons;
  final Future<void> Function(VaultEntry e) onDelete;

  @override
  State<_Duplicates> createState() => _DuplicatesState();
}

class _DuplicatesState extends State<_Duplicates> {
  Future<void> _delete(VaultEntry e, String note) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(e.title.isEmpty ? t.deleteThisLogin : t.deleteNamed(e.title)),
        content: Text(note),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.delete)),
        ],
      ),
    );
    if (sure != true) return;
    await widget.onDelete(e);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.vault.duplicates;
    final notes = Vault.duplicateNotes(groups);
    return Scaffold(
      appBar: AppBar(title: Text(t.duplicates)),
      body: groups.isEmpty
          ? Center(child: Text(t.noDuplicatesLeft))
          : ListView(
              children: [
                for (final group in groups) ...[
                  for (final e in group)
                    ListTile(
                      leading: SiteAvatar(entry: e, icons: widget.icons),
                      title: Text(e.title.isEmpty ? t.noTitle : e.title),
                      subtitle: Text(notes[e.id] ?? ''),
                      trailing: IconButton(
                        tooltip: t.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(e, notes[e.id] ?? ''),
                      ),
                    ),
                  const Divider(),
                ],
              ],
            ),
    );
  }
}
