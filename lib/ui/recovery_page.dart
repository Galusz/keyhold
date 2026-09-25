import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/drive.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';

/// The recovery key: shown only after the master password, printed as a
/// sheet with its first two rows, the third copied by hand and then checked.
/// The key alone opens the vault when the master password is forgotten.
class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key, required this.store, this.verified = false});

  final VaultStore store;

  /// The master password was typed a moment ago (it was just set).
  final bool verified;

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  static const _print = MethodChannel('keyhold/print');

  final _password = TextEditingController();
  final _check = TextEditingController();
  String? _code;
  String? _error;
  bool? _matches;
  bool _busy = false;

  VaultStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    if (widget.verified) _reveal();
  }

  @override
  void dispose() {
    _password.dispose();
    _check.dispose();
    super.dispose();
  }

  Future<void> _reveal() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    if (!widget.verified && !await _store.checkPassword(_password.text)) {
      setState(() {
        _busy = false;
        _error = t.wrongMasterPassword;
      });
      return;
    }
    final code = await _store.recoveryCode();
    if (mounted) {
      setState(() {
        _busy = false;
        _code = code;
      });
    }
  }

  /// The code in 3 rows of 3 groups of 4.
  List<List<String>> get _rows => [
        for (var r = 0; r < 3; r++)
          [for (var g = 0; g < 3; g++) _code!.substring(r * 12 + g * 4, r * 12 + g * 4 + 4)],
      ];

  static String _clean(String typed) => typed
      .toUpperCase()
      .replaceAll('0', 'O')
      .replaceAll('1', 'I')
      .replaceAll('8', 'B')
      .replaceAll(RegExp(r'[^A-Z2-7]'), '');

  void _checkRow() => setState(() => _matches = _clean(_check.text) == _code!.substring(24));

  List<String> get _places {
    final backup = _store.backup;
    final drive = DriveSync(_store);
    return [
      if (drive.connected) drive.email.isEmpty ? t.sheetDriveNoEmail : t.sheetDrive(drive.email),
      if (backup.targets.isNotEmpty) t.sheetFolders(backup.targets.join(', ')),
      if (backup.remote.configured) t.sheetServer(backup.remote.host),
      if (!drive.connected && backup.targets.isEmpty && !backup.remote.configured) t.sheetOnlyHere,
    ];
  }

  List<String> get _steps => [t.sheetStep1, t.sheetStep2, t.sheetStep3];

  String _html(String date) {
    final e = const HtmlEscape();
    String cells(String group) => [for (final c in group.split('')) '<span>${e.convert(c)}</span>'].join();
    final printed = _rows.take(2).map((row) => '<div class="row">${row.map((g) => '<div class="g">${cells(g)}</div>').join()}</div>');
    final blank = '<div class="row">${List.filled(3, '<div class="g">${List.filled(4, '<span></span>').join()}</div>').join()}</div>';
    final places = _places.map((p) => '<li>${e.convert(p)}</li>').join();
    final steps = _steps.map((s) => '<li>${e.convert(s)}</li>').join();
    return '''<!doctype html><html lang="${appLocale.languageCode}"><meta charset="utf-8">
<title>${e.convert(t.sheetTitle)}</title>
<style>
body{font:15px/1.5 system-ui,sans-serif;color:#111;max-width:640px;margin:40px auto;padding:0 24px}
h1{font-size:24px;margin:0 0 4px}.date{color:#555;margin:0 0 24px}h2{font-size:16px;margin:24px 0 8px}
.row{display:flex;gap:18px;margin:0 0 10px}.g{display:flex;gap:4px}
.g span{display:inline-block;width:28px;height:38px;border:1.5px solid #111;border-radius:5px;
font:600 22px/38px ui-monospace,Consolas,monospace;text-align:center}
.hint{color:#555;font-size:13px;margin:4px 0 0}.keep{margin-top:28px;padding:12px 14px;background:#f3f3f3;border-radius:8px}
</style>
<h1>${e.convert(t.sheetTitle)}</h1><p class="date">${e.convert(t.sheetMade(date))}</p>
<h2>${e.convert(t.sheetKeyLabel)}</h2>${printed.join()}$blank<p class="hint">${e.convert(t.sheetCopyRow)}</p>
<h2>${e.convert(t.sheetWhere)}</h2><ul>$places</ul>
<h2>${e.convert(t.sheetSteps)}</h2><ol>$steps</ol>
<p class="keep">${e.convert(t.sheetKeepSafe)}</p>
<script>window.onload=()=>window.print()</script></html>''';
  }

  Future<void> _printSheet() async {
    final html = _html(MaterialLocalizations.of(context).formatFullDate(DateTime.now()));
    if (Platform.isAndroid) {
      await _print.invokeMethod('print', {'html': html, 'name': t.sheetTitle});
      return;
    }
    // Windows: the browser prints it, "Save as PDF" included.
    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}keyhold-recovery-sheet.html');
    await file.writeAsString(html);
    await _openInBrowser(Uri.file(file.path).toString());
  }

  /// A .html file may open in an editor; the program that opens web links is a browser.
  static Future<void> _openInBrowser(String url) async {
    try {
      final choice = await Process.run('reg', [
        'query',
        r'HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice',
        '/v',
        'ProgId',
      ]);
      final progId = RegExp(r'ProgId\s+REG_SZ\s+(\S+)').firstMatch('${choice.stdout}')?.group(1);
      if (progId != null) {
        final command = await Process.run('reg', ['query', 'HKCR\\$progId\\shell\\open\\command', '/ve']);
        final line = RegExp(r'REG_SZ\s+(.+)').firstMatch('${command.stdout}')?.group(1)?.trim() ?? '';
        final program = RegExp(r'^"([^"]+)"|^(\S+)').firstMatch(line);
        final exe = program?.group(1) ?? program?.group(2);
        if (exe != null && File(exe).existsSync()) {
          await Process.start(exe, [url]);
          return;
        }
      }
    } catch (_) {
      // no registry answer: Edge comes with every Windows
    }
    await Process.start('cmd', ['/c', 'start', '', 'msedge', url]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.recoverySheet)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: _code == null ? _gate(context) : _key(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _gate(BuildContext context) {
    final theme = Theme.of(context);
    if (!_store.hasPassword) return [Text(t.recoveryNeedsPassword, style: theme.textTheme.bodyMedium)];
    return [
      Icon(Icons.key_outlined, size: 48, color: theme.colorScheme.primary),
      const SizedBox(height: 16),
      Text(t.recoveryGate, style: theme.textTheme.bodyMedium),
      const SizedBox(height: 16),
      TextField(
        controller: _password,
        obscureText: true,
        autofocus: true,
        onSubmitted: (_) => _reveal(),
        decoration: InputDecoration(labelText: t.masterPassword, border: const OutlineInputBorder(), errorText: _error),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton(onPressed: _busy ? null : _reveal, child: Text(t.showKey)),
      ),
      if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
    ];
  }

  List<Widget> _key(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.headlineSmall?.copyWith(fontFamily: 'monospace', letterSpacing: 2);
    final rows = _rows;
    return [
      Text(t.recoveryIntro, style: theme.textTheme.bodyMedium),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, row) in rows.indexed) ...[
                if (i == 2) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.edit_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(t.recoveryCopyRow, style: theme.textTheme.bodySmall)),
                  ]),
                  const SizedBox(height: 4),
                ],
                Text(row.join('  '), style: i == 2 ? mono?.copyWith(color: theme.colorScheme.primary) : mono),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: _printSheet,
            icon: const Icon(Icons.print_outlined),
            label: Text(t.print),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.done)),
        ],
      ),
      const Divider(height: 40),
      Text(t.checkRow, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      TextField(
        controller: _check,
        textCapitalization: TextCapitalization.characters,
        onSubmitted: (_) => _checkRow(),
        onChanged: (_) => setState(() => _matches = null),
        style: const TextStyle(fontFamily: 'monospace', letterSpacing: 2),
        decoration: InputDecoration(border: const OutlineInputBorder(), hintText: 'XXXX XXXX XXXX'),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          OutlinedButton(onPressed: _checkRow, child: Text(t.check)),
          const SizedBox(width: 12),
          if (_matches != null)
            Expanded(
              child: Text(
                _matches! ? t.rowMatches : t.rowDiffers,
                style: TextStyle(color: _matches! ? theme.colorScheme.primary : theme.colorScheme.error),
              ),
            ),
        ],
      ),
    ];
  }
}
