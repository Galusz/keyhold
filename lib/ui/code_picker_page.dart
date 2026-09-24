import 'dart:async';

import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/totp.dart';
import 'entry_page.dart';

/// Picks the two-factor code a login uses. Names can repeat, so each code
/// shows its current six digits too — they can be matched against the site
/// or the phone before choosing.
class CodePickerPage extends StatefulWidget {
  const CodePickerPage({super.key, required this.vault, this.selected = ''});

  final Vault vault;
  final String selected;

  @override
  State<CodePickerPage> createState() => _CodePickerPageState();
}

class _CodePickerPageState extends State<CodePickerPage> {
  final _search = TextEditingController();
  final _codes = <String, String>{};
  int _window = -1;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _refresh();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final window = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    if (window != _window) {
      _window = window;
      for (final e in widget.vault.codes) {
        _codes[e.id] = await totpCode(e.totpSecret!);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _newCode() async {
    final code = VaultEntry(id: UniqueKey().toString());
    final saved = await Navigator.of(context).push(MaterialPageRoute<Object?>(
      builder: (_) => EntryPage(entry: code, isNew: true, vault: widget.vault, code: true),
    ));
    if (saved != true || !mounted) return;
    widget.vault.put(code);
    Navigator.of(context).pop(code.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _search.text.trim().toLowerCase();
    final codes = widget.vault.codes
        .where((e) => query.isEmpty || '${e.title} ${e.url} ${e.notes}'.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Two-factor code')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newCode,
        icon: const Icon(Icons.add),
        label: const Text('New code'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search codes',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final e in codes)
                  ListTile(
                    selected: e.id == widget.selected,
                    leading: const CircleAvatar(child: Icon(Icons.pin_outlined)),
                    title: Text(e.title.isEmpty ? '(no name)' : e.title),
                    subtitle: Text(
                      [
                        hostOf(e.url).isEmpty ? 'not pinned' : 'pinned to ${hostOf(e.url)}',
                        'changed ${DateTime.fromMillisecondsSinceEpoch(e.updatedAt).toIso8601String().substring(0, 10)}',
                      ].join(' · '),
                    ),
                    trailing: Text(
                      _codes[e.id] == null ? '' : '${_codes[e.id]!.substring(0, 3)} ${_codes[e.id]!.substring(3)}',
                      style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'monospace', letterSpacing: 1),
                    ),
                    onTap: () => Navigator.of(context).pop(e.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
