import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'core/autotype.dart';
import 'tray.dart';
import 'ui/autofill_page.dart';
import 'ui/mobile_page.dart';
import 'ui/vault_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    runApp(const KeyholdApp(home: MobilePage()));
    return;
  }

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(980, 720),
      minimumSize: Size(720, 520),
      title: 'Keyhold',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
  await windowManager.setPreventClose(true);
  await hotKeyManager.unregisterAll();

  runApp(const KeyholdApp(home: TrayShell(child: VaultPage())));
}

/// Started by Android behind the "Keyhold" suggestion under a login field.
@pragma('vm:entry-point')
Future<void> autofillMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KeyholdApp(home: AutofillPage()));
}

/// Started without a screen by Android's autofill service, to find the logins
/// it shows right under a field.
@pragma('vm:entry-point')
Future<void> autofillLookupMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await serveAutofillLookups();
}

class KeyholdApp extends StatelessWidget {
  const KeyholdApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keyhold',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1FCFB4),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1FCFB4),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: home,
    );
  }
}

class TrayShell extends StatefulWidget {
  const TrayShell({super.key, required this.child});

  final Widget child;

  @override
  State<TrayShell> createState() => _TrayShellState();
}

class _TrayShellState extends State<TrayShell> with WindowListener {
  final _tray = TrayController();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    final started = _tray.init(onShow: _restore, onQuit: _quit);
    _log('tray started=$started status=${_tray.lastStatus}');
    _registerHotkey();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _tray.dispose();
    super.dispose();
  }

  Future<void> _registerHotkey() async {
    try {
      await hotKeyManager.register(
        HotKey(
          key: PhysicalKeyboardKey.keyK,
          modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
          scope: HotKeyScope.system,
        ),
        keyDownHandler: (_) async {
          AutoTypeTarget.remember();
          await _restore();
        },
      );
      await _log('hotkey registered');
    } catch (e) {
      await _log('hotkey FAILED: $e');
    }
  }

  Future<void> _log(String line) async {
    final dir = await getApplicationSupportDirectory();
    final file = File(
      '${dir.path}${Platform.pathSeparator}keyhold${Platform.pathSeparator}hotkey.log',
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('${DateTime.now()}  $line\n', mode: FileMode.append);
  }

  Future<void> _restore() async {
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _quit() async {
    _tray.dispose();
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  // Hiding the window is only safe when the tray icon can be seen; otherwise
  // the program would seem to vanish, so it stays on the taskbar.
  @override
  void onWindowClose() {
    if (_tray.visibleOnTaskbar) {
      windowManager.hide();
    } else {
      windowManager.minimize();
    }
  }

  @override
  void onWindowMinimize() {
    if (_tray.visibleOnTaskbar) windowManager.hide();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
