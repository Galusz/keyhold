import 'package:flutter/material.dart';

/// "Ask for a fingerprint when filling in": the heading on a line of its own,
/// under it the fingerprint, the explanation and the switch, the switch level
/// with the explanation.
class GuardSwitch extends StatelessWidget {
  const GuardSwitch({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final String title;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.fingerprint, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(hint, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
                const SizedBox(width: 12),
                Switch(value: value, onChanged: onChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
