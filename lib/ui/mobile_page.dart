import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/backup.dart';
import '../core/drive.dart';
import '../core/favicons.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../core/totp.dart';
import '../l10n/l10n.dart';
import 'backup_page.dart';
import 'copy_page.dart';
import 'entry_page.dart';
import 'import_page.dart';
import 'owner.dart';
import 'password_page.dart';
import 'qr_page.dart';
import 'start_page.dart';
import 'sync_page.dart';
import 'vault_info_page.dart';
import 'vault_page.dart' show SiteAvatar;

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

  /// The code after the current one, shown in its last seconds.
  final _next = <String, String>{};

  Vault _vault = Vault();
  bool _loading = true;
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
    // While Keyhold starts (unlock, start or new-password screens) there is
    // nothing to hide yet, and those screens must not be closed.
    if (!_store.backup.fingerprintLock || _locked || _loading) return;
    // Nothing stays open behind the lock: details, edits and sheets close.
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _locked = true);
  }

  Future<void> _unlock() async {
    if (_unlocking) return;
    _unlocking = true;
    final ok = await confirmOwner(context, _store);
    _unlocking = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  Future<void> _resume() async {
    // The autofill screen may have saved a login to the vault file meanwhile.
    if (!_loading && _store.isOpen) {
      _vault = Vault.merge(_vault, await _store.load());
      _codeWindow = -1;
      await _refreshCodes();
    }
    await _sync();
  }

  Future<void> _boot() async {
    final state = await _store.init();
    if (state == VaultState.locked && mounted) {
      await Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (_) => PasswordPage(store: _store, mode: PasswordMode.unlock, drive: _drive),
      ));
    }
    if (!await _ensureVault()) return;
    // The fingerprint panel comes up only from the Unlock button.
    _locked = _store.backup.fingerprintLock;
    unawaited(_lockChannel.invokeMethod('secure', _locked));
    await _loadVault();
    await _refreshCodes();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refreshCodes());
    unawaited(_sync());
  }

  /// Like on the computer: a new or an existing vault on an empty phone, and
  /// a master password for a vault from before one was required.
  Future<bool> _ensureVault() async {
    if (!_store.isOpen && mounted) {
      await Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (_) => StartPage(store: _store, drive: _drive),
      ));
    }
    if (_store.isOpen && !_store.hasPassword && mounted) {
      await Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (_) => PasswordPage(store: _store, mode: PasswordMode.seal),
      ));
    }
    return mounted && _store.isOpen;
  }

  Future<void> _loadVault() async {
    _vault = await _store.load();
    if (_vault.splitCodes()) await _store.save(_vault);
    _store.icons.fetchAll(_vault.visible);
    _codes.clear();
    _next.clear();
    _codeWindow = -1;
    setState(() => _loading = false);
  }

  /// Another vault took this one's place, or it was deleted.
  Future<void> _reopen() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Nothing of the vault that left stays on show or reaches the browser.
    setState(() {
      _vault = Vault();
      _loading = true;
    });
    if (!await _ensureVault()) return;
    await _loadVault();
    await _refreshCodes();
    unawaited(_sync());
  }

  Future<void> _refreshCodes() async {
    final window = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    if (window != _codeWindow) {
      _codeWindow = window;
      final next = DateTime.now().add(const Duration(seconds: 30));
      for (final e in _vault.visible) {
        final secret = e.totpSecret;
        if (secret == null || secret.isEmpty) continue;
        _codes[e.id] = await totpCode(secret);
        _next[e.id] = await totpCode(secret, at: next);
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
  Future<SyncResult?> _sync() async {
    if (!_drive.connected || !_store.isOpen) return null;
    if (_syncing) {
      _syncAgain = true;
      return null;
    }
    setState(() => _syncing = true);
    try {
      final result = await _drive.sync(_vault);
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
    if (choice == 'code') await _edit(VaultEntry(id: newId()), isNew: true, code: true);
    if (choice == 'new') await _edit(VaultEntry(id: newId()), isNew: true);
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
          _vault.put(VaultEntry(id: newId(), title: name, totpSecret: code.secret));
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
        onGuard: () async {
          if (!await toggleGuard(context, _store, entry)) return;
          _vault.put(entry);
          await _persist();
          if (mounted) setState(() {});
        },
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
      builder: (_) => _Settings(
        store: _store,
        drive: _drive,
        vault: _vault,
        onSync: _sync,
        onRename: (name) async {
          _vault.rename(name);
          await _persist();
        },
        onImport: (picked) async {
          for (final e in picked) {
            _vault.put(e);
          }
          _vault.splitCodes();
          await _persist();
          _toast(t.addedCount(picked.length));
        },
        beforeClose: () async {
          _syncSoon?.cancel();
          // A sync already running finishes first, then one last one.
          while (_syncing) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
          await _sync();
        },
        onSwitched: _reopen,
      ),
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
        title: Text(_vault.name.isEmpty ? 'Keyhold' : _vault.name),
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
                      // Room under the last entry, so it can come out from under the + button.
                      padding: const EdgeInsets.only(bottom: 88),
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
    final next = _left <= 10 ? _next[e.id] ?? _next[e.twoFactor] : null;
    final pinnedTo = e.isCode ? {for (final s in _vault.sitesOf(e)) hostOf(s)}.where((h) => h.isNotEmpty).join(', ') : '';
    final warn = _left <= 5 ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      onTap: () => code != null ? _copy(t.code, code) : _details(e),
      onLongPress: () => _details(e),
      // Tall enough for the countdown hanging under the code.
      minTileHeight: code == null ? null : 64,
      leading: GuardedAvatar(
        avatar: SiteAvatar(
          entry: e,
          icons: _store.icons,
          address: e.isCode ? (_vault.sitesOf(e).firstOrNull ?? '') : null,
        ),
        on: e.guarded, onTap: () async {
        if (!await toggleGuard(context, _store, e)) return;
        _vault.put(e);
        await _persist();
        if (mounted) setState(() {});
      },
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
          // The code on the name's line; the countdown and the next code hang
          // under it, so neither moves anything.
          : Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerRight,
              children: [
                Text(
                  '${code.substring(0, 3)} ${code.substring(3)}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 22, letterSpacing: 1, color: warn),
                ),
                Positioned(
                  right: 0,
                  bottom: -13,
                  // The next code sits in the room the shrinking bar leaves,
                  // high enough to stay clear of the line under the row.
                  child: SizedBox(
                    width: 100,
                    height: 18,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 100 * _left / 30,
                            height: 2,
                            color: warn ?? Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (next != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${next.substring(0, 3)} ${next.substring(3)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
    required this.onGuard,
  });

  final VaultEntry entry;
  final String? Function() code;
  final int Function() left;
  final void Function(String label, String value) onCopy;
  /// True when the entry was deleted.
  final Future<bool> Function() onEdit;

  /// The fingerprint mark on or off, as by the list's small fingerprint.
  final Future<void> Function() onGuard;

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

  Widget _field(String label, String value, {bool secret = false, String? copy}) {
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
            onPressed: () => widget.onCopy(label, copy ?? value),
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
            _field(t.codeSeconds(widget.left()), '${code.substring(0, 3)} ${code.substring(3)}', copy: code),
          _field(t.username, e.username),
          _field(t.password, e.password, secret: true),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            value: e.guarded,
            title: Text(t.guardedSwitch),
            subtitle: Text(t.guardedSwitchHint),
            onChanged: (_) async {
              await widget.onGuard();
              if (mounted) setState(() {});
            },
          ),
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
    required this.vault,
    required this.onSync,
    required this.onRename,
    required this.onImport,
    required this.beforeClose,
    required this.onSwitched,
  });

  final VaultStore store;
  final DriveSync drive;
  final Vault vault;
  final Future<SyncResult?> Function() onSync;
  final Future<void> Function(String name) onRename;
  final Future<void> Function(List<VaultEntry> picked) onImport;
  final Future<void> Function() beforeClose;
  final Future<void> Function() onSwitched;

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> with WidgetsBindingObserver {
  static const _autofill = MethodChannel('keyhold/autofill-settings');

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

  String _copiesState(BuildContext context) {
    final backup = widget.store.backup;
    if (backup.targets.isEmpty && !backup.remote.configured) return t.off;
    // As on the computer: a failed copy says so, not the time of an older one.
    final places = [...backup.targets, if (backup.remote.configured) backup.remote.host];
    final failed = places.where((p) => backup.status.errors.any((e) => e.startsWith('$p:'))).firstOrNull;
    if (failed != null) return t.backupFailed(PhoneFolderPlace.owns(failed) ? PhoneFolderPlace.label(failed) : failed);
    final at = backup.status.at;
    return at == null ? t.noBackupYet : t.lastBackup(TimeOfDay.fromDateTime(at).format(context));
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
          Text(t.vaultTab, style: theme.textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.key_outlined),
            title: Text(widget.vault.name.isEmpty ? t.myVault : widget.vault.name),
            subtitle: Text(t.itemCount(widget.vault.visible.length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => VaultInfoPage(
                  store: widget.store,
                  drive: drive,
                  vault: widget.vault,
                  onRename: widget.onRename,
                  beforeClose: widget.beforeClose,
                  onSwitched: widget.onSwitched,
                ),
              ));
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.download_outlined),
            title: Text(t.importTitle),
            subtitle: Text(t.importMenuHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await Navigator.of(context).push(MaterialPageRoute<List<VaultEntry>>(
                builder: (_) => ImportPage(store: widget.store, vault: widget.vault),
              ));
              if (picked != null && picked.isNotEmpty) await widget.onImport(picked);
              if (mounted) setState(() {});
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: widget.store.backup.fingerprintLock,
            title: Text(t.fingerprintSwitch),
            subtitle: Text(t.fingerprintSwitchHint),
            onChanged: (on) async {
              // Turning it on or off both need the owner's finger.
              if (!await confirmOwner(context, widget.store, hint: t.fingerprintConfirmHint)) return;
              widget.store.backup
                ..fingerprintLock = on
                ..saveSettings();
              await const MethodChannel('keyhold/lock').invokeMethod('secure', on);
              if (mounted) setState(() {});
            },
          ),
          const Divider(height: 40),
          Text(t.copiesTab, style: theme.textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(t.copiesPlaces),
            subtitle: Text(_copiesState(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => BackupPage(
                  store: widget.store,
                  onOpenCopy: (bytes, name) async {
                    final picked = await reviewCopy(context, widget.store, widget.vault, bytes, name);
                    if (picked != null && picked.isNotEmpty) await widget.onImport(picked);
                  },
                ),
              ));
              if (mounted) setState(() {});
            },
          ),
          const Divider(height: 40),
          Text(t.syncTab, style: theme.textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(drive.lastError != null ? Icons.sync_problem : Icons.add_to_drive),
            title: const Text('Google Drive'),
            subtitle: Text(
              drive.lastError ??
                  (!drive.connected
                      ? t.driveOnlyPhone
                      : synced == null
                          ? t.connectedAs(drive.email)
                          : t.connectedAsSynced(drive.email, TimeOfDay.fromDateTime(synced).format(context))),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => SyncPage(drive: drive, onSync: widget.onSync),
              ));
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.privacyPolicy),
            trailing: const Icon(Icons.open_in_new),
            onTap: openPrivacyPolicy,
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
