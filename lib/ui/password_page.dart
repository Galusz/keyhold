import 'package:flutter/material.dart';

import '../core/storage.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key, required this.store, required this.unlockMode});

  final VaultStore store;
  final bool unlockMode;

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _show = false;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _first.text;

    if (password.isEmpty) {
      setState(() => _error = 'Type your password first');
      return;
    }
    if (!widget.unlockMode) {
      if (password.length < 8) {
        setState(() => _error = 'Use at least 8 characters');
        return;
      }
      if (password != _second.text) {
        setState(() => _error = 'The two passwords differ');
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
          setState(() => _error = 'That password does not open this vault');
          return;
        }
      } else {
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
        title: Text(unlock ? 'Unlock vault' : 'Master password'),
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
                unlock
                    ? 'This vault came from another machine. Type the master password to open it here.'
                    : 'Windows opens this vault for you automatically. The master password is the '
                        'way back in after a reinstall, on a new machine, or on your phone.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _first,
                autofocus: true,
                obscureText: !_show,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: unlock ? 'Master password' : 'New master password',
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
                  decoration: const InputDecoration(
                    labelText: 'Repeat it',
                    border: OutlineInputBorder(),
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
                child: Text(unlock ? 'Open vault' : 'Save password'),
              ),
              if (!unlock) ...[
                const SizedBox(height: 16),
                Text(
                  'Nobody can recover it for you — not even this app. Write it down somewhere safe.',
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
