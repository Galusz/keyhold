import 'dart:io';

import 'package:tray_manager/tray_manager.dart' as tray;

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
          'Open Keyhold', tray.MenuItemType.normal);
      open?.addListener((event) {
        if (event is tray.MenuItemClickedEvent) onShow();
      });

      final separator =
          tray.MenuItem.createWithLabelAndType('', tray.MenuItemType.separator);

      final quit =
          tray.MenuItem.createWithLabelAndType('Quit', tray.MenuItemType.normal);
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
