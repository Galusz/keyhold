import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/import_csv.dart';
import '../core/models.dart';
import '../l10n/l10n.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  ImportResult? _result;
  String? _path;
  bool _deleteSource = true;

  Future<void> _pick() async {
    const type = XTypeGroup(label: 'CSV', extensions: ['csv']);
    final file = await openFile(acceptedTypeGroups: const [type]);
    if (file == null) return;

    final text = await File(file.path).readAsString();
    setState(() {
      _path = file.path;
      _result = parseCsv(text);
    });
  }

  Future<void> _finish() async {
    final result = _result;
    if (result == null || result.entries.isEmpty) return;

    if (_deleteSource && _path != null) {
      try {
        File(_path!).deleteSync();
      } catch (_) {
        // the file may be open elsewhere; the import itself already succeeded
      }
    }
    if (mounted) Navigator.of(context).pop(result.entries);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text(t.importPasswords)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            t.importHint,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.folder_open),
            label: Text(t.chooseCsv),
          ),
          if (_path != null) ...[
            const SizedBox(height: 12),
            Text(_path!, style: theme.textTheme.bodySmall),
          ],
          if (result != null) ...[
            const Divider(height: 40),
            if (result.error != null)
              Text(result.error!, style: TextStyle(color: theme.colorScheme.error))
            else ...[
              Text(
                result.skipped > 0
                    ? t.entriesReadySkipped(result.entries.length, result.skipped)
                    : t.entriesReady(result.entries.length),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...result.entries.take(8).map(_preview),
              if (result.entries.length > 8)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(t.andMore(result.entries.length - 8),
                      style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: _deleteSource,
                onChanged: (v) => setState(() => _deleteSource = v ?? true),
                contentPadding: EdgeInsets.zero,
                title: Text(t.deleteCsv),
                subtitle: Text(t.deleteCsvHint),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _finish,
                child: Text(t.importEntries(result.entries.length)),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _preview(VaultEntry e) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.key_outlined, size: 18),
      title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(e.username, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
