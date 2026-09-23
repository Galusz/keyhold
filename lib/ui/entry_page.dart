import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/totp.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({
    super.key,
    required this.entry,
    required this.isNew,
    this.groups = const [],
  });

  final VaultEntry entry;
  final bool isNew;
  final List<String> groups;

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
  }

  @override
  void dispose() {
    _title.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    _totp.dispose();
    _notes.dispose();
    _group.dispose();
    super.dispose();
  }

  void _save() {
    final e = widget.entry;
    e.title = _title.text.trim();
    e.username = _username.text.trim();
    e.password = _password.text;
    e.url = _url.text.trim();
    e.notes = _notes.text;
    e.group = _group.text.trim();
    e.pending = false;

    final secret = _totp.text.trim();
    e.totpSecret = secret.isEmpty
        ? null
        : (totpSecretFromUri(secret) ?? secret.replaceAll(' ', ''));

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New entry' : 'Edit entry'),
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
        children: [
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
          TextField(
            controller: _totp,
            decoration: const InputDecoration(
              labelText: 'Two-factor secret',
              helperText: 'Paste the setup key or the whole otpauth:// link',
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
              for (final g in widget.groups) DropdownMenuEntry(value: g, label: g),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
        ],
      ),
    );
  }
}
