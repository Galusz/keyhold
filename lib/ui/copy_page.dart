import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/importers.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';

/// A backup copy (from a folder, a pendrive, a year ago) opened only to look
/// inside; the entries ticked there come back, to be added as new ones. The
/// vault itself stays as it is.
Future<List<VaultEntry>?> reviewCopy(
    BuildContext context, VaultStore store, Vault vault, Uint8List bytes, String name) async {
  var copy = await store.openCopy(bytes);
  if (copy == null && context.mounted) {
    final field = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.copyPasswordTitle),
        content: SizedBox(
          width: 380,
          child: TextField(
            controller: field,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: t.masterPassword, helperText: t.orRecoveryCode, helperMaxLines: 2),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, field.text), child: Text(t.open)),
        ],
      ),
    ).whenComplete(field.dispose);
    if (password == null) return null;
    copy = await store.openCopy(bytes, password);
  }
  if (!context.mounted) return null;
  if (copy == null) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(t.copyNotOpened)));
    return null;
  }
  return Navigator.of(context).push(MaterialPageRoute<List<VaultEntry>>(
    builder: (_) => CopyPage(
      title: t.copyTitle(name),
      hint: t.copyReadOnly,
      entries: entriesOf(copy!),
      vault: vault,
      ticked: false,
    ),
  ));
}

/// Entries from somewhere else — a backup copy, another vault, another app's
/// export — to look through and tick; the ticked ones go into the vault as
/// new entries. Nothing here changes the vault until "Add".
class CopyPage extends StatefulWidget {
  const CopyPage({
    super.key,
    required this.title,
    required this.hint,
    required this.entries,
    required this.vault,
    this.ticked = true,
    this.leftOut = const [],
    this.plainFile,
  });

  final String title;
  final String hint;
  final List<VaultEntry> entries;

  /// The open vault: what it already holds is shown and left unticked.
  final Vault vault;

  /// Whether new entries start ticked (an import) or not (looking into a copy).
  final bool ticked;

  /// Lines about what the file held that could not come along.
  final List<String> leftOut;

  /// A file with passwords in plain text, offered for deletion afterwards.
  final String? plainFile;

  @override
  State<CopyPage> createState() => _CopyPageState();
}

/// Whether [vault] already holds [e]: the same two-factor key, or the same
/// login (site or title, username and password).
bool alreadyIn(Vault vault, VaultEntry e) {
  final secret = (e.totpSecret ?? '').toUpperCase();
  for (final mine in vault.visible) {
    if (e.isCode) {
      if (mine.isCode && (mine.totpSecret ?? '').toUpperCase() == secret) return true;
      continue;
    }
    if (mine.isCode || mine.username != e.username || mine.password != e.password) continue;
    final host = hostOf(e.url);
    if (host.isNotEmpty ? hostOf(mine.url) == host : mine.title.toLowerCase() == e.title.toLowerCase()) return true;
  }
  return false;
}

class _CopyPageState extends State<CopyPage> {
  final _search = TextEditingController();
  late final Set<String> _have = {for (final e in widget.entries) if (alreadyIn(widget.vault, e)) e.id};
  late final Set<String> _picked = {
    if (widget.ticked)
      for (final e in widget.entries)
        if (!_have.contains(e.id)) e.id,
  };
  bool _deleteFile = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add() {
    final picked = widget.entries.where((e) => _picked.contains(e.id)).toList();
    final file = widget.plainFile;
    if (_deleteFile && file != null) {
      try {
        File(file).deleteSync();
      } catch (_) {
        // open elsewhere: the entries came in all the same
      }
    }
    Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _search.text.trim().toLowerCase();
    final shown = widget.entries
        .where((e) => q.isEmpty || '${e.title} ${e.username} ${e.url}'.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    final allPicked = shown.isNotEmpty && shown.every((e) => _picked.contains(e.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.hint, style: theme.textTheme.bodySmall),
                for (final line in widget.leftOut)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(line, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
          CheckboxListTile(
            value: allPicked,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(t.selectAll),
            onChanged: (on) => setState(() {
              for (final e in shown) {
                on == true ? _picked.add(e.id) : _picked.remove(e.id);
              }
            }),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: shown.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = shown[i];
                final have = _have.contains(e.id);
                final kind = e.isCode
                    ? t.twoFactorCode
                    : (e.totpSecret ?? '').isNotEmpty
                        ? '${e.username} · ${t.twoFactorCode}'
                        : e.username;
                return ListTile(
                  leading: Checkbox(
                    value: _picked.contains(e.id),
                    onChanged: (on) => setState(() => on == true ? _picked.add(e.id) : _picked.remove(e.id)),
                  ),
                  title: Text(e.title.isEmpty ? t.noTitle : e.title),
                  subtitle: Text(have ? '$kind · ${t.alreadyInVault}' : kind),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => _CopyEntry(entry: e),
                  )),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  if (widget.plainFile != null)
                    Expanded(
                      child: CheckboxListTile(
                        value: _deleteFile,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(t.deletePlainFile),
                        subtitle: Text(t.deleteCsvHint),
                        onChanged: (on) => setState(() => _deleteFile = on ?? false),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _picked.isEmpty ? null : _add,
                    icon: const Icon(Icons.add),
                    label: Text(t.addSelected(_picked.length)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyEntry extends StatefulWidget {
  const _CopyEntry({required this.entry});

  final VaultEntry entry;

  @override
  State<_CopyEntry> createState() => _CopyEntryState();
}

class _CopyEntryState extends State<_CopyEntry> {
  bool _show = false;

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
        ],
      ),
    );
  }
}
