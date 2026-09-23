import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;
import 'package:win32/win32.dart';
import 'package:zxing2/qrcode.dart';

import 'crypto.dart';

/// A two-factor account read from a QR code.
class ScannedCode {
  ScannedCode({required this.issuer, required this.account, required this.secret});

  final String issuer;
  final String account;

  /// Base32, the form every authenticator shows as the setup key.
  final String secret;
}

class QrResult {
  QrResult({this.codes = const [], this.unsupported = 0, this.error});

  final List<ScannedCode> codes;

  /// Accounts using 8 digits, SHA-256 or counters, which Keyhold cannot generate.
  final int unsupported;
  final String? error;
}

typedef _Picture = ({int width, int height, Int32List pixels});

/// Takes a picture of all screens at once.
_Picture _captureScreen() {
  final left = GetSystemMetrics(SM_XVIRTUALSCREEN);
  final top = GetSystemMetrics(SM_YVIRTUALSCREEN);
  final width = GetSystemMetrics(SM_CXVIRTUALSCREEN);
  final height = GetSystemMetrics(SM_CYVIRTUALSCREEN);

  final screen = GetDC(null);
  final memory = CreateCompatibleDC(screen);
  final bitmap = CreateCompatibleBitmap(screen, width, height);
  final previous = SelectObject(memory, HGDIOBJ(bitmap));
  final info = calloc<BITMAPINFO>();
  final bits = calloc<Uint8>(width * height * 4);

  try {
    BitBlt(memory, 0, 0, width, height, screen, left, top, SRCCOPY);
    info.ref.bmiHeader
      ..biSize = sizeOf<BITMAPINFOHEADER>()
      ..biWidth = width
      ..biHeight = -height
      ..biPlanes = 1
      ..biBitCount = 32
      ..biCompression = 0;
    GetDIBits(memory, bitmap, 0, height, bits, info, DIB_RGB_COLORS);
    // BGRA bytes read as little-endian ints are the ARGB values the decoder wants.
    final pixels = Int32List.fromList(bits.cast<Int32>().asTypedList(width * height));
    return (width: width, height: height, pixels: pixels);
  } finally {
    SelectObject(memory, previous);
    DeleteObject(HGDIOBJ(bitmap));
    DeleteDC(memory);
    ReleaseDC(null, screen);
    calloc.free(info);
    calloc.free(bits);
  }
}

_Picture? _pictureFromFile(Uint8List bytes) {
  var image = img.decodeImage(bytes);
  if (image == null) return null;
  // Phone photos are huge; a QR code survives the shrink and decoding gets fast.
  if (image.width > 2000) image = img.copyResize(image, width: 2000);
  final rgba = image.convert(numChannels: 4);
  final bgra = rgba.getBytes(order: img.ChannelOrder.bgra);
  return (
    width: rgba.width,
    height: rgba.height,
    pixels: Int32List.fromList(bgra.buffer.asInt32List(bgra.offsetInBytes, rgba.width * rgba.height)),
  );
}

String? _decode(_Picture picture) {
  final hints = DecodeHints()..put(DecodeHintType.tryHarder);
  final source = RGBLuminanceSource(picture.width, picture.height, picture.pixels);
  for (final binarizer in [HybridBinarizer(source), GlobalHistogramBinarizer(source)]) {
    try {
      return QRCodeReader().decode(BinaryBitmap(binarizer), hints: hints).text;
    } catch (_) {
      // try the other way of telling black from white
    }
  }
  return null;
}

Future<QrResult> scanScreen() async {
  final picture = _captureScreen();
  final text = await Isolate.run(() => _decode(picture));
  if (text == null) return QrResult(error: 'No QR code found on the screen');
  return parseOtp(text);
}

Future<QrResult> scanImage(String path) async {
  final bytes = await File(path).readAsBytes();
  final text = await Isolate.run(() {
    final picture = _pictureFromFile(bytes);
    return picture == null ? null : _decode(picture);
  });
  if (text == null) return QrResult(error: 'No QR code found in this image');
  return parseOtp(text);
}

