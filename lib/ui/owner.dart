import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

import '../core/models.dart';
import '../core/storage.dart';
import '../l10n/l10n.dart';

/// The owner shows it is them: on the phone by finger (or the phone's PIN or
/// pattern), on the computer by Windows Hello. A device with neither set up
/// asks for the vault's password instead, so no one is ever locked out.
/// [beforePassword] runs before that question, to bring the window up.
Future<bool> confirmOwner(
  BuildContext context,
  VaultStore store, {
  String? hint,
  Future<void> Function()? beforePassword,
}) async {
  final reason = hint ?? t.fingerprintUnlockHint;
  final byDevice = Platform.isWindows ? await _hello(reason) : await _finger(reason);
  if (byDevice != null) return byDevice;
  await beforePassword?.call();
  if (!context.mounted) return false;
  return await showDialog<bool>(
        context: context,
        builder: (_) => _PasswordCheck(store: store, hint: reason),
      ) ??
      false;
}

/// The phone's panel: null when the phone has no screen lock to ask with.
Future<bool?> _finger(String hint) async {
  try {
    return await const MethodChannel('keyhold/fingerprint')
        .invokeMethod<bool>('ask', {'title': t.fingerprintTitle, 'hint': hint});
  } catch (_) {
    return false;
  }
}

/// Windows Hello: null when it is not set up on this computer.
Future<bool?> _hello(String reason) async {
  final hello = LocalAuthPlatform.instance;
  try {
    if (!await hello.isDeviceSupported()) return null;
    return await hello.authenticate(localizedReason: reason, authMessages: const []);
  } catch (_) {
    return null;
  }
}

class _PasswordCheck extends StatefulWidget {
  const _PasswordCheck({required this.store, required this.hint});

  final VaultStore store;
  final String hint;

  @override
  State<_PasswordCheck> createState() => _PasswordCheckState();
}

class _PasswordCheckState extends State<_PasswordCheck> {
  final _field = TextEditingController();
  bool _wrong = false;
  bool _busy = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_busy || _field.text.isEmpty) return;
    setState(() => _busy = true);
    final ok = await widget.store.checkPassword(_field.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _busy = false;
      _wrong = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.hint),
      content: TextField(
        controller: _field,
        autofocus: true,
        obscureText: true,
        enabled: !_busy,
        onSubmitted: (_) => _check(),
        decoration: InputDecoration(
          labelText: t.masterPassword,
          errorText: _wrong ? t.wrongMasterPassword : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
        FilledButton(onPressed: _busy ? null : _check, child: Text(t.unlock)),
      ],
    );
  }
}

/// An entry's avatar with a small fingerprint in its corner: lit when the
/// entry asks for the owner before it is filled in, tapped to change that.
class GuardedAvatar extends StatelessWidget {
  const GuardedAvatar({super.key, required this.avatar, required this.on, required this.onTap});

  final Widget avatar;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -4,
          bottom: -4,
          child: Tooltip(
            message: t.guardedSwitch,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? scheme.primary : scheme.surface,
                  border: Border.all(color: on ? scheme.surface : scheme.outlineVariant, width: 1.5),
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 13,
                  color: on ? scheme.onPrimary : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Marking an entry is free; taking the mark off needs the owner.
Future<bool> toggleGuard(BuildContext context, VaultStore store, VaultEntry e) async {
  if (e.guarded &&
      !await confirmOwner(context, store, hint: Platform.isWindows ? t.helloConfirmHint : t.fingerprintConfirmHint)) {
    return false;
  }
  e.guarded = !e.guarded;
  return true;
}
