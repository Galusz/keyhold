import 'dart:async';

import 'package:flutter/material.dart';

import '../core/drive.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';

/// Erases the open vault on this device, and on request its file in Google
/// Drive and its copies in the backup folders. Other vaults stay.
class DeleteVaultPage extends StatefulWidget {
  const DeleteVaultPage({super.key, required this.store, required this.drive, required this.onDeleted});

  final VaultStore store;
  final DriveSync drive;

  /// Keyhold goes back to its start screen.
  final Future<void> Function() onDeleted;

  @override
  State<DeleteVaultPage> createState() => _DeleteVaultPageState();
}

class _DeleteVaultPageState extends State<DeleteVaultPage> {
  bool _drive = false;
  bool _folders = false;
  bool _busy = false;
  bool _done = false;
  String? _error;

  Future<void> _delete() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.deleteVaultSure),
        content: Text(t.deleteVaultSureHint),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (sure != true) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Google Drive first: if it cannot be reached, nothing is gone yet.
      if (_drive && widget.drive.connected) await widget.drive.deleteMine();
      if (_folders) await widget.store.backup.deleteCopies(await widget.store.tag());
      await widget.store.deleteLocal();
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e is DriveError ? e.message : '$e';
      });
      return;
    }
    setState(() => _done = true);
    Timer(const Duration(seconds: 2), widget.onDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backup = widget.store.backup;
    return PopScope(
      canPop: !_busy && !_done,
      child: Scaffold(
        appBar: AppBar(title: Text(t.deleteVault)),
        body: _done
            ? Center(child: Text(t.vaultDeletedHere, style: theme.textTheme.titleMedium))
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Icon(Icons.delete_forever_outlined, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(t.deleteVaultHereHint, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  if (widget.drive.connected)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _drive,
                      onChanged: _busy ? null : (v) => setState(() => _drive = v ?? false),
                      title: Text(t.deleteVaultDriveMine),
                    ),
                  if (backup.targets.isNotEmpty)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _folders,
                      onChanged: _busy ? null : (v) => setState(() => _folders = v ?? false),
                      title: Text(t.deleteVaultFolders),
                      subtitle: Text(backup.targets.join(', ')),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                      onPressed: _busy ? null : _delete,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: Text(t.deleteVault),
                    ),
                  ),
                  if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
