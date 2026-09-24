import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/qr.dart';
import '../l10n/l10n.dart';
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
      if (_found.length > 1) t.codesFound(_found.length),
      if (result.unsupported > 0) t.codesUnsupported(result.unsupported),
    ];
    setState(() => _message = parts.isEmpty ? null : parts.join(' — '));
  }

  Future<void> _save(ScannedCode code) async {
    final name = await widget.onSave(code);
    setState(() {
      _saved.add(code.secret);
      _message = t.savedAs(name);
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
    setState(() => _message = t.savedCodes(count));
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
    final type = XTypeGroup(label: t.images, extensions: const ['png', 'jpg', 'jpeg', 'bmp', 'webp']);
    final file = await openFile(acceptedTypeGroups: [type]);
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
        title: Text(t.addCodes),
        actions: [
          if (_export && _found.any((c) => !_known(c)))
            TextButton(onPressed: _saveAll, child: Text(t.saveAll)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            Platform.isAndroid ? t.qrHintPhone : t.qrHintComputer,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          Text(
            t.qrMicrosoftHint,
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
                  label: Text(t.scanCamera),
                )
              else
                FilledButton.icon(
                  onPressed: _busy ? null : _scanScreen,
                  icon: const Icon(Icons.screenshot_monitor_outlined),
                  label: Text(t.scanScreen),
                ),
              OutlinedButton.icon(
                onPressed: _busy ? null : _scanImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(t.openImage),
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
            _saved.contains(code.secret) ? t.saved : t.alreadyInKeyhold,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          if (!_saved.contains(code.secret) && name != null)
            Text(t.asName(name.isEmpty ? t.noName : name), style: theme.textTheme.bodySmall),
        ],
      );
    } else if (_export) {
      action = const SizedBox.shrink();
    } else {
      action = FilledButton(onPressed: () => _save(code), child: Text(t.save));
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
                line(t.title, title, style: theme.textTheme.titleMedium),
                line(t.username, code.issuer.isNotEmpty ? code.account : ''),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}
