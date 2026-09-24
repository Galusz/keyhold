import 'dart:async';

import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/totp.dart';
import 'code_picker_page.dart';

/// Edits a login, or a two-factor code of its own: name, key, note, address.
class EntryPage extends StatefulWidget {
  const EntryPage({
    super.key,
    required this.entry,
    required this.isNew,
    required this.vault,
    this.code = false,
  });

  final VaultEntry entry;
  final bool isNew;
  final Vault vault;

  /// A new two-factor code rather than a login.
  final bool code;

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late final TextEditingController _title;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _url;
  late final TextEditingController _totp;
  late final TextEditingController _notes;
  late final TextEditingController _group;
  bool _showPassword = false;
  bool _showKey = false;

  /// The login's two-factor code, by id.
  late String _twoFactor;
  String? _linkedCode;
  Timer? _ticker;

  bool get _isCode => widget.code || widget.entry.isCode;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _title = TextEditingController(text: e.title);
    _username = TextEditingController(text: e.username);
    _password = TextEditingController(text: e.password);
    _url = TextEditingController(text: e.url);
    _totp = TextEditingController(text: e.totpSecret ?? '');
    _notes = TextEditingController(text: e.notes);
    _group = TextEditingController(text: e.group);
    _twoFactor = e.twoFactor;
    if (!_isCode) {
      _showLinkedCode();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _showLinkedCode());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _title.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    _totp.dispose();
    _notes.dispose();
    _group.dispose();
    super.dispose();
  }

  Future<void> _showLinkedCode() async {
    final code = widget.vault.entries[_twoFactor];
    final secret = code == null || code.deleted ? null : code.totpSecret;
    final value = secret == null || secret.isEmpty ? null : await totpCode(secret);
    if (mounted && value != _linkedCode) setState(() => _linkedCode = value);
  }

  Future<void> _pickCode() async {
    final id = await Navigator.of(context).push(MaterialPageRoute<String>(
      builder: (_) => CodePickerPage(vault: widget.vault, selected: _twoFactor),
    ));
    if (id == null) return;
    setState(() => _twoFactor = id);
    _showLinkedCode();
  }

  void _save() {
    final e = widget.entry;
    e.title = _title.text.trim();
    e.url = _url.text.trim();
    e.notes = _notes.text;

    if (_isCode) {
      final raw = _totp.text.trim();
      final secret = totpSecretFromUri(raw) ?? raw.replaceAll(' ', '');
      if (secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the key of the two-factor code')),
        );
        return;
      }
      e.totpSecret = secret;
      e.username = '';
      e.password = '';
    } else {
      e.username = _username.text.trim();
      e.password = _password.text;
      e.group = _group.text.trim();
      widget.vault.setCode(e, _twoFactor);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final String heading;
    if (_isCode) {
      heading = widget.isNew ? 'New two-factor code' : 'Two-factor code';
    } else {
      heading = widget.isNew ? 'New entry' : 'Edit entry';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(heading),
        actions: [
          if (!widget.isNew)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => Navigator.of(context).pop('delete'),
            ),
          TextButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: _isCode ? _codeFields() : _loginFields(),
      ),
    );
  }

  List<Widget> _codeFields() {
    final logins = widget.vault.loginsOf(widget.entry);
    return [
      TextField(
        controller: _title,
        autofocus: widget.isNew,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _totp,
        obscureText: !_showKey,
        decoration: InputDecoration(
          labelText: 'Key',
          helperText: 'Paste the setup key or the whole otpauth:// link',
          suffixIcon: IconButton(
            icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showKey = !_showKey),
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _notes,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Note'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _url,
        decoration: const InputDecoration(
          labelText: 'Address',
          helperText: 'The site it is used on. Fills itself when you pin it to a login or use it on a site.',
        ),
      ),
      if (logins.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('Pinned to', style: Theme.of(context).textTheme.bodySmall),
        for (final l in logins)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.key_outlined),
            title: Text(l.title.isEmpty ? '(no title)' : l.title),
            subtitle: Text(l.username),
          ),
      ],
    ];
  }

  List<Widget> _loginFields() {
    final code = widget.vault.entries[_twoFactor];
    final linked = code != null && !code.deleted;
    return [
      TextField(
        controller: _title,
        autofocus: widget.isNew,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _username,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _password,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _url,
        decoration: const InputDecoration(labelText: 'Address'),
      ),
      const SizedBox(height: 16),
      InputDecorator(
        decoration: const InputDecoration(labelText: '2FA'),
        child: Row(
          children: [
            Expanded(
              child: Text(
                linked
                    ? '${code.title.isEmpty ? '(no name)' : code.title}'
                        '${_linkedCode == null ? '' : '  ·  ${_linkedCode!.substring(0, 3)} ${_linkedCode!.substring(3)}'}'
                    : 'None',
              ),
            ),
            TextButton(onPressed: _pickCode, child: Text(linked ? 'Change' : 'Choose')),
            if (linked)
              TextButton(
                onPressed: () => setState(() {
                  _twoFactor = '';
                  _linkedCode = null;
                }),
                child: const Text('Remove'),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      DropdownMenu<String>(
        controller: _group,
        requestFocusOnTap: true,
        enableFilter: true,
        expandedInsets: EdgeInsets.zero,
        label: const Text('Group'),
        helperText: 'Pick one or type a new name',
        dropdownMenuEntries: [
          for (final g in widget.vault.groups) DropdownMenuEntry(value: g, label: g),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _notes,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'Notes'),
      ),
    ];
  }
}
