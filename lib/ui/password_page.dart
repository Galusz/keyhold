import 'package:flutter/material.dart';

import '../core/storage.dart';
import '../l10n/l10n.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key, required this.store, required this.unlockMode});

  final VaultStore store;
  final bool unlockMode;

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
      } else {
        // A change reaches every device, so it takes the password in use now.
        if (!await widget.store.checkPassword(_current.text)) {
          setState(() => _error = t.currentPasswordWrong);
          return;
        }
        await widget.store.setPassword(password);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlock = widget.unlockMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(unlock ? t.unlockVault : t.masterPassword),
        automaticallyImplyLeading: !unlock,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(32),
            children: [
              Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                unlock ? t.unlockHint : t.masterPasswordHint,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),
              if (!unlock && widget.store.hasPassword) ...[
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
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
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
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
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
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
