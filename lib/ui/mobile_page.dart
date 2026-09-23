import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/drive.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../core/totp.dart';
import 'entry_page.dart';
import 'password_page.dart';
import 'qr_page.dart';
import 'vault_page.dart' show kPending;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    if (state == AppLifecycleState.resumed) unawaited(_sync());
  }

  Future<void> _boot() async {
    final ready = await _store.init();
    if (!ready && mounted) {
      await Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (_) => PasswordPage(store: _store, unlockMode: true),
      ));
    }
    _vault = await _store.load();
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
      _toast('Google Drive was not connected: $e');
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
        title: const Text('Master password'),
        content: TextField(
          controller: field,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Master password of your vault',
            helperText: 'The one you set in Keyhold on your computer',
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, field.text), child: const Text('Open')),
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
    _toast('$label copied');
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
              title: const Text('Scan a QR code'),
              subtitle: const Text('Two-factor code of a website or a Google Authenticator export'),
              onTap: () => Navigator.pop(context, 'qr'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('New entry'),
              onTap: () => Navigator.pop(context, 'new'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'qr') await _scanQr();
    if (choice == 'new') await _edit(VaultEntry(id: UniqueKey().toString()), isNew: true);
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

  Future<void> _edit(VaultEntry entry, {required bool isNew}) async {
    final result = await Navigator.of(context).push(MaterialPageRoute<Object?>(
      builder: (_) => EntryPage(entry: entry, isNew: isNew, groups: _vault.groups),
    ));
    if (result == 'delete') {
      _vault.remove(entry.id);
      await _persist();
    } else if (result == true) {
      _vault.put(entry);
      await _persist();
    }
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

  Future<void> _settings() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _Settings(store: _store, drive: _drive, onConnect: _connect, onSync: _sync),
    ));
    setState(() {});
  }

  // ---------- screens ----------

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _settings,
          ),
        ],
      ),
      bottomNavigationBar: _backupBar(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
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
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Codes'), icon: Icon(Icons.pin_outlined)),
                ButtonSegment(value: false, label: Text('Everything'), icon: Icon(Icons.key_outlined)),
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
                        child: Text(_codesOnly
                            ? 'No two-factor codes yet — tap + to scan one'
                            : 'Nothing here yet'),
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
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} days ago';
  }

  /// Always on screen: losing the phone must never mean losing the codes.
  Widget _backupBar() {
    final theme = Theme.of(context);
    final synced = _drive.syncedAt;
    final (IconData icon, Color color, String text) = switch (_drive) {
      _ when !_drive.connected => (
          Icons.cloud_off_outlined,
          theme.colorScheme.error,
          'Not backed up — tap to connect Google Drive',
        ),
      _ when _syncing => (Icons.cloud_sync_outlined, theme.hintColor, 'Backing up…'),
      _ when _drive.lastError != null => (
          Icons.sync_problem,
          theme.colorScheme.error,
          'Backup failed: ${_drive.lastError}',
        ),
      _ when synced == null => (Icons.cloud_upload_outlined, theme.hintColor, 'Waiting for the first backup'),
      _ => (Icons.cloud_done_outlined, theme.colorScheme.primary, 'Backed up to Google Drive ${_ago(synced)}'),
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
    final code = _codes[e.id];
    final warn = _left <= 5 ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      onTap: () => code != null ? _copy('Code', code) : _details(e),
      onLongPress: () => _details(e),
      leading: CircleAvatar(
        child: Text(e.title.isEmpty ? '?' : e.title.characters.first.toUpperCase()),
      ),
      title: Text(
        e.title.isEmpty ? '(no title)' : e.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: e.pending ? const TextStyle(color: kPending) : null,
      ),
      subtitle: Text(
        e.pending ? '${e.username} · not confirmed' : e.username,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: code == null
          ? (e.pending
              ? IconButton(
                  tooltip: 'Confirm',
                  icon: const Icon(Icons.check_circle_outline, color: kPending),
                  onPressed: () async {
                    e.pending = false;
                    _vault.put(e);
                    await _persist();
                  },
                )
              : const Icon(Icons.chevron_right))
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
                'Your passwords and two-factor codes — the same vault as on your computer, '
                'kept in step through your own Google Drive.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.add_to_drive),
                label: const Text('Connect Google Drive'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _welcome = false),
                child: const Text('Start with an empty vault'),
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
  final Future<void> Function() onEdit;

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
            tooltip: 'Copy',
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
        title: Text(e.title.isEmpty ? '(no title)' : e.title),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await widget.onEdit();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (code != null)
            _field('Code (${widget.left()} s)', '${code.substring(0, 3)} ${code.substring(3)}'),
          _field('Username', e.username),
          _field('Password', e.password, secret: true),
          _field('Address', e.url),
          _field('Notes', e.notes),
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

class _SettingsState extends State<_Settings> {
  bool _busy = false;

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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Google Drive', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            drive.connected
                ? 'Connected as ${drive.email}${synced == null ? '' : ' — last sync ${TimeOfDay.fromDateTime(synced).format(context)}'}'
                : 'Not connected — the vault lives only on this phone.',
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
                  label: const Text('Connect'),
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _run(() async => widget.onSync()),
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync now'),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _run(drive.disconnect),
                  child: const Text('Disconnect'),
                ),
              ],
            ],
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
          const Divider(height: 40),
          Text('Master password', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            widget.store.hasPassword
                ? 'Set. It opens this vault on a new device.'
                : 'Not set. Without it a new device cannot open the vault.',
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
              label: Text(widget.store.hasPassword ? 'Change' : 'Set master password'),
            ),
          ),
        ],
      ),
    );
  }
}
