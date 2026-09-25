import 'package:flutter/material.dart';

import '../core/crypto.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';
import 'recovery_page.dart';

/// After the vault was opened with the recovery key: a new master password,
/// which then reaches the other devices.
Future<void> newPasswordAfterRecovery(BuildContext context, VaultStore store) =>
    Navigator.of(context).push(MaterialPageRoute<bool>(
      builder: (_) => PasswordPage(store: store, unlockMode: false, reset: true),
    ));

class PasswordPage extends StatefulWidget {
  const PasswordPage({
    super.key,
    required this.store,
    required this.unlockMode,
    this.reset = false,
  });

  final VaultStore store;
  final bool unlockMode;

  /// A new master password after the vault was opened with the recovery key:
  /// the forgotten one is not asked for.
  final bool reset;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _current = TextEditingController();
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _show = false;

  @override
  void dispose() {
    _current.dispose();
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _first.text;

    if (password.isEmpty) {
      setState(() => _error = t.typePasswordFirst);
      return;
    }
    if (!widget.unlockMode) {
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
      if (widget.unlockMode) {
        final ok = await widget.store.unlockWithPassword(password);
        if (!ok) {
          setState(() => _error = t.passwordDoesNotOpen);
          return;
        }
        // Opened with the recovery key: the master password was forgotten, a new one comes now.
        if (await readRecoveryCode(password) != null && mounted) await newPasswordAfterRecovery(context, widget.store);
      } else {
        // A change reaches every device, so it takes the password in use now.
        if (!widget.reset && !await widget.store.checkPassword(_current.text)) {
          setState(() => _error = t.currentPasswordWrong);
          return;
        }
        await widget.store.setPassword(password);
        if (!widget.reset && mounted) await _recoverySheet(verified: true);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recoverySheet({bool verified = false}) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => RecoveryPage(store: widget.store, verified: verified)),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlock = widget.unlockMode;

    return PopScope(
      canPop: !unlock && !widget.reset,
      child: Scaffold(
        appBar: AppBar(
          title: Text(unlock ? t.unlockVault : t.masterPassword),
          automaticallyImplyLeading: !unlock && !widget.reset,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(32),
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  unlock
                      ? t.unlockHint
                      : widget.reset
                          ? t.newPasswordAfterKey
                          : t.masterPasswordHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 24),
                if (!unlock && !widget.reset && widget.store.hasPassword) ...[
                  TextField(
                    controller: _current,
                    obscureText: !_show,
                    decoration: InputDecoration(
                      labelText: t.currentMasterPassword,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _first,
                  autofocus: widget.unlockMode,
                  obscureText: !_show,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: unlock ? t.masterPassword : t.newMasterPassword,
                    helperText: unlock ? t.orRecoveryCode : null,
                    helperMaxLines: 2,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _show ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _show = !_show),
                    ),
                  ),
                ),
                if (!unlock) ...[
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
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(unlock ? t.openVault : t.savePassword),
                ),
                if (!unlock) ...[
                  const SizedBox(height: 16),
                  Text(
                    t.nobodyCanRecover,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  if (widget.store.hasPassword && !widget.reset) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _recoverySheet,
                        icon: const Icon(Icons.key_outlined),
                        label: Text(t.printRecoverySheet),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
