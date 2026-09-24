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

  /// Only codes not used anywhere yet, or all of them.
  bool _freeOnly = true;
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
    final saved = await Navigator.of(context).push(
      MaterialPageRoute<Object?>(
        builder: (_) => EntryPage(
          entry: code,
          isNew: true,
          vault: widget.vault,
          code: true,
        ),
      ),
    );
    if (saved != true || !mounted) return;
    widget.vault.put(code);
    Navigator.of(context).pop(code.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const pinnedColor = Color(0xFFF29A2E);
    final query = _search.text.trim().toLowerCase();
    final codes = widget.vault.codes.where((e) {
      final sites = widget.vault.sitesOf(e);
      if (_freeOnly && sites.isNotEmpty && e.id != widget.selected) {
        return false;
      }
      return query.isEmpty ||
          '${e.title} ${sites.join(' ')} ${e.notes}'.toLowerCase().contains(
            query,
          );
    }).toList();

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Free')),
                ButtonSegment(value: false, label: Text('All')),
              ],
              selected: {_freeOnly},
              onSelectionChanged: (v) => setState(() => _freeOnly = v.first),
            ),
          ),
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
                if (codes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _freeOnly
                          ? 'Every code is pinned somewhere. Switch to All to see them.'
                          : 'No codes found.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final e in codes)
                  Builder(
                    builder: (context) {
                      // Already used elsewhere: orange, with where.
                      final hosts = {
                        for (final s in widget.vault.sitesOf(e)) hostOf(s),
                      }.where((h) => h.isNotEmpty);
                      final pinned = hosts.isNotEmpty;
                      return ListTile(
                        selected: e.id == widget.selected,
                        leading: CircleAvatar(
                          child: Icon(
                            Icons.pin_outlined,
                            color: pinned ? pinnedColor : null,
                          ),
                        ),
                        title: Text(
                          e.title.isEmpty ? '(no name)' : e.title,
                          style: pinned
                              ? const TextStyle(color: pinnedColor)
                              : null,
                        ),
                        subtitle: Text(
                          [
                            pinned
                                ? 'pinned to ${hosts.join(', ')}'
                                : 'not pinned',
                            'changed ${DateTime.fromMillisecondsSinceEpoch(e.updatedAt).toIso8601String().substring(0, 10)}',
                          ].join(' · '),
                        ),
                        trailing: Text(
                          _codes[e.id] == null
                              ? ''
                              : '${_codes[e.id]!.substring(0, 3)} ${_codes[e.id]!.substring(3)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            letterSpacing: 1,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(e.id),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
