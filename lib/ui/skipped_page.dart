import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';

/// Sites and apps where the user said "no" to "Save to Keyhold?": Keyhold
/// does not ask there again until one is taken off this list.
class SkippedPage extends StatefulWidget {
  const SkippedPage({super.key});

  @override
  State<SkippedPage> createState() => _SkippedPageState();
}

class _SkippedPageState extends State<SkippedPage> {
  static const _autofill = MethodChannel('keyhold/autofill-settings');

  List<Map<String, String>>? _skipped;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await _autofill.invokeListMethod<Map<dynamic, dynamic>>('skipped') ?? const [];
    if (!mounted) return;
    setState(() => _skipped = [
          for (final m in raw) {'key': '${m['key']}', 'label': '${m['label']}'},
        ]);
  }

  Future<void> _askAgain(Map<String, String> item) async {
    await _autofill.invokeMethod('unskip', item['key']);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final skipped = _skipped;
    return Scaffold(
      appBar: AppBar(title: Text(t.skippedSaves)),
      body: skipped == null
          ? const Center(child: CircularProgressIndicator())
          : skipped.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(t.skippedNone, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(t.skippedSavesHint),
                    ),
                    for (final item in skipped)
                      ListTile(
                        leading: Icon(item['key']!.startsWith('androidapp://') ? Icons.apps : Icons.language),
                        title: Text(item['label']!),
                        trailing: IconButton(
                          tooltip: t.askAgain,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _askAgain(item),
                        ),
                      ),
                  ],
                ),
    );
  }
}
