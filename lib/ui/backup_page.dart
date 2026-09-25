import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/backup.dart';
import '../core/remote.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';

/// Copies of the vault in folders and on the user's own server; they are
/// only copies, never another place the vault syncs with.
class BackupPage extends StatefulWidget {
  const BackupPage({
    super.key,
    required this.store,
    required this.onOpenCopy,
  });

  final VaultStore store;

  /// Opens a vault file (a backup copy) to look inside.
  final Future<void> Function(Uint8List bytes, String name) onOpenCopy;

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
    // On a phone the folder comes from Android's own folder window.
    if (Platform.isAndroid) {
      final tree = await PhoneFolderPlace.pick();
      if (tree != null && !_folders.contains(tree)) setState(() => _folders.add(tree));
      return;
    }
    final path = await getDirectoryPath();
    if (path == null || _folders.contains(path)) return;
    setState(() => _folders.add(path));
    // Copies of another vault in it (an earlier one, before a reinstall): it can be looked into.
    final copies = Directory(path)
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.startsWith('vault-') && f.path.endsWith('.khd'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    if (copies.isEmpty) return;
    final newest = copies.first;
    final bytes = newest.readAsBytesSync();
    if (await widget.store.opens(bytes) || !mounted) return;
    final bring = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.otherVaultTitle),
        content: Text(t.otherVaultHint(_when(newest.lastModifiedSync()))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.notNow)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.open)),
        ],
      ),
    );
    if (bring == true) await widget.onOpenCopy(bytes, newest.uri.pathSegments.last);
  }

  /// On a phone: the vault file to mail, send or keep anywhere. It opens only
  /// with the master password or the recovery key.
  Future<void> _shareCopy() async {
    final vault = await widget.store.load();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final name = (vault.name.isEmpty ? t.myVault : vault.name).replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
    final dir = Directory('${(await getTemporaryDirectory()).path}${Platform.pathSeparator}share')..createSync(recursive: true);
    for (final old in dir.listSync()) {
      old.deleteSync();
    }
    final file = File('${dir.path}${Platform.pathSeparator}Keyhold-$name-$stamp.khd');
    await File(widget.store.vaultPath).copy(file.path);
    await const MethodChannel('keyhold/share').invokeMethod('share', {'path': file.path, 'title': t.shareVaultCopy});
  }

  Future<void> _openCopyFile() async {
    const type = XTypeGroup(label: 'Keyhold', extensions: ['khd']);
    // Android knows no type for .khd files: any file can be picked there.
    final file = await openFile(acceptedTypeGroups: Platform.isAndroid ? const [] : const [type]);
    if (file == null) return;
    await widget.onOpenCopy(await file.readAsBytes(), file.name);
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
    if (!Platform.isAndroid) {
      setState(() => _key.text = file.path);
      return;
    }
    // A picked file on a phone is only lent for a moment: Keyhold keeps its own copy of the key.
    final base = await getApplicationSupportDirectory();
    final kept = File('${base.path}${Platform.pathSeparator}keyhold${Platform.pathSeparator}server-key');
    await kept.writeAsBytes(await file.readAsBytes(), flush: true);
    setState(() => _key.text = kept.path);
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

  String _when(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    final now = DateTime.now();
    final time = '${two(t.hour)}:${two(t.minute)}';
    return t.year == now.year && t.month == now.month && t.day == now.day
        ? time
        : '${two(t.day)}.${two(t.month)} $time';
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
    final backup = widget.store.backup;
    // A phone folder taken off the list gives back Keyhold's right to write there.
    for (final gone in backup.targets.where((t) => !_folders.contains(t) && PhoneFolderPlace.owns(t))) {
      PhoneFolderPlace.release(gone);
    }
    backup
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
        title: Text(t.copiesTab),
        actions: [
          TextButton(onPressed: _save, child: Text(t.save)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _section(
            icon: Icons.folder_copy_outlined,
            title: Platform.isAndroid ? t.foldersOnPhone : t.foldersOnComputer,
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
      Platform.isAndroid ? '${t.foldersSlotsHint} ${t.phoneFoldersHint} ${t.shareVaultHint}' : t.foldersSlotsHint,
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
    Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _addFolder,
          icon: const Icon(Icons.add),
          label: Text(t.addFolder),
        ),
        if (Platform.isAndroid)
          OutlinedButton.icon(
            onPressed: _shareCopy,
            icon: const Icon(Icons.share_outlined),
            label: Text(t.shareVaultCopy),
          ),
        OutlinedButton.icon(
          onPressed: _openCopyFile,
          icon: const Icon(Icons.visibility_outlined),
          label: Text(t.reviewCopy),
        ),
      ],
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
    final phone = PhoneFolderPlace.owns(path);
    final reachable = phone || Directory(path).existsSync();

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        reachable ? Icons.folder_outlined : Icons.folder_off_outlined,
        color: reachable ? null : theme.colorScheme.error,
      ),
      title: Text(phone ? PhoneFolderPlace.label(path) : path, maxLines: 1, overflow: TextOverflow.ellipsis),
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
