import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

int foregroundWindow() => GetForegroundWindow().address;

void focusWindow(int handle) {
  if (handle == 0) return;
  final hwnd = HWND(Pointer.fromAddress(handle));
  ShowWindow(hwnd, SW_RESTORE);
  SetForegroundWindow(hwnd);
}

void _send(List<void Function(Pointer<INPUT>)> builders) {
  final buffer = calloc<INPUT>(builders.length);
  try {
    for (var i = 0; i < builders.length; i++) {
      builders[i](buffer + i);
    }
    SendInput(builders.length, buffer, sizeOf<INPUT>());
  } finally {
    calloc.free(buffer);
  }
}

void _unicodeChar(Pointer<INPUT> input, int code, {required bool up}) {
  input.ref.type = INPUT_KEYBOARD;
  input.ref.ki.wVk = VIRTUAL_KEY(0);
  input.ref.ki.wScan = code;
  input.ref.ki.dwFlags =
      KEYBD_EVENT_FLAGS(up ? KEYEVENTF_UNICODE | KEYEVENTF_KEYUP : KEYEVENTF_UNICODE);
}

void _virtualKey(Pointer<INPUT> input, VIRTUAL_KEY vk, {required bool up}) {
  input.ref.type = INPUT_KEYBOARD;
  input.ref.ki.wVk = vk;
  input.ref.ki.wScan = 0;
  input.ref.ki.dwFlags = KEYBD_EVENT_FLAGS(up ? KEYEVENTF_KEYUP : 0);
}

void typeText(String text) {
  if (text.isEmpty) return;
  for (final code in text.codeUnits) {
    _send([
      (p) => _unicodeChar(p, code, up: false),
      (p) => _unicodeChar(p, code, up: true),
    ]);
  }
}

void pressTab() => _send([
      (p) => _virtualKey(p, VK_TAB, up: false),
      (p) => _virtualKey(p, VK_TAB, up: true),
    ]);

void pressEnter() => _send([
      (p) => _virtualKey(p, VK_RETURN, up: false),
      (p) => _virtualKey(p, VK_RETURN, up: true),
    ]);

class AutoTypeTarget {
  static int handle = 0;
  static String title = '';

  static void remember() {
    handle = foregroundWindow();
    title = foregroundWindowTitle();
  }

  static void clear() {
    handle = 0;
    title = '';
  }
}

Future<void> typeCredentials(String username, String password) async {
  focusWindow(AutoTypeTarget.handle);
  await Future<void>.delayed(const Duration(milliseconds: 150));
  if (username.isNotEmpty) {
    typeText(username);
    pressTab();
    await Future<void>.delayed(const Duration(milliseconds: 60));
  }
  typeText(password);
}

Future<void> typeCode(String code) async {
  focusWindow(AutoTypeTarget.handle);
  await Future<void>.delayed(const Duration(milliseconds: 150));
  typeText(code);
}

String foregroundWindowTitle() {
  final hwnd = GetForegroundWindow();
  final length = GetWindowTextLength(hwnd).value;
  if (length <= 0) return '';

  final buffer = wsalloc(length + 1);
  try {
    GetWindowText(hwnd, buffer, length + 1);
    return buffer.toDartString();
  } finally {
    free(buffer);
  }
}
