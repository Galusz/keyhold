import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/totp.dart';
import '../l10n/l10n.dart';
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
  late bool _guarded = widget.entry.guarded;

  /// The login's two-factor code, by id.
  late String _twoFactor;
  String? _linkedCode;
  Timer? _ticker;

  /// A code's own addresses, and the logins to let go of on save.
  late final List<String> _sites;
  final _unpinned = <String>{};
  final _newSite = TextEditingController();

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
    _sites = [...e.sites];
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
    _newSite.dispose();
    super.dispose();
  }

  void _addSite() {
    final site = _newSite.text.trim();
    if (site.isEmpty) return;
    setState(() {
      if (!_sites.contains(site)) _sites.add(site);
      _newSite.clear();
    });
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

  /// Deleting reaches every device, and a two-factor code gone is a sign-in gone: asked first.
  Future<void> _delete() async {
    final e = widget.entry;
    final name = e.title.trim();
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name.isNotEmpty ? t.deleteNamed(name) : _isCode ? t.deleteThisCode : t.deleteThisLogin),
        content: Text(_isCode ? t.deleteCodeWarning : t.deleteLoginWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.delete)),
        ],
      ),
    );
    if (sure == true && mounted) Navigator.of(context).pop('delete');
  }

  /// Whether anything on the screen differs from the entry as it came.
  bool get _changed {
    final e = widget.entry;
    if (_title.text.trim() != e.title || _notes.text != e.notes || _guarded != e.guarded) return true;
    if (_isCode) {
      return _totp.text.trim() != (e.totpSecret ?? '') ||
          _newSite.text.trim().isNotEmpty ||
          !listEquals(_sites, e.sites) ||
          _unpinned.isNotEmpty;
    }
    return _username.text.trim() != e.username ||
        _password.text != e.password ||
        _url.text.trim() != e.url ||
        _group.text.trim() != e.group ||
        _twoFactor != e.twoFactor;
  }

  /// Back with changes on the screen asks first: they are easy to forget.
  Future<void> _leave() async {
    if (!_changed) {
      Navigator.of(context).pop();
      return;
    }
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.saveChanges),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, 'discard'), child: Text(t.dontSave)),
          FilledButton(onPressed: () => Navigator.pop(context, 'save'), child: Text(t.save)),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'save') _save();
    if (choice == 'discard') Navigator.of(context).pop();
  }

  void _save() {
    final e = widget.entry;
    e.title = _title.text.trim();
    e.notes = _notes.text;
    e.guarded = _guarded;

    if (_isCode) {
      _addSite();
      final raw = _totp.text.trim();
      final secret = totpSecretFromUri(raw) ?? raw.replaceAll(' ', '');
      if (secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.enterCodeKey)),
        );
        return;
      }
      e.totpSecret = secret;
      e.username = '';
      e.password = '';
      e.url = '';
      e.sites = _sites;
      for (final login in widget.vault.loginsOf(e)) {
        if (!_unpinned.contains(login.id)) continue;
        login.twoFactor = '';
        widget.vault.put(login);
      }
    } else {
      e.url = _url.text.trim();
      e.username = _username.text.trim();
      e.password = _password.text;
      e.group = _group.text.trim();
      e.twoFactor = _twoFactor;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final String heading;
    if (_isCode) {
      heading = widget.isNew ? t.newCode : t.twoFactorCode;
    } else {
      heading = widget.isNew ? t.newEntryTitle : t.editEntry;
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(heading),
          actions: [
            if (!widget.isNew)
              IconButton(
                tooltip: t.delete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
            TextButton(onPressed: _save, child: Text(t.save)),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: _isCode ? _codeFields() : _loginFields(),
        ),
      ),
    );
  }

  List<Widget> _codeFields() {
    final logins = widget.vault.loginsOf(widget.entry);
    return [
      TextField(
        controller: _title,
        autofocus: widget.isNew,
        decoration: InputDecoration(labelText: t.name),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _totp,
        obscureText: !_showKey,
        decoration: InputDecoration(
          labelText: t.key,
          helperText: t.keyHint,
          suffixIcon: IconButton(
            icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showKey = !_showKey),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _guardSwitch(),
      const SizedBox(height: 8),
      TextField(
        controller: _notes,
        maxLines: 3,
        decoration: InputDecoration(labelText: t.note),
      ),
      const SizedBox(height: 24),
      Text(t.addresses, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 4),
      if (logins.every((l) => _unpinned.contains(l.id)) && _sites.isEmpty)
        Text(
          t.codeNotUsedYet,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      // From logins pinned to this code: let go here or on the login.
      for (final l in logins)
        if (!_unpinned.contains(l.id))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.push_pin_outlined),
            title: Text('${l.title.isEmpty ? t.noTitle : l.title} — ${l.username}'),
            subtitle: Text(l.url.isEmpty ? t.noAddress : l.url),
            trailing: IconButton(
              tooltip: t.unpin,
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _unpinned.add(l.id)),
            ),
          ),
      // Added by hand: stay with the code only.
      for (final site in _sites)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.language),
          title: Text(site),
          trailing: IconButton(
            tooltip: t.remove,
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _sites.remove(site)),
          ),
        ),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newSite,
              decoration: InputDecoration(hintText: t.addAddress),
              onSubmitted: (_) => _addSite(),
            ),
          ),
          IconButton(tooltip: t.add, icon: const Icon(Icons.add), onPressed: _addSite),
        ],
      ),
    ];
  }

  Widget _guardSwitch() => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.fingerprint),
        value: _guarded,
        onChanged: (on) => setState(() => _guarded = on),
        title: Text(t.guardedSwitch),
        subtitle: Text(t.guardedSwitchHint),
      );

  List<Widget> _loginFields() {
    final code = widget.vault.entries[_twoFactor];
    final linked = code != null && !code.deleted;
    return [
      TextField(
        controller: _title,
        autofocus: widget.isNew,
        decoration: InputDecoration(labelText: t.title),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _username,
        decoration: InputDecoration(labelText: t.username),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _password,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          labelText: t.password,
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _guardSwitch(),
      const SizedBox(height: 8),
      TextField(
        controller: _url,
        decoration: InputDecoration(labelText: t.address),
      ),
      const SizedBox(height: 16),
      InputDecorator(
        decoration: InputDecoration(labelText: t.filter2fa),
        child: Row(
          children: [
            Expanded(
              child: Text(
                linked
                    ? '${code.title.isEmpty ? t.noName : code.title}'
                        '${_linkedCode == null ? '' : '  ·  ${_linkedCode!.substring(0, 3)} ${_linkedCode!.substring(3)}'}'
                    : t.none,
              ),
            ),
            TextButton(onPressed: _pickCode, child: Text(linked ? t.change : t.choose)),
            if (linked)
              TextButton(
                onPressed: () => setState(() {
                  _twoFactor = '';
                  _linkedCode = null;
                }),
                child: Text(t.remove),
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
        label: Text(t.group),
        helperText: t.groupHint,
        dropdownMenuEntries: [
          for (final g in widget.vault.groups) DropdownMenuEntry(value: g, label: g),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _notes,
        maxLines: 5,
        decoration: InputDecoration(labelText: t.notes),
      ),
    ];
  }
}
