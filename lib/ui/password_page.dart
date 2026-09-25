import 'package:flutter/material.dart';

import '../core/crypto.dart';
import '../core/drive.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';
import 'recovery_page.dart';
import 'start_page.dart';

/// After the vault was opened with the recovery key: a new master password,
/// which then reaches the other devices.
Future<void> newPasswordAfterRecovery(BuildContext context, VaultStore store) =>
    Navigator.of(context).push(MaterialPageRoute<bool>(
      builder: (_) => PasswordPage(store: store, mode: PasswordMode.reset),
    ));

enum PasswordMode {
  /// A new, empty vault with its master password.
  create,

  /// The open vault has no master password yet (made before one was required).
  seal,

  /// A new master password after the recovery key opened the vault.
  reset,

  /// The master password, or the recovery key, opens a vault.
  unlock,
}

/// Tries what was typed; null when it opened, otherwise what to tell the user.
/// [status] shows progress while it runs.
typedef Attempt = Future<String?> Function(String typed, void Function(String) status);

class PasswordPage extends StatefulWidget {
  const PasswordPage({
    super.key,
    required this.store,
    required this.mode,
    this.title,
    this.hint,
    this.attempt,
    this.drive,
  });

  final VaultStore store;
  final PasswordMode mode;

  /// At start, for a vault this device cannot open by itself: with it,
  /// another vault can be opened or a new one made instead.
  final DriveSync? drive;

  /// For [PasswordMode.unlock]: what is being opened, and how.
  final String? title;
  final String? hint;
  final Attempt? attempt;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _name = TextEditingController(text: t.myVault);
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;
  String? _status;
  bool _busy = false;
  bool _show = false;

  /// Unlocking with the recovery key instead of the forgotten password.
  bool _byKey = false;

  PasswordMode get _mode => widget.mode;
  bool get _unlock => _mode == PasswordMode.unlock;
  bool get _named => _mode == PasswordMode.create || _mode == PasswordMode.seal;

  @override
  void dispose() {
    _name.dispose();
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  Future<String?> _unlockHere(String typed, void Function(String) status) async =>
      await widget.store.unlockWithPassword(typed) ? null : t.passwordDoesNotOpen;

  Future<void> _submit() async {
    final password = _first.text;

    if (password.isEmpty) {
      setState(() => _error = t.typePasswordFirst);
      return;
    }
    if (!_unlock) {
      if (password.length < 8) {
        setState(() => _error = t.atLeast8);
        return;
      }
      if (password != _second.text) {
        setState(() => _error = t.passwordsDiffer);
        return;
      }
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      switch (_mode) {
        case PasswordMode.unlock:
          final problem = await (widget.attempt ?? _unlockHere)(password, (s) {
            if (mounted) setState(() => _status = s);
          });
          if (problem != null) {
            setState(() => _error = problem);
            return;
          }
          // Opened with the recovery key: the master password was forgotten, a new one comes now.
          if (await readRecoveryCode(password) != null && mounted) await newPasswordAfterRecovery(context, widget.store);
        case PasswordMode.create:
          await widget.store.createVault(_name.text.trim(), password);
          if (mounted) await _recoverySheet();
        case PasswordMode.seal:
          await widget.store.setPassword(password, name: _name.text.trim());
          if (mounted) await _recoverySheet();
        case PasswordMode.reset:
          await widget.store.setPassword(password);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    }
  }

  /// A vault that does not open here need not hold Keyhold up: it is set
  /// aside, not deleted, and another one opens or a new one starts.
  Future<void> _instead(Widget page) async {
    final done = await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => page));
    if (done == true && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _recoverySheet() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoveryPage(store: widget.store, verified: true)),
      );

  String get _title => switch (_mode) {
        PasswordMode.unlock => widget.title ?? t.unlockVault,
        PasswordMode.create => t.newVault,
        PasswordMode.seal || PasswordMode.reset => t.masterPassword,
      };

  String get _hint => switch (_mode) {
        PasswordMode.unlock => widget.hint ?? t.unlockHint,
        PasswordMode.create => t.newVaultHint,
        PasswordMode.seal => t.sealHint,
        PasswordMode.reset => t.newPasswordAfterKey,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A vault must not stay without its master password, nor forget a reset.
    final canLeave = _mode == PasswordMode.create || (_unlock && widget.attempt != null);

    return PopScope(
      canPop: canLeave && !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title),
          automaticallyImplyLeading: canLeave,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(32),
              children: [
                Icon(
                  _byKey ? Icons.key_outlined : Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _hint,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 24),
                if (_named) ...[
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: t.vaultName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _first,
                  autofocus: _unlock,
                  obscureText: !_show && !_byKey,
                  onSubmitted: (_) => _submit(),
                  textCapitalization: _byKey ? TextCapitalization.characters : TextCapitalization.none,
                  style: _byKey ? const TextStyle(fontFamily: 'monospace', letterSpacing: 2) : null,
                  decoration: InputDecoration(
                    labelText: _byKey
                        ? t.recoveryKey
                        : _mode == PasswordMode.reset
                            ? t.newMasterPassword
                            : t.masterPassword,
                    helperText: _byKey ? t.recoveryKeyFieldHint : null,
                    helperMaxLines: 2,
                    border: const OutlineInputBorder(),
                    suffixIcon: _byKey
                        ? null
                        : IconButton(
                            icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _show = !_show),
                          ),
                  ),
                ),
                if (!_unlock) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _second,
                    obscureText: !_show,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: t.repeatIt,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(switch (_mode) {
                    PasswordMode.unlock => t.openVault,
                    PasswordMode.create => t.createVaultButton,
                    PasswordMode.seal || PasswordMode.reset => t.savePassword,
                  }),
                ),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  if (_status != null) ...[
                    const SizedBox(height: 8),
                    Text(_status!, style: theme.textTheme.bodySmall),
                  ],
                ],
                if (_unlock) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _byKey = !_byKey;
                        _first.clear();
                        _error = null;
                      }),
                      child: Text(_byKey ? t.usePassword : t.forgotPassword),
                    ),
                  ),
                  if (widget.drive != null) ...[
                    const Divider(height: 32),
                    Text(
                      t.lockedInstead,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _instead(OpenVaultPage(store: widget.store, drive: widget.drive!)),
                          icon: const Icon(Icons.folder_open_outlined),
                          label: Text(t.openOtherVault),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _instead(PasswordPage(store: widget.store, mode: PasswordMode.create)),
                          icon: const Icon(Icons.add),
                          label: Text(t.createVault),
                        ),
                      ],
                    ),
                  ],
                ] else if (_mode != PasswordMode.reset) ...[
                  const SizedBox(height: 16),
                  Text(
                    t.nobodyCanRecover,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
