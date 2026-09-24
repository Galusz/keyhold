import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/drive.dart';
import '../core/remote.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';
import 'password_page.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key, required this.store, required this.drive, required this.onSync});

  final VaultStore store;
  final DriveSync drive;

  /// Runs a sync through the vault screen, which owns the open vault.
  final Future<SyncResult?> Function({String? password}) onSync;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _user;
  late final TextEditingController _key;
  late final TextEditingController _dir;
  late List<String> _folders;

  String? _message;
  bool _failed = false;
  bool _busy = false;
  String? _driveMessage;
  bool _driveBusy = false;

  @override
  void initState() {
    super.initState();
    final backup = widget.store.backup;
    final c = backup.remote;
    _folders = List<String>.from(backup.targets);
    _host = TextEditingController(text: c.host);
    _port = TextEditingController(text: c.port.toString());
    _user = TextEditingController(text: c.user);
    _key = TextEditingController(text: c.keyPath);
    _dir = TextEditingController(text: c.remoteDir);
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    _user.dispose();
    _key.dispose();
    _dir.dispose();
    super.dispose();
  }

  RemoteConfig _collect() => RemoteConfig(
    host: _host.text.trim(),
    port: int.tryParse(_port.text.trim()) ?? 22,
    user: _user.text.trim(),
    keyPath: _key.text.trim(),
    remoteDir: _dir.text.trim().isEmpty ? 'keyhold' : _dir.text.trim(),
  );

  Future<void> _addFolder() async {
    final path = await getDirectoryPath();
    if (path == null || _folders.contains(path)) return;
    setState(() => _folders.add(path));
  }

  String? _validate(RemoteConfig config) {
    if (config.host.isEmpty) return t.fillHostFirst;
    if (config.user.isEmpty) return t.fillUserFirst;
    if (config.keyPath.isEmpty) return t.pickKeyFirst;
    if (!File(config.keyPath).existsSync()) {
      return t.noFileAt(config.keyPath);
    }
    return null;
  }

  String _friendly(Object error) {
    final text = error.toString();
    if (text.contains('SocketException') || text.contains('TimeoutException')) {
      return t.serverUnreachable(_host.text, _port.text);
    }
    if (text.contains('auth') || text.contains('Auth')) {
      return t.serverRefusedKey(_user.text);
    }
    if (text.contains('FormatException') || text.contains('pem')) {
      return t.notAPrivateKey;
    }
    if (text.contains('Permission') || text.contains('permission')) {
      return t.cannotWriteFolder(_dir.text);
    }
    return text;
  }

  Future<void> _pickKey() async {
    final file = await openFile();
    if (file == null) return;
    setState(() => _key.text = file.path);
  }

  Future<void> _test() async {
    final config = _collect();
    final problem = _validate(config);
    if (problem != null) {
      setState(() {
        _message = problem;
        _failed = true;
      });
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await RemoteClient(config).test();
      setState(() {
        _message = result;
        _failed = false;
      });
    } catch (e) {
      setState(() {
        _message = _friendly(e);
        _failed = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _drive(Future<void> Function() action) async {
    setState(() {
      _driveBusy = true;
      _driveMessage = null;
    });
    try {
      await action();
    } on DriveError catch (e) {
      _driveMessage = e.message;
    } finally {
      if (mounted) setState(() => _driveBusy = false);
    }
  }

  Future<void> _syncDrive() async {
    var result = await widget.onSync();
    if (result != null && result.needsPassword) {
      final password = await _askPassword();
      if (password == null) {
        _driveMessage = t.driveHoldsVault;
        return;
      }
      result = await widget.onSync(password: password);
    }
    _driveMessage =
        widget.drive.lastError ??
        (result == null
            ? null
            : result.changedHere || result.uploaded
            ? t.synced
            : t.alreadyInSync);
  }

  Future<String?> _askPassword() {
    final field = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.masterPasswordOfDriveVault),
        content: SizedBox(
          width: 380,
          child: TextField(
            controller: field,
            obscureText: true,
            decoration: InputDecoration(labelText: t.masterPassword),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, field.text),
            child: Text(t.join),
          ),
        ],
      ),
    ).whenComplete(field.dispose);
  }

  String _when(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    final now = DateTime.now();
    final time = '${two(t.hour)}:${two(t.minute)}';
    return t.year == now.year && t.month == now.month && t.day == now.day
        ? time
        : '${two(t.day)}.${two(t.month)} $time';
  }

  List<Widget> _driveSection(ThemeData theme) {
    final drive = widget.drive;
    final synced = drive.syncedAt;

    return [
      Text(
        t.driveHint,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
      const SizedBox(height: 12),
      if (!DriveSync.available)
        Text(t.driveNotInBuild)
      else if (!widget.store.hasPassword) ...[
        Text(t.setPasswordFirst),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => PasswordPage(store: widget.store, unlockMode: false),
                ),
              );
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.lock_outline),
            label: Text(t.setMasterPassword),
          ),
        ),
      ] else if (!drive.connected)
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _driveBusy
                ? null
                : () => _drive(() async {
                    await drive.connect();
                    await _syncDrive();
                  }),
            icon: const Icon(Icons.add_to_drive),
            label: Text(t.connectDrive),
          ),
        )
      else
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(synced == null ? t.connectedAs(drive.email) : t.connectedAsSynced(drive.email, _when(synced))),
            OutlinedButton.icon(
              onPressed: _driveBusy ? null : () => _drive(_syncDrive),
              icon: const Icon(Icons.sync),
              label: Text(t.syncNow),
            ),
            TextButton(
              onPressed: _driveBusy ? null : () => _drive(drive.disconnect),
              child: Text(t.disconnect),
            ),
          ],
        ),
      if (_driveBusy) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
      if (_driveMessage != null) ...[const SizedBox(height: 8), Text(_driveMessage!)],
    ];
  }

  /// One kind of backup: a card with its state in the header, open or folded.
  Widget _section({
    required IconData icon,
    required String title,
    required String state,
    required List<Widget> children,
    bool open = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: open,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(state),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _save() {
    widget.store.backup
      ..targets = _folders
      ..remote = _collect()
      ..saveSettings();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.backup),
        actions: [
          TextButton(onPressed: _save, child: Text(t.save)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _section(
            icon: Icons.add_to_drive,
            title: 'Google Drive',
            state: widget.drive.connected ? t.onWith(widget.drive.email) : t.off,
            children: _driveSection(theme),
          ),
          _section(
            icon: Icons.folder_copy_outlined,
            title: t.foldersOnComputer,
            state: _folders.isEmpty
                ? t.off
                : widget.store.backup.status.at == null
                    ? t.folderCount(_folders.length)
                    : t.folderCountCopied(_folders.length, _when(widget.store.backup.status.at!)),
            children: _folderSection(theme),
          ),
          // For those who run their own machine; folded away until set up.
          _section(
            icon: Icons.dns_outlined,
            title: t.yourServer,
            state: _host.text.trim().isEmpty ? t.off : _host.text.trim(),
            open: _host.text.trim().isNotEmpty,
            children: _serverSection(theme),
          ),
        ],
      ),
    );
  }

  List<Widget> _folderSection(ThemeData theme) => [
    Text(
      t.foldersHint,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
    ),
    const SizedBox(height: 12),
    if (_folders.isEmpty)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          t.noFolders,
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    ..._folders.map(_folderRow),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      onPressed: _addFolder,
      icon: const Icon(Icons.add),
      label: Text(t.addFolder),
    ),
  ];

  List<Widget> _serverSection(ThemeData theme) => [
    Text(
      t.serverHint,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
    ),
    const SizedBox(height: 16),
    TextField(
      controller: _host,
      decoration: InputDecoration(
        labelText: t.host,
        hintText: 'vps.example.com',
        border: const OutlineInputBorder(),
      ),
    ),
    const SizedBox(height: 16),
    TextField(
      controller: _port,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: t.port, border: const OutlineInputBorder()),
    ),
    const SizedBox(height: 16),
    TextField(
      controller: _user,
      decoration: InputDecoration(labelText: t.user, border: const OutlineInputBorder()),
    ),
    const SizedBox(height: 16),
    TextField(
      controller: _key,
      decoration: InputDecoration(
        labelText: t.privateKeyFile,
        hintText: r'C:\Users\you\.ssh\id_ed25519',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          tooltip: t.chooseFile,
          icon: const Icon(Icons.folder_open),
          onPressed: _pickKey,
        ),
      ),
    ),
    const SizedBox(height: 16),
    TextField(
      controller: _dir,
      decoration: InputDecoration(
        labelText: t.serverFolder,
        border: const OutlineInputBorder(),
      ),
    ),
    const SizedBox(height: 24),
    OutlinedButton.icon(
      onPressed: _busy ? null : _test,
      icon: const Icon(Icons.wifi_tethering),
      label: Text(t.testConnection),
    ),
    if (_message != null) ...[
      const SizedBox(height: 20),
      Text(
        _message!,
        style: TextStyle(color: _failed ? theme.colorScheme.error : theme.colorScheme.primary),
      ),
    ],
  ];

  Widget _folderRow(String path) {
    final theme = Theme.of(context);
    final reachable = Directory(path).existsSync();

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        reachable ? Icons.folder_outlined : Icons.folder_off_outlined,
        color: reachable ? null : theme.colorScheme.error,
      ),
      title: Text(path, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: reachable
          ? null
          : Text(t.notReachable, style: TextStyle(color: theme.colorScheme.error)),
      trailing: IconButton(
        tooltip: t.remove,
        icon: const Icon(Icons.close),
        onPressed: () => setState(() => _folders.remove(path)),
      ),
    );
  }
}
