import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/importers.dart';
import '../core/models.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';
import 'copy_page.dart';

/// Brings entries in from another password manager, an authenticator app, a
/// KeePass database or another Keyhold vault. Any file can be picked; what it
/// is shows from its content. Returns the entries to add.
class ImportPage extends StatefulWidget {
  const ImportPage({super.key, required this.store, required this.vault});

  final VaultStore store;
  final Vault vault;

  @override
  State<ImportPage> createState() => _ImportPageState();
}

/// Every format whose export keeps passwords readable to anyone with the file.
const _plainFormats = {'CSV', 'Bitwarden', '1Password', 'Aegis', '2FAS', 'andOTP', 'FreeOTP+'};

class _ImportPageState extends State<ImportPage> {
  String? _error;
  bool _busy = false;

  Future<String?> _askPassword(String format, {bool wrong = false}) {
    final field = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.importPasswordTitle(format)),
        content: SizedBox(
          width: 380,
          child: TextField(
            controller: field,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.password,
              helperText: format == 'Keyhold' ? t.orRecoveryCode : null,
              helperMaxLines: 2,
              errorText: wrong ? t.importWrongPassword : null,
            ),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, field.text), child: Text(t.open)),
        ],
      ),
    ).whenComplete(field.dispose);
  }

  Future<void> _pick() async {
    setState(() => _error = null);
    final file = await openFile();
    if (file == null) return;
    final bytes = await file.readAsBytes();

    var password = '';
    var format = '';
    Imported? read;
    while (read == null) {
      setState(() => _busy = true);
      try {
        read = await readImport(bytes, widget.store, password: password);
      } on ImportNeedsPassword catch (e) {
        setState(() => _busy = false);
        format = e.format;
        final typed = await _askPassword(format);
        if (typed == null || typed.isEmpty) return;
        password = typed;
      } on ImportWrongPassword {
        setState(() => _busy = false);
        if (!mounted) return;
        final typed = await _askPassword(format, wrong: true);
        if (typed == null || typed.isEmpty) return;
        password = typed;
      } on ImportFailed catch (e) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
        return;
      } catch (_) {
        setState(() {
          _busy = false;
          _error = t.importUnknown;
        });
        return;
      }
    }
    setState(() => _busy = false);
    if (read.entries.isEmpty) {
      setState(() => _error = t.importNothing(read!.format));
      return;
    }
    if (!mounted) return;
    final picked = await Navigator.of(context).push(MaterialPageRoute<List<VaultEntry>>(
      builder: (_) => CopyPage(
        title: '${read!.format} · ${file.name}',
        hint: t.importPickHint,
        entries: read.entries,
        vault: widget.vault,
        leftOut: [
          if (read.unsupported > 0) t.codesLeftOut(read.unsupported),
          if (read.skipped > 0) t.recordsLeftOut(read.skipped),
        ],
        plainFile: _plainFormats.contains(read.format) && !Platform.isAndroid ? file.path : null,
      ),
    ));
    if (picked != null && mounted) Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor);
    return Scaffold(
      appBar: AppBar(title: Text(t.importTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(t.importAnyHint, style: muted),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.folder_open),
              label: Text(t.chooseFile),
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(t.importReading, style: theme.textTheme.bodySmall),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const Divider(height: 40),
          Text(t.importPasswordsFrom, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(t.importPasswordsList, style: muted),
          const SizedBox(height: 16),
          Text(t.importCodesFrom, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(t.importCodesList, style: muted),
          const SizedBox(height: 16),
          Text(t.importNoExport, style: muted),
        ],
      ),
    );
  }
}
