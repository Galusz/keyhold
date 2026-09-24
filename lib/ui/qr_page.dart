import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/qr.dart';
import 'camera_scan_page.dart';

/// Scans two-factor QR codes. Each code becomes its own entry; it is paired
/// with a site later — on first use, or by giving it the site's address.
class QrPage extends StatefulWidget {
  const QrPage({super.key, required this.known, required this.onSave});

  /// Codes already in the vault by their key, with the entry's name: not
  /// saved twice, and the list says where they already are.
  final Map<String, String> known;

  /// Keeps one code; returns the entry's name for the message.
  final Future<String> Function(ScannedCode code) onSave;

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  final _found = <ScannedCode>[];
  final _saved = <String>{};
  bool _export = false;
  String? _message;
  bool _busy = false;

  bool _known(ScannedCode code) =>
      widget.known.containsKey(code.secret) || _saved.contains(code.secret);

  void _add(QrResult result) {
    _found.clear();
    _export = result.export;
    for (final code in result.codes) {
      if (!_found.any((f) => f.secret == code.secret)) _found.add(code);
    }
    final parts = [
      if (result.error != null) result.error!,
      if (_found.length > 1) '${_found.length} found',
      if (result.unsupported > 0)
        '${result.unsupported} use a code type Keyhold cannot generate yet',
    ];
    setState(() => _message = parts.isEmpty ? null : parts.join(' — '));
  }

  Future<void> _save(ScannedCode code) async {
    final name = await widget.onSave(code);
    setState(() {
      _saved.add(code.secret);
      _message = 'Saved as $name';
    });
  }

  Future<void> _saveAll() async {
    var count = 0;
    for (final code in _found) {
      if (_known(code)) continue;
      await widget.onSave(code);
      _saved.add(code.secret);
      count++;
    }
    setState(() => _message = 'Saved $count ${count == 1 ? 'code' : 'codes'}');
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

  Future<void> _scanCamera() async {
    final text = await Navigator.of(context)
        .push(MaterialPageRoute<String>(builder: (_) => const CameraScanPage()));
    if (text != null) _add(parseOtp(text));
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
          if (_export && _found.any((c) => !_known(c)))
            TextButton(onPressed: _saveAll, child: const Text('Save all')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            Platform.isAndroid
                ? 'Point the camera at the QR code a website shows when you turn on two-factor '
                    'login, or at the export from Google Authenticator (Transfer accounts → Export).'
                : 'Show the QR code on the screen and scan it. It can be the code a website shows '
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
              if (Platform.isAndroid)
                FilledButton.icon(
                  onPressed: _busy ? null : _scanCamera,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan with the camera'),
                )
              else
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

  Widget _row(ScannedCode code) {
    final theme = Theme.of(context);
    final title = code.issuer.isNotEmpty ? code.issuer : code.account;

    Widget line(String label, String value, {TextStyle? style}) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ),
              Expanded(child: Text(value.isEmpty ? '—' : value, style: style)),
            ],
          ),
        );

    final Widget action;
    if (_known(code)) {
      final name = widget.known[code.secret];
      action = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _saved.contains(code.secret) ? 'Saved' : 'Already in Keyhold',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          if (!_saved.contains(code.secret) && name != null)
            Text('as "${name.isEmpty ? '(no name)' : name}"', style: theme.textTheme.bodySmall),
        ],
      );
    } else if (_export) {
      action = const SizedBox.shrink();
    } else {
      action = FilledButton(onPressed: () => _save(code), child: const Text('Save'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.pin_outlined)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line('Title', title, style: theme.textTheme.titleMedium),
                line('Username', code.issuer.isNotEmpty ? code.account : ''),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}
