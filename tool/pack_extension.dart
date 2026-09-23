import 'dart:convert';
import 'dart:io';

/// Builds the store packages: one for Chrome and Edge, one for Firefox.
/// Each store rejects the background key the other one needs.
void main() {
  final manifest = jsonDecode(File('extension/manifest.json').readAsStringSync())
      as Map<String, dynamic>;
  final version = manifest['version'];
  final out = Directory('build/store')..createSync(recursive: true);

  final chromium = jsonDecode(jsonEncode(manifest)) as Map<String, dynamic>;
  (chromium['background'] as Map).remove('scripts');
  chromium.remove('browser_specific_settings');

  final firefox = jsonDecode(jsonEncode(manifest)) as Map<String, dynamic>;
  (firefox['background'] as Map).remove('service_worker');

  for (final (name, content) in [('chromium', chromium), ('firefox', firefox)]) {
    final stage = Directory('${out.path}/$name');
    if (stage.existsSync()) stage.deleteSync(recursive: true);
    _copy(Directory('extension'), stage);
    File('${stage.path}/manifest.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(content));

    final zip = File('${out.path}/keyhold-extension-$name-$version.zip');
    if (zip.existsSync()) zip.deleteSync();
    // Windows' own tar writes zip files; the one from Git reads "E:" as a host name.
    final entries = stage.listSync().map((e) => e.uri.pathSegments.lastWhere((s) => s.isNotEmpty));
    final result = Process.runSync(
        r'C:\Windows\System32\tar.exe', ['-a', '-c', '-f', zip.absolute.path, ...entries],
        workingDirectory: stage.path);
    if (result.exitCode != 0) throw StateError(result.stderr.toString());
    stdout.writeln(zip.path);
  }
}

void _copy(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entity in from.listSync()) {
    final name = entity.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (entity is Directory) {
      _copy(entity, Directory('${to.path}/$name'));
    } else if (entity is File) {
      entity.copySync('${to.path}/$name');
    }
  }
}
