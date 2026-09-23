import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/import_csv.dart';
import '../core/models.dart';

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
      appBar: AppBar(title: const Text('Import passwords')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Export your passwords from the browser as CSV, then load the file here. '
            'Chrome, Edge, Firefox, Bitwarden and KeePassXC exports all work.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.folder_open),
            label: const Text('Choose CSV file'),
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
                '${result.entries.length} entries ready'
                '${result.skipped > 0 ? ', ${result.skipped} empty rows skipped' : ''}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...result.entries.take(8).map(_preview),
              if (result.entries.length > 8)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('and ${result.entries.length - 8} more',
                      style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: _deleteSource,
                onChanged: (v) => setState(() => _deleteSource = v ?? true),
                contentPadding: EdgeInsets.zero,
                title: const Text('Delete the CSV file after importing'),
                subtitle: const Text('It holds every password in plain text'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _finish,
                child: Text('Import ${result.entries.length} entries'),
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
