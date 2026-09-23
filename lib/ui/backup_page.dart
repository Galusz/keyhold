import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/drive.dart';
import '../core/remote.dart';
import '../core/storage.dart';
import 'password_page.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({
    super.key,
    required this.store,
    required this.drive,
    required this.onSync,
  });

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
    if (config.host.isEmpty) return 'Fill in the host first';
    if (config.user.isEmpty) return 'Fill in the user first';
    if (config.keyPath.isEmpty) return 'Pick your private key file first';
    if (!File(config.keyPath).existsSync()) {
      return 'There is no file at ${config.keyPath}';
    }
    return null;
  }

  String _friendly(Object error) {
    final text = error.toString();
    if (text.contains('SocketException') || text.contains('TimeoutException')) {
      return 'Cannot reach ${_host.text} on port ${_port.text}. '
          'Check the address, the port and whether the server is up.';
    }
    if (text.contains('auth') || text.contains('Auth')) {
      return 'The server refused this key for user ${_user.text}. '
          'Make sure the matching public key sits in its authorized_keys.';
    }
    if (text.contains('FormatException') || text.contains('pem')) {
      return 'That file is not a usable private key.';
    }
    if (text.contains('Permission') || text.contains('permission')) {
      return 'Logged in, but cannot write into "${_dir.text}". Pick another folder.';
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
        _driveMessage = 'Google Drive already holds a Keyhold vault. '
            'Its master password is needed to join it.';
        return;
      }
      result = await widget.onSync(password: password);
    }
    _driveMessage = widget.drive.lastError ??
        (result == null ? null : result.changedHere || result.uploaded ? 'Synced' : 'Already in sync');
  }

  Future<String?> _askPassword() {
    final field = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Master password of the vault in Google Drive'),
        content: SizedBox(
          width: 380,
          child: TextField(
            controller: field,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Master password'),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, field.text),
            child: const Text('Join'),
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
      Text('Google Drive', style: theme.textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        'Keeps the encrypted vault in a "Keyhold" folder in your own Google Drive, '
        'so your other devices stay in sync and a lost computer loses nothing. '
        'Google cannot read it.',
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
      const SizedBox(height: 12),
      if (!DriveSync.available)
        const Text('Google Drive is not set up in this build.')
      else if (!widget.store.hasPassword) ...[
        const Text('Set a master password first — a new device needs it to open the vault.'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute<bool>(
                builder: (_) => PasswordPage(store: widget.store, unlockMode: false),
              ));
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text('Set master password'),
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
            label: const Text('Connect Google Drive'),
          ),
        )
      else
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Connected as ${drive.email}'
                '${synced == null ? '' : ' — last sync ${_when(synced)}'}'),
            OutlinedButton.icon(
              onPressed: _driveBusy ? null : () => _drive(_syncDrive),
              icon: const Icon(Icons.sync),
              label: const Text('Sync now'),
            ),
            TextButton(
              onPressed: _driveBusy ? null : () => _drive(drive.disconnect),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      if (_driveBusy) ...[
        const SizedBox(height: 12),
        const LinearProgressIndicator(),
      ],
      if (_driveMessage != null) ...[
        const SizedBox(height: 8),
        Text(_driveMessage!),
      ],
      const Divider(height: 48),
    ];
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
        title: const Text('Backup'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ..._driveSection(theme),
          Text('Folders on this computer', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Every save drops a dated copy into each folder and keeps the last 30.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          if (_folders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No folders — local copies are off',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ..._folders.map(_folderRow),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addFolder,
            icon: const Icon(Icons.add),
            label: const Text('Add folder'),
          ),
          const Divider(height: 48),
          Text('Your server', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'The same copy goes over SFTP to a machine you own. The file stays encrypted, '
            'so the server sees bytes and nothing else. Leave the host empty to skip this.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _host,
            decoration: const InputDecoration(
              labelText: 'Host',
              hintText: 'vps.example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _port,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _user,
            decoration: const InputDecoration(
              labelText: 'User',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _key,
            decoration: InputDecoration(
              labelText: 'Private key file',
              hintText: r'C:\Users\you\.ssh\id_ed25519',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Choose file',
                icon: const Icon(Icons.folder_open),
                onPressed: _pickKey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dir,
            decoration: const InputDecoration(
              labelText: 'Folder on the server',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _busy ? null : _test,
            icon: const Icon(Icons.wifi_tethering),
            label: const Text('Test connection'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 20),
            Text(
              _message!,
              style: TextStyle(
                color: _failed ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

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
          : Text(
              'Not reachable right now',
              style: TextStyle(color: theme.colorScheme.error),
            ),
      trailing: IconButton(
        tooltip: 'Remove',
        icon: const Icon(Icons.close),
        onPressed: () => setState(() => _folders.remove(path)),
      ),
    );
  }
}
