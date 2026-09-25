import 'package:flutter/material.dart';

import '../core/drive.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';
import 'delete_vault_page.dart';
import 'password_page.dart';
import 'recovery_page.dart';
import 'start_page.dart';

/// The vault itself: its name, its recovery key, another vault instead of
/// this one, and deleting it. The master password is not changed here: only
/// the recovery key replaces a forgotten one.
class VaultInfoPage extends StatefulWidget {
  const VaultInfoPage({
    super.key,
    required this.store,
    required this.drive,
    required this.vault,
    required this.onRename,
    required this.beforeClose,
    required this.onSwitched,
  });

  final VaultStore store;
  final DriveSync drive;
  final Vault vault;
  final Future<void> Function(String name) onRename;

  /// Brings the vault's last changes to Google Drive before it closes here.
  final Future<void> Function() beforeClose;

  /// Another vault is open now, or none is (this one was deleted).
  final Future<void> Function() onSwitched;

  @override
  State<VaultInfoPage> createState() => _VaultInfoPageState();
}

class _VaultInfoPageState extends State<VaultInfoPage> {
  String get _name => widget.vault.name.isEmpty ? t.myVault : widget.vault.name;

  Future<void> _rename() async {
    final field = TextEditingController(text: _name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.renameVault),
        content: SizedBox(
          width: 380,
          child: TextField(
            controller: field,
            autofocus: true,
            decoration: InputDecoration(labelText: t.vaultName),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, field.text), child: Text(t.save)),
        ],
      ),
    ).whenComplete(field.dispose);
    if (name == null || name.trim().isEmpty) return;
    await widget.onRename(name.trim());
    if (mounted) setState(() {});
  }

  /// Another vault instead of this one, after saying plainly that nothing is lost.
  Future<void> _switch(Widget page) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.closeVaultTitle(_name)),
        content: Text(t.closeVaultHint),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.continueLabel)),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    await widget.beforeClose();
    if (!mounted) return;
    final done = await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => page));
    if (done == true) await widget.onSwitched();
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = widget.store;
    return Scaffold(
      appBar: AppBar(title: Text(t.vaultTab)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(Icons.key_outlined, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, style: theme.textTheme.titleLarge),
                    Text(t.itemCount(widget.vault.visible.length), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(tooltip: t.renameVault, icon: const Icon(Icons.edit_outlined), onPressed: _rename),
            ],
          ),
          const SizedBox(height: 16),
          Text(t.vaultInfoHint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 20),
          _tile(
            Icons.print_outlined,
            t.recoveryKey,
            t.recoveryKeyHint,
            () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RecoveryPage(store: store))),
          ),
          const SizedBox(height: 16),
          Text(t.otherVaults, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _tile(
            Icons.swap_horiz,
            t.openOtherVault,
            t.openOtherVaultHint,
            () => _switch(OpenVaultPage(store: store, drive: widget.drive)),
          ),
          _tile(
            Icons.add,
            t.createVault,
            t.createNewVaultHint,
            () => _switch(PasswordPage(store: store, mode: PasswordMode.create)),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => DeleteVaultPage(store: store, drive: widget.drive, onDeleted: widget.onSwitched),
              )),
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(t.deleteVault),
            ),
          ),
        ],
      ),
    );
  }
}