/// Reads both a single `otpauth://` code and the `otpauth-migration://`
/// export of Google Authenticator, which holds many accounts at once.
QrResult parseOtp(String text) {
  final uri = Uri.tryParse(text.trim());
  if (uri == null) return QrResult(error: 'This QR code is not a two-factor code');

  if (uri.scheme == 'otpauth-migration') {
    final data = uri.queryParameters['data'];
    if (data == null) return QrResult(error: 'The export QR code is empty');
    try {
      return _parseMigration(base64.decode(base64.normalize(data.replaceAll(' ', '+'))));
    } catch (_) {
      return QrResult(error: 'This export QR code could not be read');
    }
  }

  if (uri.scheme != 'otpauth') return QrResult(error: 'This QR code is not a two-factor code');

  final params = uri.queryParameters;
  final supported = uri.host == 'totp' &&
      (params['algorithm'] ?? 'SHA1').toUpperCase() == 'SHA1' &&
      (params['digits'] ?? '6') == '6' &&
      (params['period'] ?? '30') == '30';
  final secret = (params['secret'] ?? '').toUpperCase().replaceAll(RegExp(r'[\s=]'), '');
  if (!supported || secret.isEmpty) return QrResult(unsupported: 1);

  final label = Uri.decodeComponent(uri.path.replaceFirst('/', ''));
  final (labelIssuer, account) = _splitLabel(label);
  return QrResult(codes: [
    ScannedCode(issuer: params['issuer'] ?? labelIssuer, account: account, secret: secret),
  ]);
}

// Some sites write the label as "Google - me@mail.com" or "Shop (me@mail.com)"
// instead of the standard "Issuer:account".
final _nameAndMail = RegExp(r'^(.*?)\s*(?:[-–|(])\s*([^\s()]+@[^\s()]+)\)?$');

(String, String) _splitLabel(String label) {
  final colon = label.indexOf(':');
  if (colon >= 0) {
    return (label.substring(0, colon).trim(), label.substring(colon + 1).trim());
  }
  final m = _nameAndMail.firstMatch(label.trim());
  if (m != null && m.group(1)!.isNotEmpty) return (m.group(1)!.trim(), m.group(2)!);
  return ('', label.trim());
}

// Google's export is a protobuf message:
// MigrationPayload { repeated OtpParameters otp_parameters = 1; ... }
// OtpParameters { bytes secret = 1; string name = 2; string issuer = 3;
//                 algorithm = 4; digits = 5; type = 6; ... }
QrResult _parseMigration(Uint8List bytes) {
  final codes = <ScannedCode>[];
  var unsupported = 0;

  final payload = _Proto(bytes);
  while (!payload.done) {
    final (field, wire) = payload.tag();
    if (field != 1 || wire != 2) {
      payload.skip(wire);
      continue;
    }

    final otp = _Proto(payload.chunk());
    Uint8List? secret;
    var name = '';
    var issuer = '';
    var algorithm = 0;
    var digits = 0;
    var type = 0;
    while (!otp.done) {
      final (f, w) = otp.tag();
      switch (f) {
        case 1:
          secret = otp.chunk();
        case 2:
          name = utf8.decode(otp.chunk());
        case 3:
          issuer = utf8.decode(otp.chunk());
        case 4:
          algorithm = otp.varint();
        case 5:
          digits = otp.varint();
        case 6:
          type = otp.varint();
        default:
          otp.skip(w);
      }
    }

    // 0 means "not set", which Google treats as the defaults: SHA1, 6 digits, TOTP.
    final ok = secret != null && algorithm <= 1 && digits <= 1 && (type == 0 || type == 2);
    if (!ok) {
      unsupported++;
      continue;
    }

    final (labelIssuer, account) = _splitLabel(name);
    codes.add(ScannedCode(
      issuer: issuer.isNotEmpty ? issuer : labelIssuer,
      account: account,
      secret: encodeBase32(secret),
    ));
  }

  return QrResult(codes: codes, unsupported: unsupported);
}

class _Proto {
  _Proto(this.bytes);

  final Uint8List bytes;
  int pos = 0;

  bool get done => pos >= bytes.length;

  int varint() {
    var result = 0;
    var shift = 0;
    while (true) {
      final b = bytes[pos++];
      result |= (b & 0x7f) << shift;
      if (b & 0x80 == 0) return result;
      shift += 7;
    }
  }

  (int, int) tag() {
    final key = varint();
    return (key >> 3, key & 7);
  }

  Uint8List chunk() {
    final length = varint();
    final out = Uint8List.sublistView(bytes, pos, pos + length);
    pos += length;
    return out;
  }

  void skip(int wire) {
    switch (wire) {
      case 0:
        varint();
      case 1:
        pos += 8;
      case 2:
        chunk();
      case 5:
        pos += 4;
      default:
        throw const FormatException('Unknown protobuf field');
    }
  }
}
