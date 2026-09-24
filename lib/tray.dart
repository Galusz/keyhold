import 'dart:io';

import 'package:tray_manager/tray_manager.dart' as tray;

import 'l10n/l10n.dart';

class TrayController {
  tray.TrayIcon? _icon;
  final List<tray.MenuItem> _items = [];
  String lastStatus = 'not started';

  String? _iconPath() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final sep = Platform.pathSeparator;
    final candidates = [
      '$exeDir${sep}data${sep}flutter_assets${sep}assets${sep}tray_icon.png',
      '$exeDir${sep}data${sep}flutter_assets${sep}assets${sep}tray_icon.ico',
      'assets${sep}tray_icon.png',
      'assets${sep}tray_icon.ico',
    ];
    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }
    return null;
  }

  /// Whether Windows shows the icon on the taskbar. By default it hides new
  /// icons behind the arrow, and only the user can change that; the choice
  /// is kept per program path under NotifyIconSettings.
  bool get visibleOnTaskbar {
    if (!Platform.isWindows) return true;
    final result = Process.runSync(
        'reg', ['query', r'HKCU\Control Panel\NotifyIconSettings', '/s']);
    if (result.exitCode != 0) return false;
    final exe = Platform.resolvedExecutable.toLowerCase();
    // One block per icon, starting with its key name; values come in any order.
    for (final block in (result.stdout as String).split(RegExp(r'\r?\n(?=HKEY_)'))) {
      String? path;
      var promoted = false;
      for (final line in block.split('\n')) {
        final parts = line.trim().split(RegExp(r'\s{2,}'));
        if (parts.length < 3) continue;
        if (parts[0] == 'ExecutablePath') path = parts[2].toLowerCase();
        if (parts[0] == 'IsPromoted') promoted = parts[2] == '0x1';
      }
      if (path != null && _samePath(path, exe)) return promoted;
    }
    return false;
  }

  // Paths under known folders are stored as "{folder-guid}\rest\app.exe".
  bool _samePath(String stored, String exe) {
    if (stored == exe) return true;
    final close = stored.indexOf('}');
    return stored.startsWith('{') && close > 0 && exe.endsWith(stored.substring(close + 1));
  }

  bool init({required void Function() onShow, required void Function() onQuit}) {
    final icon = tray.TrayIcon.create();
    if (icon == null) {
      lastStatus = 'TrayIcon.create() returned null';
      return false;
    }

    final path = _iconPath();
    if (path == null) {
      lastStatus = 'icon file not found';
    } else {
      final image = tray.Image.fromFile(path);
      if (image == null) {
        lastStatus = 'Image.fromFile failed for $path';
      } else {
        icon.icon = image;
        lastStatus = 'ok $path size=${image.size} format=${image.format}';
      }
    }

    final menu = tray.Menu.create();
    if (menu != null) {
      final open = tray.MenuItem.createWithLabelAndType(
          t.openKeyhold, tray.MenuItemType.normal);
      open?.addListener((event) {
        if (event is tray.MenuItemClickedEvent) onShow();
      });

      final separator =
          tray.MenuItem.createWithLabelAndType('', tray.MenuItemType.separator);

      final quit =
          tray.MenuItem.createWithLabelAndType(t.quit, tray.MenuItemType.normal);
      quit?.addListener((event) {
        if (event is tray.MenuItemClickedEvent) onQuit();
      });

      for (final item in [open, separator, quit]) {
        if (item != null) {
          menu.addItem(item);
          _items.add(item);
        }
      }
      icon.setTooltip('Keyhold');
      icon.setContextMenu(menu);
    } else {
      lastStatus = '$lastStatus / menu create failed';
    }

    icon.addListener((event) {
      if (event is tray.TrayIconClickedEvent) {
        onShow();
      } else if (event is tray.TrayIconRightClickedEvent) {
        icon.openContextMenu();
      }
    });

    final visible = icon.setVisible(true);
    lastStatus = '$lastStatus / setVisible=$visible';
    _icon = icon;
    return true;
  }

  void dispose() {
    _icon?.setVisible(false);
    _icon?.dispose();
    _icon = null;
    _items.clear();
  }
}
