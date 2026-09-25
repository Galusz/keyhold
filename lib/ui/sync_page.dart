import 'package:flutter/material.dart';

import '../core/drive.dart';
import '../l10n/l10n.dart';

/// The one place that keeps this vault in step between devices: its own file
/// in the user's Google Drive.
class SyncPage extends StatefulWidget {
  const SyncPage({super.key, required this.drive, required this.onSync});

  final DriveSync drive;

  /// Runs a sync through the vault screen, which owns the open vault.
  final Future<SyncResult?> Function() onSync;

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  String? _message;
  bool _busy = false;

  DriveSync get _drive => widget.drive;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on DriveError catch (e) {
      _message = e.message;
    } catch (e) {
      _message = t.driveNotConnected('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncNow() async {
    final result = await widget.onSync();
    _message = _drive.lastError ??
        (result == null
            ? null
            : result.changedHere || result.uploaded
                ? t.synced
                : t.alreadyInSync);
  }

  String _when(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    final now = DateTime.now();
    final time = '${two(t.hour)}:${two(t.minute)}';
    return t.year == now.year && t.month == now.month && t.day == now.day
        ? time
        : '${two(t.day)}.${two(t.month)} $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final synced = _drive.syncedAt;
    return Scaffold(
      appBar: AppBar(title: Text(t.syncTab)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(Icons.add_to_drive, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text('Google Drive', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(t.driveVaultHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 20),
          if (!DriveSync.available)
            Text(t.driveNotInBuild)
          else if (!_drive.connected)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                          await _drive.connect();
                          await _syncNow();
                        }),
                icon: const Icon(Icons.add_to_drive),
                label: Text(t.connectDrive),
              ),
            )
          else ...[
            Text(synced == null ? t.connectedAs(_drive.email) : t.connectedAsSynced(_drive.email, _when(synced))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _run(_syncNow),
                  icon: const Icon(Icons.sync),
                  label: Text(t.syncNow),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _run(_drive.disconnect),
                  child: Text(t.disconnect),
                ),
              ],
            ),
          ],
          if (_busy) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
          if (_message != null) ...[const SizedBox(height: 8), Text(_message!)],
        ],
      ),
    );
  }
}
