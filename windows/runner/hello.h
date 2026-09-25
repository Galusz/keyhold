#ifndef RUNNER_HELLO_H_
#define RUNNER_HELLO_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>

#include <memory>
#include <string>

// Windows Hello (face, fingerprint or the Windows PIN) for Keyhold, on the
// channel "keyhold/hello": "ask" answers true or false, or null when Hello is
// not set up on this computer. The panel belongs to the window in front — the
// browser a login is going into — so it comes up over it, and Keyhold's own
// window stays usable meanwhile.
class Hello {
 public:
  Hello(flutter::BinaryMessenger* messenger, HWND window);

  // Window messages posted back from Windows' threads; true when handled.
  bool Handle(UINT message, WPARAM wparam);

  static constexpr UINT kAvailability = WM_APP + 0x4b1;
  static constexpr UINT kVerified = WM_APP + 0x4b2;

 private:
  void Start();
  void Verify();
  void Answer(const flutter::EncodableValue& value);

  HWND window_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> pending_;
  std::wstring reason_;
};

#endif  // RUNNER_HELLO_H_
