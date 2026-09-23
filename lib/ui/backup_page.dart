import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/remote.dart';
import '../core/storage.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key, required this.store});

  final VaultStore store;

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
