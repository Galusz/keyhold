import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const bg = 0xFF1B2A26;
const accent = 0xFF1FCFB4;

img.ColorRgba8 rgba(int argb) => img.ColorRgba8(
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
      (argb >> 24) & 0xFF,
    );

// Drawn large and scaled down smoothly, so small icons stay centred instead of
// picking up rounding from a 256-unit grid.
const master = 1024;

img.Image _smaller(img.Image big, int size) =>
    img.copyResize(big, width: size, height: size, interpolation: img.Interpolation.average);

img.Image draw(int size, {int color = accent}) => _smaller(_lock(master, color), size);

img.Image drawStop(int size) => _smaller(_stop(master), size);

img.Image _lock(int size, int color) {
  final s = size / 256.0;
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  final back = rgba(bg);
  final fg = rgba(color);
  final clear = img.ColorRgba8(0, 0, 0, 0);

  final r = (48 * s).round();
  img.fillRect(canvas,
      x1: 0, y1: r, x2: size - 1, y2: size - 1 - r, color: back);
  img.fillRect(canvas,
      x1: r, y1: 0, x2: size - 1 - r, y2: size - 1, color: back);
  for (final c in [
    [r, r],
    [size - 1 - r, r],
    [r, size - 1 - r],
    [size - 1 - r, size - 1 - r],
  ]) {
    img.fillCircle(canvas, x: c[0], y: c[1], radius: r, color: back);
  }

  img.fillCircle(canvas,
      x: (128 * s).round(), y: (108 * s).round(), radius: (56 * s).round(), color: fg);
  img.fillCircle(canvas,
      x: (128 * s).round(), y: (108 * s).round(), radius: (34 * s).round(), color: back);
  img.fillRect(canvas,
      x1: (60 * s).round(),
      y1: (110 * s).round(),
      x2: (196 * s).round(),
      y2: (150 * s).round(),
      color: back);

  img.fillRect(canvas,
      x1: (68 * s).round(),
      y1: (118 * s).round(),
      x2: (188 * s).round(),
      y2: (206 * s).round(),
      color: fg);
  for (final c in [
    [(80 * s).round(), (130 * s).round()],
    [(176 * s).round(), (130 * s).round()],
    [(80 * s).round(), (194 * s).round()],
    [(176 * s).round(), (194 * s).round()],
  ]) {
    img.fillCircle(canvas, x: c[0], y: c[1], radius: (12 * s).round(), color: fg);
  }

  img.fillCircle(canvas,
      x: (128 * s).round(), y: (152 * s).round(), radius: (14 * s).round(), color: back);
  img.fillRect(canvas,
      x1: (122 * s).round(),
      y1: (152 * s).round(),
      x2: (134 * s).round(),
      y2: (182 * s).round(),
      color: back);

  if (clear.a == 0) return canvas;
  return canvas;
}

void main() {
  File('windows/runner/resources/app_icon.ico')
      .writeAsBytesSync(img.encodeIco(draw(256)));
  File('assets/tray_icon.ico').writeAsBytesSync(img.encodeIco(draw(32)));
  File('assets/tray_icon.png').writeAsBytesSync(img.encodePng(draw(32)));
  File('assets/icon.png').writeAsBytesSync(img.encodePng(draw(512)));
  for (final (folder, size) in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]) {
    File('android/app/src/main/res/mipmap-$folder/ic_launcher.png').writeAsBytesSync(img.encodePng(draw(size)));
  }
  Directory('extension/icons').createSync(recursive: true);
  for (final size in [16, 32, 48, 128]) {
    File('extension/icons/icon$size.png').writeAsBytesSync(img.encodePng(draw(size)));
  }
  // Toolbar stop sign: saving is switched off on this site.
  for (final size in [16, 32]) {
    File('extension/icons/stop$size.png').writeAsBytesSync(img.encodePng(drawStop(size)));
  }
  // Toolbar lock, blinking orange: a caught login waits for ✓ / ✕.
  // Red for a few seconds: the login just tried did not work.
  for (final size in [16, 32]) {
    File('extension/icons/pending$size.png')
        .writeAsBytesSync(img.encodePng(draw(size, color: 0xFFF29A2E)));
    File('extension/icons/failed$size.png')
        .writeAsBytesSync(img.encodePng(draw(size, color: 0xFFE53935)));
  }
  stdout.writeln('icons written');
}

/// A red octagon with a white bar — reads as "stop" even at 16 px.
img.Image _stop(int size) {
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
  final c = (size - 1) / 2;
  final r = size / 2;
  final corners = [
    for (var i = 0; i < 8; i++)
      img.Point(c + r * _cos(22.5 + 45 * i), c + r * _sin(22.5 + 45 * i)),
  ];
  img.fillPolygon(canvas, vertices: corners, color: img.ColorRgba8(0xD3, 0x2F, 0x2F, 255));
  final bar = (size * 0.16).round().clamp(2, size);
  final left = (size * 0.22).round();
  final top = (size / 2 - bar / 2).round();
  img.fillRect(canvas,
      x1: left,
      y1: top,
      x2: size - 1 - left,
      y2: size - 1 - top,
      color: img.ColorRgba8(255, 255, 255, 255));
  return canvas;
}

double _cos(double deg) => math.cos(deg * math.pi / 180);
double _sin(double deg) => math.sin(deg * math.pi / 180);
