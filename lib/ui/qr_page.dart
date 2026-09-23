import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/models.dart';
import '../core/qr.dart';

/// A scanned account and where it goes: an existing entry or a new one.
class QrImport {
  QrImport(this.code, this.target, {this.suggestions = const []});

  final ScannedCode code;
  VaultEntry? target;
  final List<VaultEntry> suggestions;
}

class QrPage extends StatefulWidget {
  const QrPage({super.key, required this.entries});

  final List<VaultEntry> entries;

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final _found = <QrImport>[];
  String? _message;
  bool _busy = false;

  String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String _siteName(VaultEntry e) {
    var text = e.url.trim().toLowerCase();
    if (!text.contains('://')) text = 'https://$text';
    final parts = (Uri.tryParse(text)?.host ?? '').split('.');
    return parts.length >= 2 ? parts[parts.length - 2] : '';
  }

  /// Entries that look like the same account: same site name as the issuer,
  /// best of all with the same username.
  List<VaultEntry> _suggest(ScannedCode code) {
    final issuer = _norm(code.issuer);
    final account = code.account.toLowerCase();
    if (issuer.isEmpty && account.isEmpty) return const [];

    final scored = <(int, VaultEntry)>[];
    for (final e in widget.entries) {
      var score = 0;
      if (issuer.isNotEmpty &&
          (_siteName(e) == issuer || _norm(e.title).contains(issuer))) {
        score += 2;
      }
      if (account.isNotEmpty && e.username.toLowerCase() == account) score += 1;
      if (score >= 2) scored.add((score, e));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.take(5).map((s) => s.$2).toList();
  }

  void _add(QrResult result) {
    var added = 0;
    for (final code in result.codes) {
      if (_found.any((f) => f.code.secret == code.secret)) continue;
      final suggestions = _suggest(code);
      _found.add(QrImport(code, suggestions.isEmpty ? null : suggestions.first,
          suggestions: suggestions));
      added++;
    }

    final parts = [
      if (result.error != null) result.error!,
      if (result.codes.isNotEmpty) '$added found',
      if (result.unsupported > 0)
        '${result.unsupported} use a code type Keyhold cannot generate yet',
    ];
    setState(() => _message = parts.join(' — '));
  }

  Future<void> _scanScreen() async {
    setState(() => _busy = true);
    await windowManager.hide();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    try {
      _add(await scanScreen());
    } finally {
      await windowManager.show();
      setState(() => _busy = false);
    }
  }

  Future<void> _scanImage() async {
    const type = XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg', 'bmp', 'webp']);
    final file = await openFile(acceptedTypeGroups: const [type]);
    if (file == null) return;
    setState(() => _busy = true);
    try {
      _add(await scanImage(file.path));
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add two-factor codes'),
        actions: [
          if (_found.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_found),
              child: Text('Save ${_found.length}'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Show the QR code on the screen and scan it. It can be the code a website shows '
            'when you turn on two-factor login, or the export from Google Authenticator '
            '(Transfer accounts → Export). A photo of the code works too.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Microsoft Authenticator cannot export its codes — turn two-factor login off and on '
            'again on each site and scan the new code here.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _scanScreen,
                icon: const Icon(Icons.screenshot_monitor_outlined),
                label: const Text('Scan the screen'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _scanImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Open an image'),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, style: theme.textTheme.bodyMedium),
          ],
          if (_found.isNotEmpty) ...[
            const Divider(height: 40),
            ..._found.map(_row),
          ],
        ],
      ),
    );
  }

  Widget _row(QrImport item) {
    final code = item.code;
    final title = code.issuer.isNotEmpty ? code.issuer : code.account;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.pin_outlined),
      title: Text(title),
      subtitle: Text(code.issuer.isNotEmpty ? code.account : ''),
      trailing: SizedBox(
        width: 320,
        child: DropdownButtonFormField<VaultEntry?>(
          initialValue: item.target,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Save to', isDense: true),
          items: [
            const DropdownMenuItem(value: null, child: Text('New entry')),
            for (final e in item.suggestions)
              DropdownMenuItem(
                value: e,
                child: Text(
                  '${e.title} — ${e.username}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => item.target = value),
        ),
      ),
    );
  }
}
