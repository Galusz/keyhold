import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models.dart';
import '../l10n/l10n.dart';

/// A backup copy opened only to look inside — an old password found, a single
/// entry taken back into the vault. Nothing here changes the vault by itself.
class CopyPage extends StatefulWidget {
  const CopyPage({super.key, required this.copy, required this.name, required this.onAdd});

  final Vault copy;
  final String name;
  final Future<void> Function(VaultEntry entry) onAdd;

  @override
  State<CopyPage> createState() => _CopyPageState();
}

class _CopyPageState extends State<CopyPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _search.text.trim().toLowerCase();
    final entries = widget.copy.visible
        .where((e) => q.isEmpty || '${e.title} ${e.username} ${e.url}'.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return Scaffold(
      appBar: AppBar(title: Text(t.copyTitle(widget.name))),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(t.copyReadOnly, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.search,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = entries[i];
                return ListTile(
                  title: Text(e.title.isEmpty ? t.noTitle : e.title),
                  subtitle: Text(e.isCode ? t.twoFactorCode : e.username),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => _CopyEntry(entry: e, onAdd: widget.onAdd),
                  )),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyEntry extends StatefulWidget {
  const _CopyEntry({required this.entry, required this.onAdd});

  final VaultEntry entry;
  final Future<void> Function(VaultEntry entry) onAdd;

  @override
  State<_CopyEntry> createState() => _CopyEntryState();
}

class _CopyEntryState extends State<_CopyEntry> {
  bool _show = false;
  bool _added = false;

  Widget _field(String label, String value, {bool secret = false}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(secret && !_show ? '••••••••••' : value, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secret)
            IconButton(
              icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _show = !_show),
            ),
          IconButton(
            tooltip: t.copy,
            icon: const Icon(Icons.copy_outlined),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(t.copied(label))));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Scaffold(
      appBar: AppBar(title: Text(e.title.isEmpty ? t.noTitle : e.title)),
      body: ListView(
        children: [
          _field(t.username, e.username),
          _field(t.password, e.password, secret: true),
          _field(t.key, e.totpSecret ?? '', secret: true),
          _field(t.address, e.url),
          _field(t.notes, e.notes),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _added
                    ? null
                    : () async {
                        await widget.onAdd(e);
                        if (mounted) setState(() => _added = true);
                      },
                icon: Icon(_added ? Icons.check : Icons.add),
                label: Text(_added ? t.addedToVault(e.title) : t.addToVault),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
