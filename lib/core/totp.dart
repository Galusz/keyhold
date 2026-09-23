import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

Uint8List decodeBase32(String input) {
  final clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
  final out = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final char in clean.split('')) {
    final value = _alphabet.indexOf(char);
    if (value < 0) continue;
    buffer = (buffer << 5) | value;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      out.add((buffer >> bits) & 0xFF);
    }
  }
  return Uint8List.fromList(out);
}

int secondsLeft({int period = 30}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return period - (now % period);
}

Future<String> totpCode(String secret, {int digits = 6, int period = 30}) async {
  final key = decodeBase32(secret);
  if (key.isEmpty) return ''.padLeft(digits, '-');

  final counter = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ period;
  final message = Uint8List(8);
  var rest = counter;
  for (var i = 7; i >= 0; i--) {
    message[i] = rest & 0xFF;
    rest >>= 8;
  }

  final mac = await Hmac.sha1().calculateMac(message, secretKey: SecretKey(key));
  final bytes = mac.bytes;
  final offset = bytes[bytes.length - 1] & 0x0F;
  final binary = ((bytes[offset] & 0x7F) << 24) |
      ((bytes[offset + 1] & 0xFF) << 16) |
      ((bytes[offset + 2] & 0xFF) << 8) |
      (bytes[offset + 3] & 0xFF);

  final modulo = 1;
  var divisor = modulo;
  for (var i = 0; i < digits; i++) {
    divisor *= 10;
  }
  return (binary % divisor).toString().padLeft(digits, '0');
}

String? totpSecretFromUri(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'otpauth') return null;
  return uri.queryParameters['secret'];
}
