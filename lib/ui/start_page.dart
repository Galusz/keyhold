import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/backup.dart';
import '../core/drive.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';
import 'password_page.dart';

/// An empty Keyhold: a new vault, or one that already exists somewhere.
class StartPage extends StatelessWidget {
  const StartPage({super.key, required this.store, required this.drive});

  final VaultStore store;
  final DriveSync drive;

  Future<void> _go(BuildContext context, Widget page) async {
    final done = await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => page));
    if (done == true && context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(32),
              children: [
                Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 20),
                Text('Keyhold', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  t.startHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () => _go(context, PasswordPage(store: store, mode: PasswordMode.create)),
                  icon: const Icon(Icons.add),
                  label: Text(t.createVault),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _go(context, OpenVaultPage(store: store, drive: drive)),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text(t.openMyVault),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A vault that already exists becomes this device's vault, as it is: from
/// Google Drive, from a file, or one opened here before. Nothing is merged.
class OpenVaultPage extends StatefulWidget {
  const OpenVaultPage({super.key, required this.store, required this.drive});

  final VaultStore store;
  final DriveSync drive;

  @override
  State<OpenVaultPage> createState() => _OpenVaultPageState();
}

class _OpenVaultPageState extends State<OpenVaultPage> {
  String? _error;
  bool _busy = false;

  VaultStore get _store => widget.store;

  Future<void> _ask(String title, String hint, Attempt attempt) async {
    final opened = await Navigator.of(context).push(MaterialPageRoute<bool>(
      builder: (_) => PasswordPage(store: _store, mode: PasswordMode.unlock, title: title, hint: hint, attempt: attempt),
    ));
    if (opened == true && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _fromDrive() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      if (!widget.drive.connected) await widget.drive.connect();
    } catch (e) {
      setState(() => _error = e is DriveError ? e.message : t.driveNotConnected('$e'));
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    await _ask(t.fromDrive, t.typeVaultPassword, (typed, status) async {
      final ({FoundVault? found, int files}) result;
      try {
        result = await widget.drive.find(typed, onTry: (at, of) => status(t.lookingForVault(at, of)));
      } on DriveError catch (e) {
        return e.message;
      }
      if (result.files == 0) return t.noVaultInDrive;
      final found = result.found;
      if (found == null) return t.noVaultMatches;
      // The vault open here already: nothing to change.
      if (!await _store.opens(found.bytes)) await _store.openVault(found.bytes, found.key);
      return null;
    });
  }

  Future<void> _fromFile() async {
    setState(() => _error = null);
    const type = XTypeGroup(label: 'Keyhold', extensions: ['khd']);
    // Android knows no type for .khd files: any file can be picked there.
    final file = await openFile(acceptedTypeGroups: Platform.isAndroid ? const [] : const [type]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (_store.isOpen && await _store.opens(bytes)) {
      setState(() => _error = t.sameVaultFile);
      return;
    }
    await _ask(t.fromFile, t.fileVaultPassword(file.name), (typed, _) async {
      final key = await _store.keyFor(bytes, typed);
      if (key == null) return t.passwordDoesNotOpen;
      await _store.openVault(bytes, key);
      return null;
    });
  }

  Future<void> _fromClosed(ClosedVault closed) async {
    setState(() => _error = null);
    final file = _store.closedFile(closed.tag);
    if (!file.existsSync()) {
      _store.backup
        ..closed = _store.backup.closed.where((c) => c.tag != closed.tag).toList()
        ..saveSettings();
      setState(() => _error = t.closedVaultGone);
      return;
    }
    final bytes = await file.readAsBytes();
    await _ask(_nameOf(closed), t.fileVaultPassword(_nameOf(closed)), (typed, _) async {
      final key = await _store.keyFor(bytes, typed);
      if (key == null) return t.passwordDoesNotOpen;
      await _store.openVault(bytes, key);
      return null;
    });
  }

  static String _nameOf(ClosedVault c) => c.name.isEmpty ? t.myVault : c.name;

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Widget _option(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: _busy ? null : onTap,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final closed = _store.backup.closed;
    return Scaffold(
      appBar: AppBar(title: Text(t.openVaultTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(t.openVaultHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 20),
          if (DriveSync.available)
            _option(
              Icons.add_to_drive,
              t.fromDrive,
              widget.drive.connected ? t.fromDriveAs(widget.drive.email) : t.fromDriveHint,
              _fromDrive,
            ),
          _option(Icons.insert_drive_file_outlined, t.fromFile, t.fromFileHint, _fromFile),
          if (closed.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(t.closedHere, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final c in closed)
              _option(
                Icons.history,
                _nameOf(c),
                '${t.itemCount(c.count)} · ${t.closedOn(_date(c.at))}',
                () => _fromClosed(c),
              ),
          ],
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
