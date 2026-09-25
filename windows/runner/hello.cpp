#include "hello.h"

#include <unknwn.h>
#include <winrt/base.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Security.Credentials.UI.h>
#include <UserConsentVerifierInterop.h>

#include <flutter/standard_method_codec.h>

#include <map>

namespace wf = winrt::Windows::Foundation;
namespace ui = winrt::Windows::Security::Credentials::UI;

namespace {

std::wstring Wide(const std::string& text) {
  if (text.empty()) return std::wstring();
  const int size = ::MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), nullptr, 0);
  std::wstring out(size, L'\0');
  ::MultiByteToWideChar(CP_UTF8, 0, text.data(), static_cast<int>(text.size()), out.data(), size);
  return out;
}

// The panel over the window in front; over Keyhold's own when nothing is.
HWND OwnerFor(HWND fallback) {
  HWND front = ::GetForegroundWindow();
  return front ? front : fallback;
}

}  // namespace

Hello::Hello(flutter::BinaryMessenger* messenger, HWND window) : window_(window) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "keyhold/hello", &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    if (call.method_name() != "ask") {
      result->NotImplemented();
      return;
    }
    // Keyhold asks one question at a time; a second one meanwhile is a no.
    if (pending_) {
      result->Success(flutter::EncodableValue(false));
      return;
    }
    reason_ = L"Keyhold";
    if (const auto* args = std::get_if<flutter::EncodableMap>(call.arguments())) {
      const auto found = args->find(flutter::EncodableValue("reason"));
      if (found != args->end()) {
        if (const auto* text = std::get_if<std::string>(&found->second)) reason_ = Wide(*text);
      }
    }
    pending_ = std::move(result);
    Start();
  });
}

// Windows answers on threads of its own; the reply goes back through the
// window, so it reaches Flutter on its own thread.
void Hello::Start() {
  try {
    ui::UserConsentVerifier::CheckAvailabilityAsync().Completed(
        [window = window_](const wf::IAsyncOperation<ui::UserConsentVerifierAvailability>& op, wf::AsyncStatus status) {
          const bool ready = status == wf::AsyncStatus::Completed && op.GetResults() == ui::UserConsentVerifierAvailability::Available;
          ::PostMessage(window, kAvailability, ready ? 1 : 0, 0);
        });
  } catch (...) {
    Answer(flutter::EncodableValue());
  }
}

void Hello::Verify() {
  try {
    const auto interop = winrt::get_activation_factory<ui::UserConsentVerifier, IUserConsentVerifierInterop>();
    const winrt::hstring reason(reason_);
    wf::IAsyncOperation<ui::UserConsentVerificationResult> op{nullptr};
    HRESULT hr = interop->RequestVerificationForWindowAsync(
        OwnerFor(window_), static_cast<HSTRING>(winrt::get_abi(reason)),
        winrt::guid_of<wf::IAsyncOperation<ui::UserConsentVerificationResult>>(), winrt::put_abi(op));
    // A window of another program may not be accepted: then over Keyhold's own, brought to the front.
    if (FAILED(hr)) {
      ::ShowWindow(window_, ::IsIconic(window_) ? SW_RESTORE : SW_SHOW);
      ::SetForegroundWindow(window_);
      hr = interop->RequestVerificationForWindowAsync(
          window_, static_cast<HSTRING>(winrt::get_abi(reason)),
          winrt::guid_of<wf::IAsyncOperation<ui::UserConsentVerificationResult>>(), winrt::put_abi(op));
    }
    winrt::check_hresult(hr);
    op.Completed([window = window_](const wf::IAsyncOperation<ui::UserConsentVerificationResult>& done, wf::AsyncStatus status) {
      const bool ok = status == wf::AsyncStatus::Completed && done.GetResults() == ui::UserConsentVerificationResult::Verified;
      ::PostMessage(window, kVerified, ok ? 1 : 0, 0);
    });
  } catch (...) {
    Answer(flutter::EncodableValue(false));
  }
}

bool Hello::Handle(UINT message, WPARAM wparam) {
  if (message == kAvailability) {
    if (wparam == 1) {
      Verify();
    } else {
      Answer(flutter::EncodableValue());
    }
    return true;
  }
  if (message == kVerified) {
    Answer(flutter::EncodableValue(wparam == 1));
    return true;
  }
  return false;
}

void Hello::Answer(const flutter::EncodableValue& value) {
  if (!pending_) return;
  auto result = std::move(pending_);
  result->Success(value);
}
