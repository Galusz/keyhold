import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';

class ExtensionPage extends StatelessWidget {
  const ExtensionPage({
    super.key,
    required this.token,
    required this.running,
    required this.extensionPath,
  });

  final String token;
  final bool running;
  final String extensionPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.browserExtension)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(
                running ? Icons.check_circle_outline : Icons.error_outline,
                size: 18,
                color: running ? theme.colorScheme.primary : theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                running ? t.listening('127.0.0.1:19919') : t.notListening,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: running ? theme.colorScheme.primary : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(t.pairingToken, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            t.pairingTokenHint,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              token,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(
                  content: Text(t.tokenCopied),
                  duration: const Duration(seconds: 2),
                ));
            },
            icon: const Icon(Icons.copy_outlined),
            label: Text(t.copyToken),
          ),
          const Divider(height: 48),
          Text(t.installIt, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _step(theme, '1', t.installChrome),
          _step(theme, '2', t.installFirefox),
          _step(theme, '3', t.installPaste),
          const SizedBox(height: 16),
          SelectableText(
            extensionPath,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _step(ThemeData theme, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(number, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
