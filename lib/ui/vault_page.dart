import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../core/models.dart';
import '../core/autotype.dart';
import '../core/bridge.dart';
import '../core/drive.dart';
import '../core/favicons.dart';
import '../core/storage.dart';
import '../core/totp.dart';
import '../core/watch.dart';
import '../l10n/l10n.dart';
import 'entry_page.dart';
import 'extension_page.dart';
import 'import_page.dart';
import 'password_page.dart';
import 'qr_page.dart';
import 'recovery_page.dart';
import 'backup_page.dart';
import 'copy_page.dart';
import 'start_page.dart';
import 'sync_page.dart';
import 'vault_info_page.dart';

enum EntryFilter { all, twoFactor, plain, files, duplicates }

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _store = VaultStore();
  final _search = TextEditingController();
  final _codes = <String, String>{};

  Vault _vault = Vault();
  Timer? _ticker;
  bool _loading = true;
  EntryFilter _filter = EntryFilter.all;
  String? _group;

  /// Under "Duplicates": which one is newest and how the others differ.
  Map<String, String> _duplicateNotes = const {};
  final _selected = <String>{};
  BrowserBridge? _bridge;
  Timer? _watchTimer;
  late final _drive = DriveSync(_store);
  Timer? _driveTimer;
  Timer? _driveSoon;
  bool _driveBusy = false;
  bool _driveAgain = false;
  WatchResult? _lastScan;
  DateTime? _lastScanAt;
  bool _scanning = false;
  int _left = 30;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _watchTimer?.cancel();
    _driveTimer?.cancel();
    _driveSoon?.cancel();
    _bridge?.stop();
    _search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    clearRecoverySheet();
    final state = await _store.init();
    if (state == VaultState.locked && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => PasswordPage(store: _store, mode: PasswordMode.unlock),
        ),
      );
    }
    if (!await _ensureVault()) return;
    await _loadVault();
    await _startBridge();
    await _startWatching();
    unawaited(_syncDrive());
    _driveTimer = Timer.periodic(const Duration(minutes: 5), (_) => _syncDrive());
    await _refreshCodes();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refreshCodes());
  }

  /// A vault to work with: an empty device starts with a new vault or one it
  /// already has somewhere, and a vault from before master passwords were
  /// required gets one now.
  Future<bool> _ensureVault() async {
    if (!_store.isOpen && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => StartPage(store: _store, drive: _drive)),
      );
    }
    if (_store.isOpen && !_store.hasPassword && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => PasswordPage(store: _store, mode: PasswordMode.seal)),
      );
    }
    return mounted && _store.isOpen;
  }

  Future<void> _loadVault() async {
    _vault = await _store.load();
    final grouped = _autoGroup();
    if (_vault.splitCodes() || grouped) await _store.save(_vault);
    _store.icons.fetchAll(_vault.visible);
    _codes.clear();
    _codeWindow = -1;
    _revision++;
    _selected.clear();
    _group = null;
    setState(() => _loading = false);
  }

  /// Another vault took this one's place, or it was deleted.
  Future<void> _reopen() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Nothing of the vault that left stays on show or reaches the browser.
    setState(() {
      _vault = Vault();
      _loading = true;
      _search.clear();
      _filter = EntryFilter.all;
      _lastScan = null;
    });
    if (!await _ensureVault()) return;
    await _loadVault();
    await _refreshCodes();
    unawaited(_syncDrive());
  }

  /// How a login caught in the browser relates to what the vault holds.
  String _loginState(String url, String username, String password) {
    final existing = _findLogin(_vault.visible, url, '', username);
    if (existing == null) return 'new';
    return existing.password == password ? 'same' : 'changed';
  }

  /// Writes a login the user confirmed in the browser.
  Future<String> _storeLogin(String url, String username, String password) async {
    final existing = _findLogin(_vault.visible, url, '', username);
    if (existing != null) {
      existing.password = password;
      _vault.put(existing);
      await _persist();
      return 'updated';
    }
    _vault.put(VaultEntry(
      id: newId(),
      title: hostOf(url),
      username: username,
      password: password,
      url: url,
      group: _vault.defaultGroup('Web', t.groupWeb),
    ));
    await _persist();
    return 'saved';
  }

  /// The same login already in the vault: same site (or same title when there
  /// is no address) and the same username.
  VaultEntry? _findLogin(
      List<VaultEntry> entries, String url, String title, String username) {
    final host = hostOf(url);
    final name = title.trim().toLowerCase();
    for (final e in entries) {
      if (e.username != username) continue;
      if (host.isNotEmpty ? hostOf(e.url) == host : e.title.toLowerCase() == name) {
        return e;
      }
    }
    return null;
  }

  static final _ipPattern = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

  bool _isLocal(String host) =>
      host == 'localhost' ||
      host.endsWith('.local') ||
      host.endsWith('.lan') ||
      host.startsWith('192.168.') ||
      host.startsWith('10.') ||
      host.startsWith('127.') ||
      RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(host);

  /// A vault without any groups gets a first split: home devices, servers
  /// reached by address, and websites.
  bool _autoGroup() {
    final entries = _vault.visible;
    if (entries.isEmpty || entries.any((e) => e.group.isNotEmpty)) return false;
    for (final e in entries) {
      final host = hostOf(e.url.isNotEmpty ? e.url : e.title);
      e.group = _isLocal(host)
          ? t.groupLocal
          : _ipPattern.hasMatch(host)
              ? t.groupServers
              : t.groupWeb;
      _vault.put(e);
    }
    return true;
  }

  String _extensionFolder() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return '$exeDir${Platform.pathSeparator}extension';
  }

  Future<void> _startBridge() async {
    if (!Platform.isWindows) return;
    final bridge = BrowserBridge(
      vault: () => _vault,
      token: _store.ensureBridgeToken(),
      loginState: _loginState,
      storeLogin: _storeLogin,
      neverSave: () => _store.backup.neverSave,
      autoSave: () => _store.backup.autoSave,
      iconOf: _store.icons.bytesOf,
    )
      ..onNever = (host, never) {
        final list = _store.backup.neverSave;
        list.remove(host);
        if (never) list.add(host);
        _store.backup.saveSettings();
      }
      ..onAutoSave = (on) {
        _store.backup.autoSave = on;
        _store.backup.saveSettings();
      }
      ..onPair = (id, pageUrl) async {
        final entry = _vault.entries[id];
        if (entry == null || entry.deleted) return;
        _vault.addSite(entry, pageUrl);
        await _persist();
        if (mounted) setState(() {});
      }
      ..onOpen = (id) async {
        final entry = _vault.entries[id];
        if (entry == null) return;
        if (await windowManager.isMinimized()) await windowManager.restore();
        await windowManager.show();
        await windowManager.focus();
        if (mounted) await _open(entry, isNew: false);
      };
    try {
      await bridge.start();
      _bridge = bridge;
    } catch (_) {
      // another instance already listens; the first one serves the extension
    }
  }

  Future<void> _import() async {
    await _take(await Navigator.of(context).push(
      MaterialPageRoute<List<VaultEntry>>(builder: (_) => ImportPage(store: _store, vault: _vault)),
    ));
  }

  /// Entries brought in from elsewhere, each a new entry of its own.
  Future<void> _take(List<VaultEntry>? picked) async {
    if (picked == null || picked.isEmpty) return;
    for (final e in picked) {
      _vault.put(e);
    }
    _vault.splitCodes();
    await _persist();
    if (mounted) {
      setState(() {});
      _toast(t.addedCount(picked.length));
    }
  }

  /// What is not needed day to day: the vault itself, sync, backups, import
  /// and the browser extension.
  Widget _menu() {
    final theme = Theme.of(context);
    final syncedAt = _drive.syncedAt;
    PopupMenuItem<VoidCallback> item(IconData icon, String title, String? state, VoidCallback action) =>
        PopupMenuItem(
          value: action,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(title),
            subtitle: state == null ? null : Text(state, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        );
    return PopupMenuButton<VoidCallback>(
      tooltip: t.menu,
      constraints: const BoxConstraints(minWidth: 340, maxWidth: 400),
      onSelected: (action) => action(),
      itemBuilder: (_) => [
        item(Icons.key_outlined, t.vaultTab, _vault.name.isEmpty ? t.myVault : _vault.name, _openVaultInfo),
        item(
          _drive.lastError != null
              ? Icons.sync_problem
              : _drive.connected
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
          t.syncTab,
          !_drive.connected
              ? t.off
              : _drive.lastError ?? (syncedAt == null ? _drive.email : t.driveSynced(_ago(syncedAt))),
          _openSync,
        ),
        item(Icons.history, t.copiesTab, null, _openBackup),
        item(Icons.download_outlined, t.importTitle, t.importMenuHint, _import),
        item(Icons.extension_outlined, t.browserExtension, null, _openExtension),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(t.menu, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _openExtension() => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExtensionPage(
            token: _store.ensureBridgeToken(),
            running: _bridge?.running ?? false,
            extensionPath: _extensionFolder(),
          ),
        ),
      );

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


  int _codeWindow = -1;

  /// Codes only change once per 30 second window, so they are computed then —
  /// the timer itself just moves the countdown.
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
    _revision++;
    _codeWindow = -1;
    await _store.save(_vault);
    await _refreshCodes();
    _driveSoon?.cancel();
    _driveSoon = Timer(const Duration(seconds: 3), _syncDrive);
  }

  /// Pulls changes from other devices and pushes this one's. Edits made while
  /// a sync runs are kept: the result is merged into the vault as it is now.
  Future<SyncResult?> _syncDrive() async {
    if (!_drive.connected || !_store.isOpen) return null;
    if (_driveBusy) {
      _driveAgain = true;
      return null;
    }
    _driveBusy = true;
    try {
      final result = await _drive.sync(_vault);
      final theirs = result.vault;
      if (theirs != null) {
        _vault = Vault.merge(_vault, theirs);
        // Another device may still keep codes inside logins.
        _vault.splitCodes();
        _revision++;
        _codeWindow = -1;
        await _store.save(_vault);
        await _refreshCodes();
      }
      return result;
    } on DriveError {
      return null;
    } finally {
      _driveBusy = false;
      if (mounted) setState(() {});
      if (_driveAgain) {
        _driveAgain = false;
        unawaited(_syncDrive());
      }
    }
  }

  Future<void> _open(VaultEntry entry, {required bool isNew, bool code = false}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<Object?>(
        builder: (_) => EntryPage(entry: entry, isNew: isNew, vault: _vault, code: code),
      ),
    );
    if (result == 'delete') {
      _vault.remove(entry.id);
      await _persist();
      return;
    }
    if (result == true) {
      _vault.put(entry);
      await _persist();
    }
  }

  void _copy(String label, String value) {
    if (value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(t.copied(label)),
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _autoType(VaultEntry entry, {bool codeOnly = false}) async {
    final code = _codes[entry.id] ?? _codes[entry.twoFactor];
    if (codeOnly && (code == null || code.isEmpty)) return;

    await windowManager.hide();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (codeOnly) {
      await typeCode(code!);
    } else {
      await typeCredentials(entry.username, entry.password);
    }
  }

  bool _hasCode(VaultEntry e) =>
      e.totpSecret != null && e.totpSecret!.isNotEmpty;

  static final _hostPattern =
      RegExp(r'[a-z0-9][a-z0-9-]*(?:\.[a-z0-9-]+)+(?::\d+)?');

  /// Words worth matching a window title against: the site name and the entry title.
  Iterable<String> _keywordsOf(VaultEntry e) sync* {
    final host = hostOf(e.url);
    if (host.isNotEmpty) {
      final name = host.split('.').first;
      if (name.length >= 3) yield name;
    }
    final title = e.title.trim().toLowerCase();
    if (title.length >= 3) yield title;
  }

  // Both lists walk every entry, so they are rebuilt only when their inputs
  // change — not on every tick of the code timer.
  String _suggestedKey = '';
  List<VaultEntry> _suggestedCache = const [];

  String _filteredKey = '';
  List<VaultEntry> _filteredCache = const [];

  int _revision = 0;

  List<VaultEntry> get _suggested {
    final window = AutoTypeTarget.title.toLowerCase();
    final key = '$_revision|$window';
    if (key == _suggestedKey) return _suggestedCache;

    _suggestedKey = key;
    if (window.isEmpty) {
      _suggestedCache = const [];
      return _suggestedCache;
    }

    final entries = _vault.visible;

    // A window title usually carries the address itself ("… — ha.zkv.pl").
    // An exact host beats everything: ha.zkv.pl must not drag in zkv.pl.
    final hosts = _hostPattern
        .allMatches(window)
        .map((m) => m.group(0)!.split(':').first)
        .map((h) => h.startsWith('www.') ? h.substring(4) : h)
        .toSet();

    var hits = hosts.isEmpty
        ? <VaultEntry>[]
        : entries.where((e) => hosts.contains(hostOf(e.url))).toList();

    // Nothing addressed directly — fall back to the site name and the title.
    if (hits.isEmpty) {
      hits = entries.where((e) => _keywordsOf(e).any(window.contains)).toList();
    }

    hits.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    _suggestedCache = hits;
    return hits;
  }

  List<VaultEntry> get _filtered {
    final q = _search.text.trim().toLowerCase();
    final key = '$_revision|${_filter.name}|$_group|$q';
    if (key == _filteredKey) return _filteredCache;

    _filteredKey = key;
    var all = _vault.visible;

    _duplicateNotes = const {};
    if (_filter == EntryFilter.duplicates) {
      final groups = _vault.duplicates;
      _duplicateNotes = Vault.duplicateNotes(groups);
      all = [for (final group in groups) ...group];
    }

    all = switch (_filter) {
      EntryFilter.twoFactor => all.where(_hasCode).toList(),
      EntryFilter.plain => all.where((e) => !_hasCode(e)).toList(),
      EntryFilter.all || EntryFilter.files || EntryFilter.duplicates => all,
    };

    final group = _group;
    if (group != null) all = all.where((e) => e.group == group).toList();

    if (q.isNotEmpty) {
      all = all
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.username.toLowerCase().contains(q) ||
              e.url.toLowerCase().contains(q))
          .toList();
    }

    _filteredCache = all;
    return all;
  }

  Widget _sidebar() {
    final theme = Theme.of(context);
    final visible = _vault.visible;
    final withCode = visible.where(_hasCode).length;
    final counts = <String, int>{};
    for (final e in visible) {
      counts[e.group] = (counts[e.group] ?? 0) + 1;
    }
    final groups = _vault.groups;
    final duplicates = _vault.duplicates.fold<int>(0, (n, g) => n + g.length);

    Widget item(IconData icon, String label, int count, bool selected,
            VoidCallback onTap) =>
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          selected: selected,
          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(icon, size: 20),
          title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text('$count', style: theme.textTheme.bodySmall),
          onTap: onTap,
        );

    Widget filter(IconData icon, String label, int count, EntryFilter value) =>
        item(icon, label, count, _group == null && _filter == value,
            () => setState(() {
                  _filter = value;
                  _group = null;
                }));

    Widget group(IconData icon, String label, String name) =>
        item(icon, label, counts[name] ?? 0, _group == name,
            () => setState(() {
                  _filter = EntryFilter.all;
                  _group = name;
                }));

    return SizedBox(
      width: 220,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          filter(Icons.all_inbox_outlined, t.filterAll, visible.length, EntryFilter.all),
          filter(Icons.pin_outlined, t.filter2fa, withCode, EntryFilter.twoFactor),
          filter(Icons.key_outlined, t.filterPasswords, visible.length - withCode,
              EntryFilter.plain),
          filter(Icons.attach_file, t.filterFiles, _vault.visibleFiles.length,
              EntryFilter.files),
          if (duplicates > 0 || _filter == EntryFilter.duplicates)
            filter(Icons.content_copy_outlined, t.duplicates, duplicates, EntryFilter.duplicates),
          if (groups.isNotEmpty) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(t.groups,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ),
            for (final name in groups) group(Icons.folder_outlined, name, name),
            if ((counts[''] ?? 0) > 0) group(Icons.folder_off_outlined, t.noGroup, ''),
          ],
        ],
      ),
    );
  }

  void _toggle(VaultEntry e) {
    setState(() {
      if (!_selected.remove(e.id)) _selected.add(e.id);
    });
  }

  Future<void> _moveSelected() async {
    final target = await _askGroup();
    if (target == null) return;
    for (final id in _selected) {
      final e = _vault.entries[id];
      if (e == null) continue;
      e.group = target;
      _vault.put(e);
    }
    _selected.clear();
    await _persist();
  }

  Future<String?> _askGroup() async {
    final groups = _vault.groups;
    final name = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.moveCountToGroup(_selected.length)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groups.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in groups)
                      ActionChip(
                        avatar: const Icon(Icons.folder_outlined, size: 18),
                        label: Text(g),
                        onPressed: () => Navigator.pop(context, g),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: t.newGroup,
                  helperText: t.newGroupHint,
                ),
                onSubmitted: (v) => Navigator.pop(context, v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, name.text.trim()),
            child: Text(t.move),
          ),
        ],
      ),
    );
    name.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = _filtered;
    final selecting = _selected.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: selecting
            ? IconButton(
                tooltip: t.clearSelection,
                icon: const Icon(Icons.close),
                onPressed: () => setState(_selected.clear),
              )
            : null,
        title: Text(selecting
            ? t.selectedCount(_selected.length)
            : _vault.name.isEmpty
                ? 'Keyhold'
                : _vault.name),
        actions: selecting
            ? [
                FilledButton.icon(
                  onPressed: _moveSelected,
                  icon: const Icon(Icons.drive_file_move_outlined),
                  label: Text(t.moveToGroup),
                ),
                const SizedBox(width: 16),
              ]
            : [
          IconButton(
            tooltip: t.addCodesFromQr,
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQr,
          ),
          const SizedBox(width: 4),
          _menu(),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
        ),
      ),
      floatingActionButton: _filter == EntryFilter.files
          ? FloatingActionButton.extended(
              onPressed: _addFile,
              icon: const Icon(Icons.attach_file),
              label: Text(t.addFile),
            )
          : FloatingActionButton.extended(
              onPressed: () => _open(
                  VaultEntry(id: newId(), group: _group ?? ''),
                  isNew: true,
                  code: _filter == EntryFilter.twoFactor),
              icon: const Icon(Icons.add),
              label: Text(t.newEntry),
            ),
      bottomNavigationBar: _backupBar(items.length),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: _filter == EntryFilter.files ? _filesBody() : _body(items),
          ),
        ],
      ),
    );
  }

  List<String> get _watched => _store.backup.watched ?? const [];

  Future<void> _startWatching() async {
    await _scan();
    _watchTimer = Timer.periodic(const Duration(minutes: 15), (_) => _scan());
  }

  Future<void> _scan() async {
    if (_scanning) return;
    _scanning = true;
    // EXPIRES: when no Keyhold 1.1.0 or older is left — those could watch a single file.
    // Such a file is already in the vault; only folders are watched now.
    final folders = _watched
        .where((p) => !FileSystemEntity.isFileSync(p) && !_vault.files.values.any((f) => f.source == p))
        .toList();
    if (folders.length != _watched.length) {
      _store.backup.watched = folders;
      _store.backup.saveSettings();
    }
    try {
      final result = await scanWatched(_vault, _watched);
      if (result.changed) await _persist();
      if (mounted) {
        setState(() {
          _lastScan = result;
          _lastScanAt = DateTime.now();
        });
      }
    } finally {
      _scanning = false;
    }
  }

  Future<void> _watch() async {
    final path = await getDirectoryPath();
    if (path == null || _watched.contains(path)) return;
    _store.backup.watched = [..._watched, path];
    _store.backup.saveSettings();
    await _scan();
  }

  void _unwatch(String path) {
    _store.backup.watched = _watched.where((p) => p != path).toList();
    _store.backup.saveSettings();
    setState(() {});
  }

  Widget _watchedPanel() {
    final theme = Theme.of(context);
    final scan = _lastScan;
    final countFor = <String, int>{};
    for (final f in _vault.visibleFiles) {
      final src = f.source;
      if (src == null) continue;
      for (final root in _watched) {
        if (src.startsWith('$root${Platform.pathSeparator}')) {
          countFor[root] = (countFor[root] ?? 0) + 1;
        }
      }
    }

    String status;
    if (_scanning) {
      status = t.checking;
    } else if (scan == null) {
      status = t.notCheckedYet;
    } else {
      final when = _ago(_lastScanAt!);
      final parts = [
        if (scan.added > 0) t.filesNew(scan.added),
        if (scan.updated > 0) t.filesChanged(scan.updated),
        if (scan.skipped.isNotEmpty) t.filesSkipped(scan.skipped.length),
      ];
      status = parts.isEmpty ? t.checkedNothingChanged(when) : t.checkedWith(when, parts.join(', '));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.watchedHint,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          if (_watched.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(t.nothingWatched, style: theme.textTheme.bodyMedium),
            ),
          ..._watched.map((path) {
            return Row(
              children: [
                const Icon(Icons.folder_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$path  (${countFor[path] ?? 0})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: t.stopWatching,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close),
                  onPressed: () => _unwatch(path),
                ),
              ],
            );
          }),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _watch,
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                label: Text(t.watchFolder),
              ),
              TextButton.icon(
                onPressed: _scanning ? null : _scan,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(t.checkNow),
              ),
              Text(status, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  static const _maxFileBytes = 25 * 1024 * 1024;

  String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 3)));
  }

  Future<void> _addFile() async {
    final picked = await openFile();
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (bytes.length > _maxFileBytes) {
      _toast(t.fileTooBig(picked.name, _humanSize(bytes.length)));
      return;
    }

    _vault.putFile(VaultFile(
      id: newId(),
      name: picked.name,
      data: base64Encode(bytes),
      size: bytes.length,
    ));
    await _persist();
    _toast(t.fileAdded(picked.name));
  }

  Future<void> _saveFile(VaultFile f) async {
    final target = await getSaveLocation(suggestedName: f.name);
    if (target == null) return;
    await File(target.path).writeAsBytes(f.bytes, flush: true);
    _toast(t.savedTo(target.path));
  }

  Future<void> _deleteEntry(VaultEntry e) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(e.title.isEmpty ? t.deleteThisLogin : t.deleteNamed(e.title)),
        content: Text(_duplicateNotes[e.id] ?? e.username),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.delete)),
        ],
      ),
    );
    if (sure != true) return;
    _vault.remove(e.id);
    await _persist();
    if (mounted) setState(() {});
  }

  Future<void> _deleteFile(VaultFile f) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.removeNamed(f.name)),
        content: Text(t.removeFileHint),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.remove)),
        ],
      ),
    );
    if (sure != true) return;
    _vault.removeFile(f.id);
    await _persist();
  }

  Widget _filesBody() {
    final q = _search.text.trim().toLowerCase();
    final files = _vault.visibleFiles
        .where((f) => q.isEmpty || f.name.toLowerCase().contains(q))
        .toList();

    final list = files.isEmpty
        ? Center(child: Text(t.noFilesYet))
        : _filesList(files);

    return Column(
      children: [
        _watchedPanel(),
        const Divider(height: 1),
        Expanded(child: list),
      ],
    );
  }

  Widget _filesList(List<VaultFile> files) {
    return ListView.separated(
      itemCount: files.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final f = files[i];
        return ListTile(
          leading: Icon(f.source == null
              ? Icons.insert_drive_file_outlined
              : Icons.sync_outlined),
          title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            f.source == null ? _humanSize(f.size) : '${_humanSize(f.size)} · ${f.source}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: t.saveToDisk,
                icon: const Icon(Icons.save_alt),
                onPressed: () => _saveFile(f),
              ),
              IconButton(
                tooltip: t.remove,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteFile(f),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body(List<VaultEntry> items) {
    final suggested = _suggested;
    final ids = suggested.map((e) => e.id).toSet();
    final rest = items.where((e) => !ids.contains(e.id)).toList();

    if (suggested.isEmpty && rest.isEmpty) {
      return Center(child: Text(t.nothingYet));
    }

    final highlight =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);

    final rows = <Object>[];
    if (suggested.isNotEmpty) {
      rows.add(t.forWindow(AutoTypeTarget.title));
      rows.addAll(suggested);
    }
    rows.addAll(rest);

    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final item = rows[i];
        if (item is String) {
          return _sectionHeader(
            item,
            onDismiss: () => setState(AutoTypeTarget.clear),
          );
        }

        final entry = item as VaultEntry;
        final inSuggestions = i <= suggested.length && suggested.isNotEmpty;

        return ColoredBox(
          color: inSuggestions ? highlight : Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_row(entry), const Divider(height: 1)],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String text, {VoidCallback? onDismiss}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              tooltip: t.dismiss,
              iconSize: 16,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
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

  Future<void> _openCopy(Uint8List bytes, String name) async =>
      _take(await reviewCopy(context, _store, _vault, bytes, name));

  Future<void> _openBackup() async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => BackupPage(store: _store, onOpenCopy: _openCopy),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSync() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SyncPage(drive: _drive, onSync: _syncDrive)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openVaultInfo() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VaultInfoPage(
          store: _store,
          drive: _drive,
          vault: _vault,
          onRename: (name) async {
            _vault.rename(name);
            await _persist();
            if (mounted) setState(() {});
          },
          beforeClose: () async {
            _driveSoon?.cancel();
            // A sync already running finishes first, then one last one.
            while (_driveBusy) {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            }
            await _syncDrive();
          },
          onSwitched: _reopen,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _backupBar(int count) {
    final theme = Theme.of(context);
    final status = _store.backup.status;
    final backup = _store.backup;

    // Only places still set up count: a folder just removed is no backup any more.
    final places = [...backup.targets, if (backup.remote.configured) backup.remote.host];
    final done = status.targets.where(places.contains).toList();
    final errors = status.errors.where((e) => places.any((p) => e.startsWith('$p:'))).toList();
    final syncedAt = _drive.syncedAt;

    final (IconData icon, Color color, String text) = switch (status) {
      _ when places.isEmpty && !_drive.connected => (
          Icons.cloud_off_outlined,
          theme.colorScheme.error,
          t.noBackupPlaces,
        ),
      _ when places.isEmpty => (
          Icons.cloud_done_outlined,
          theme.colorScheme.primary,
          syncedAt == null ? t.waitingFirstBackup : t.backedUpToDrive(_ago(syncedAt)),
        ),
      _ when errors.isNotEmpty => (
          Icons.error_outline,
          theme.colorScheme.error,
          t.backupFailed(errors.first),
        ),
      _ when status.at == null => (
          Icons.cloud_off_outlined,
          theme.hintColor,
          t.noBackupYet,
        ),
      _ when status.stale => (
          Icons.warning_amber_outlined,
          theme.colorScheme.tertiary,
          t.lastBackup(_ago(status.at!)),
        ),
      _ => (
          Icons.cloud_done_outlined,
          theme.colorScheme.primary,
          t.backedUpTo(_ago(status.at!), done.join(', ')),
        ),
    };

    final drive = !_drive.connected || places.isEmpty
        ? null
        : _drive.lastError != null
            ? t.driveProblem(_drive.lastError!)
            : syncedAt == null
                ? null
                : t.driveSynced(_ago(syncedAt));

    return InkWell(
      // With no folder or server the vault's safety is Google Drive.
      onTap: places.isEmpty ? _openSync : _openBackup,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
            if (drive != null) ...[
              Icon(
                _drive.lastError != null ? Icons.sync_problem : Icons.add_to_drive,
                size: 18,
                color: _drive.lastError != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(drive, style: theme.textTheme.bodySmall),
              const SizedBox(width: 16),
            ],
            Text(t.itemCount(count), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _row(VaultEntry e) {
    // A login shows the code pinned to it, like the code's own row.
    final code = _codes[e.id] ?? _codes[e.twoFactor];
    final selected = _selected.contains(e.id);
    final pinnedTo = e.isCode ? {for (final s in _vault.sitesOf(e)) hostOf(s)}.where((h) => h.isNotEmpty).join(', ') : '';
    return ListTile(
      selected: selected,
      onTap: () => _selected.isEmpty ? _open(e, isNew: false) : _toggle(e),
      leading: Tooltip(
        message: t.select,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _toggle(e),
          child: SiteAvatar(
            entry: e,
            icons: _store.icons,
            address: e.isCode ? (_vault.sitesOf(e).firstOrNull ?? '') : null,
            child: selected ? const Icon(Icons.check) : null,
          ),
        ),
      ),
      title: Text(
        e.title.isEmpty ? t.noTitle : e.title,
      ),
      subtitle: e.isCode
          ? (pinnedTo.isEmpty ? null : Text('📌 $pinnedTo', maxLines: 1, overflow: TextOverflow.ellipsis))
          : Text(
              _duplicateNotes[e.id] ?? e.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_filter == EntryFilter.duplicates)
            IconButton(
              tooltip: t.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteEntry(e),
            ),
          if (code != null) ...[
            InkWell(
              onTap: () => _copy(t.code, code),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${code.substring(0, 3)} ${code.substring(3)}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      letterSpacing: 1,
                      color: _left <= 5 ? Theme.of(context).colorScheme.error : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 84,
                    child: LinearProgressIndicator(
                      value: _left / 30,
                      minHeight: 2,
                      color: _left <= 5 ? Theme.of(context).colorScheme.error : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (code != null)
            IconButton(
              tooltip: t.typeCode,
              icon: const Icon(Icons.pin_outlined),
              onPressed: () => _autoType(e, codeOnly: true),
            ),
          // A code on its own has no username or password to type or copy.
          if (!e.isCode) ...[
            IconButton(
              tooltip: t.typeLogin,
              icon: const Icon(Icons.keyboard_outlined),
              onPressed: () => _autoType(e),
            ),
            IconButton(
              tooltip: t.copyPassword,
              icon: const Icon(Icons.copy_outlined),
              onPressed: () => _copy(t.password, e.password),
            ),
          ],
        ],
      ),
    );
  }
}

/// The site's own icon when Keyhold has one, otherwise its first letter.
class SiteAvatar extends StatelessWidget {
  const SiteAvatar({super.key, required this.entry, required this.icons, this.child, this.address});

  final VaultEntry entry;
  final Favicons icons;

  /// Where the icon comes from when the entry's own address is not it — a
  /// two-factor code shows the site it is pinned to.
  final String? address;

  /// Shown instead of either, such as the tick of a selected row.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) return CircleAvatar(child: child);
    return ValueListenableBuilder<int>(
      valueListenable: icons.changed,
      builder: (context, _, _) {
        final icon = icons.of(address ?? Favicons.addressOf(entry));
        if (icon == null) {
          return CircleAvatar(
            child: Text(entry.title.isEmpty ? '?' : entry.title.characters.first.toUpperCase()),
          );
        }
        return SizedBox.square(
          dimension: 40,
          child: Center(
            child: Image(image: icon, width: 32, height: 32, filterQuality: FilterQuality.medium),
          ),
        );
      },
    );
  }
}
