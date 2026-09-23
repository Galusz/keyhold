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
import '../core/storage.dart';
import '../core/totp.dart';
import '../core/watch.dart';
import 'entry_page.dart';
import 'extension_page.dart';
import 'import_page.dart';
import 'password_page.dart';
import 'qr_page.dart';
import 'backup_page.dart';

enum EntryFilter { all, twoFactor, plain, files }

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
  final _selected = <String>{};
  BrowserBridge? _bridge;
  Timer? _watchTimer;
  late final _drive = DriveSync(_store);
  Timer? _driveTimer;
  Timer? _driveSoon;
  bool _driveBusy = false;
  bool _driveAgain = false;
  bool _driveNeedsPassword = false;
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
    final ready = await _store.init();
    if (!ready && mounted) {
      final unlocked = await Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => PasswordPage(store: _store, unlockMode: true),
        ),
      );
      if (unlocked != true) {
        setState(() => _loading = false);
        return;
      }
    }
    _vault = await _store.load();
    if (_autoGroup()) await _store.save(_vault);
    setState(() => _loading = false);
    await _startBridge();
    await _startWatching();
    unawaited(_syncDrive());
    _driveTimer = Timer.periodic(const Duration(minutes: 5), (_) => _syncDrive());
    await _refreshCodes();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refreshCodes());
  }

  /// Stores credentials the extension captured on a login form.
  Future<String> _saveFromBrowser(
      String url, String username, String password, bool update) async {
    if (password.isEmpty) return 'ignored';

    final existing = _findLogin(_vault.visible, url, '', username);
    if (existing != null) {
      if (existing.password == password) return 'unchanged';
      if (!update) return 'changed';
      existing.password = password;
      _vault.put(existing);
      await _persist();
      return 'updated';
    }

    _vault.put(VaultEntry(
      id: UniqueKey().toString(),
      title: _hostOf(url),
      username: username,
      password: password,
      url: url,
      group: 'Web',
    ));
    await _persist();
    return 'created';
  }

  /// The same login already in the vault: same site (or same title when there
  /// is no address) and the same username.
  VaultEntry? _findLogin(
      List<VaultEntry> entries, String url, String title, String username) {
    final host = _hostOf(url);
    final name = title.trim().toLowerCase();
    for (final e in entries) {
      if (e.username != username) continue;
      if (host.isNotEmpty ? _hostOf(e.url) == host : e.title.toLowerCase() == name) {
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
      final host = _hostOf(e.url.isNotEmpty ? e.url : e.title);
      e.group = _isLocal(host)
          ? 'Local network'
          : _ipPattern.hasMatch(host)
              ? 'Servers'
              : 'Web';
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
      onSave: _saveFromBrowser,
    );
    try {
      await bridge.start();
      _bridge = bridge;
    } catch (_) {
      // another instance already listens; the first one serves the extension
    }
  }

  Future<void> _import() async {
    final imported = await Navigator.of(context).push(
      MaterialPageRoute<List<VaultEntry>>(builder: (_) => const ImportPage()),
    );
    if (imported == null || imported.isEmpty) return;
    for (final entry in imported) {
      _vault.put(entry);
    }
    await _persist();
  }

  Future<void> _scanQr() async {
    final found = await Navigator.of(context).push(
      MaterialPageRoute<List<QrImport>>(builder: (_) => QrPage(entries: _vault.visible)),
    );
    if (found == null || found.isEmpty) return;
    for (final item in found) {
      final target = item.target;
      if (target != null) {
        target.totpSecret = item.code.secret;
        _vault.put(target);
      } else {
        _vault.put(VaultEntry(
          id: UniqueKey().toString(),
          title: item.code.issuer.isNotEmpty ? item.code.issuer : item.code.account,
          username: item.code.account,
          totpSecret: item.code.secret,
        ));
      }
    }
    await _persist();
    _toast('${found.length} two-factor ${found.length == 1 ? 'code' : 'codes'} saved');
  }

  Future<void> _setPassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PasswordPage(store: _store, unlockMode: false),
      ),
    );
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
  Future<SyncResult?> _syncDrive({String? password}) async {
    if (!_drive.connected) return null;
    if (_driveBusy) {
      _driveAgain = true;
      return null;
    }
    _driveBusy = true;
    try {
      final result = await _drive.sync(_vault, password: password);
      _driveNeedsPassword = result.needsPassword;
      final theirs = result.vault;
      if (theirs != null) {
        _vault = Vault.merge(_vault, theirs);
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

  Future<void> _open(VaultEntry entry, {required bool isNew}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<Object?>(
        builder: (_) => EntryPage(entry: entry, isNew: isNew, groups: _vault.groups),
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
        content: Text('$label copied'),
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _autoType(VaultEntry entry, {bool codeOnly = false}) async {
    final code = _codes[entry.id];
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

  String _hostOf(String url) {
    var text = url.trim().toLowerCase();
    if (text.isEmpty) return '';
    if (!text.contains('://')) text = 'https://$text';
    final host = Uri.tryParse(text)?.host ?? '';
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  /// Words worth matching a window title against: the site name and the entry title.
  Iterable<String> _keywordsOf(VaultEntry e) sync* {
    final host = _hostOf(e.url);
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
        : entries.where((e) => hosts.contains(_hostOf(e.url))).toList();

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

    all = switch (_filter) {
      EntryFilter.twoFactor => all.where(_hasCode).toList(),
      EntryFilter.plain => all.where((e) => !_hasCode(e)).toList(),
      EntryFilter.all || EntryFilter.files => all,
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
          filter(Icons.all_inbox_outlined, 'All', visible.length, EntryFilter.all),
          filter(Icons.pin_outlined, '2FA', withCode, EntryFilter.twoFactor),
          filter(Icons.key_outlined, 'Passwords', visible.length - withCode,
              EntryFilter.plain),
          filter(Icons.attach_file, 'Files', _vault.visibleFiles.length,
              EntryFilter.files),
          if (groups.isNotEmpty) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text('Groups',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            ),
            for (final name in groups) group(Icons.folder_outlined, name, name),
            if ((counts[''] ?? 0) > 0) group(Icons.folder_off_outlined, 'No group', ''),
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
        title: Text('Move ${_selected.length} to group'),
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
                decoration: const InputDecoration(
                  labelText: 'New group',
                  helperText: 'Leave empty to take them out of any group',
                ),
                onSubmitted: (v) => Navigator.pop(context, v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, name.text.trim()),
            child: const Text('Move'),
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
                tooltip: 'Clear selection',
                icon: const Icon(Icons.close),
                onPressed: () => setState(_selected.clear),
              )
            : null,
        title: Text(selecting ? '${_selected.length} selected' : 'Keyhold'),
        actions: selecting
            ? [
                FilledButton.icon(
                  onPressed: _moveSelected,
                  icon: const Icon(Icons.drive_file_move_outlined),
                  label: const Text('Move to group'),
                ),
                const SizedBox(width: 16),
              ]
            : [
          IconButton(
            tooltip: 'Add two-factor codes from a QR code',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQr,
          ),
          IconButton(
            tooltip: 'Browser extension',
            icon: const Icon(Icons.extension_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExtensionPage(
                  token: _store.ensureBridgeToken(),
                  running: _bridge?.running ?? false,
                  extensionPath: _extensionFolder(),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Backup',
            icon: const Icon(Icons.backup_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => BackupPage(store: _store, drive: _drive, onSync: _syncDrive),
                ),
              );
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Import from CSV',
            icon: const Icon(Icons.download_outlined),
            onPressed: _import,
          ),
          IconButton(
            tooltip: _store.hasPassword ? 'Change master password' : 'Set master password',
            icon: Icon(_store.hasPassword ? Icons.lock_outline : Icons.lock_open_outlined),
            onPressed: _setPassword,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _filter == EntryFilter.files
          ? FloatingActionButton.extended(
              onPressed: _addFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add file'),
            )
          : FloatingActionButton.extended(
              onPressed: () => _open(
                  VaultEntry(id: UniqueKey().toString(), group: _group ?? ''),
                  isNew: true),
              icon: const Icon(Icons.add),
              label: const Text('New'),
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
    if (_store.backup.watched == null) {
      _store.backup.watched = defaultWatched();
      _store.backup.saveSettings();
    }
    await _scan();
    _watchTimer = Timer.periodic(const Duration(minutes: 15), (_) => _scan());
  }

  Future<void> _scan() async {
    if (_scanning) return;
    _scanning = true;
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

  Future<void> _watch({required bool folder}) async {
    final path = folder ? await getDirectoryPath() : (await openFile())?.path;
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
        if (src == root || src.startsWith('$root${Platform.pathSeparator}')) {
          countFor[root] = (countFor[root] ?? 0) + 1;
        }
      }
    }

    String status;
    if (_scanning) {
      status = 'Checking…';
    } else if (scan == null) {
      status = 'Not checked yet';
    } else {
      final when = _ago(_lastScanAt!);
      final parts = [
        if (scan.added > 0) '${scan.added} new',
        if (scan.updated > 0) '${scan.updated} changed',
        if (scan.skipped.isNotEmpty) '${scan.skipped.length} skipped',
      ];
      status = 'Checked $when${parts.isEmpty ? ' — nothing changed' : ' — ${parts.join(', ')}'}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Watched — copied into the vault whenever they change, every 15 minutes',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          if (_watched.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Nothing watched yet', style: theme.textTheme.bodyMedium),
            ),
          ..._watched.map((path) {
            final missing = scan?.missing.contains(path) ?? false;
            return Row(
              children: [
                Icon(
                  missing
                      ? Icons.error_outline
                      : FileSystemEntity.isDirectorySync(path)
                          ? Icons.folder_outlined
                          : Icons.insert_drive_file_outlined,
                  size: 18,
                  color: missing ? theme.colorScheme.error : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    missing ? '$path — not found' : '$path  (${countFor[path] ?? 0})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: missing ? theme.colorScheme.error : null),
                  ),
                ),
                IconButton(
                  tooltip: 'Stop watching',
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
                onPressed: () => _watch(folder: true),
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                label: const Text('Watch folder'),
              ),
              OutlinedButton.icon(
                onPressed: () => _watch(folder: false),
                icon: const Icon(Icons.note_add_outlined, size: 18),
                label: const Text('Watch file'),
              ),
              TextButton.icon(
                onPressed: _scanning ? null : _scan,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Check now'),
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
      _toast('${picked.name} is ${_humanSize(bytes.length)} — the limit is 25 MB');
      return;
    }

    _vault.putFile(VaultFile(
      id: UniqueKey().toString(),
      name: picked.name,
      data: base64Encode(bytes),
      size: bytes.length,
    ));
    await _persist();
    _toast('${picked.name} is now in the vault');
  }

  Future<void> _saveFile(VaultFile f) async {
    final target = await getSaveLocation(suggestedName: f.name);
    if (target == null) return;
    await File(target.path).writeAsBytes(f.bytes, flush: true);
    _toast('Saved to ${target.path}');
  }

  Future<void> _deleteFile(VaultFile f) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${f.name}?'),
        content: const Text('It disappears from the vault. Older backups still hold it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
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
        ? const Center(child: Text('No files yet — add recovery codes, keys or scans'))
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
                tooltip: 'Save to disk',
                icon: const Icon(Icons.save_alt),
                onPressed: () => _saveFile(f),
              ),
              IconButton(
                tooltip: 'Remove',
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
      return const Center(child: Text('Nothing here yet'));
    }

    final highlight =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);

    final rows = <Object>[];
    if (suggested.isNotEmpty) {
      rows.add('For "${AutoTypeTarget.title}"');
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
              tooltip: 'Dismiss',
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
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} days ago';
  }

  Widget _backupBar(int count) {
    final theme = Theme.of(context);
    final status = _store.backup.status;

    final (IconData icon, Color color, String text) = switch (status) {
      _ when status.errors.isNotEmpty => (
          Icons.error_outline,
          theme.colorScheme.error,
          'Backup failed: ${status.errors.first}',
        ),
      _ when status.at == null => (
          Icons.cloud_off_outlined,
          theme.hintColor,
          'No backup yet — it runs on the first save',
        ),
      _ when status.stale => (
          Icons.warning_amber_outlined,
          theme.colorScheme.tertiary,
          'Last backup ${_ago(status.at!)}',
        ),
      _ => (
          Icons.cloud_done_outlined,
          theme.colorScheme.primary,
          'Backed up ${_ago(status.at!)} — ${status.targets.join(', ')}',
        ),
    };

    final syncedAt = _drive.syncedAt;
    final drive = !_drive.connected
        ? null
        : _driveNeedsPassword
            ? 'Google Drive: open Backup and enter the master password'
            : _drive.lastError != null
                ? 'Google Drive: ${_drive.lastError}'
                : syncedAt == null
                    ? null
                    : 'Google Drive: synced ${_ago(syncedAt)}';

    return Container(
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
              _drive.lastError != null || _driveNeedsPassword
                  ? Icons.sync_problem
                  : Icons.add_to_drive,
              size: 18,
              color: _drive.lastError != null || _driveNeedsPassword
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(drive, style: theme.textTheme.bodySmall),
            const SizedBox(width: 16),
          ],
          Text('$count items', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _row(VaultEntry e) {
    final code = _codes[e.id];
    final selected = _selected.contains(e.id);
    return ListTile(
      selected: selected,
      onTap: () => _selected.isEmpty ? _open(e, isNew: false) : _toggle(e),
      leading: Tooltip(
        message: 'Select',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _toggle(e),
          child: CircleAvatar(
            child: selected
                ? const Icon(Icons.check)
                : Text(e.title.isEmpty ? '?' : e.title.characters.first.toUpperCase()),
          ),
        ),
      ),
      title: Text(e.title.isEmpty ? '(no title)' : e.title),
      subtitle: Text(e.username, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (code != null) ...[
            InkWell(
              onTap: () => _copy('Code', code),
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
              tooltip: 'Type the code into the previous window',
              icon: const Icon(Icons.pin_outlined),
              onPressed: () => _autoType(e, codeOnly: true),
            ),
          IconButton(
            tooltip: 'Type username and password',
            icon: const Icon(Icons.keyboard_outlined),
            onPressed: () => _autoType(e),
          ),
          IconButton(
            tooltip: 'Copy password',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () => _copy('Password', e.password),
          ),
        ],
      ),
    );
  }
}
