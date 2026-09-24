# Keyhold

Passwords, two-factor codes and important files in one encrypted file that backs itself up — on Windows, Android and in the browser.

- **Passwords and 2FA codes** — codes of their own, like Google Authenticator; pin one to a login or a site and it is offered right under the field. Ctrl+Alt+K types a login or a code into any window.
- **Browser extension** — logins and codes right under the field in Chrome, Edge and Firefox; a login you type in is offered for saving once it worked. It uses the Keyhold app on the same computer, or opens your vault from Google Drive on its own.
- **Android** — your codes and logins on the phone, filled into apps and browsers as the phone's password filler.
- **Important files** — watched folders such as `.ssh` are copied into the vault whenever they change.
- **Backups** — every change goes to the folders you choose, optionally to your own server over SSH and to your own Google Drive, which also keeps your devices in sync.
- **QR codes** — adds 2FA codes from the screen, an image or the phone's camera, including the Google Authenticator export.

The vault is encrypted with AES-256-GCM on your device. There is no Keyhold server and no account. See [how Keyhold protects your data](https://galusz.github.io/keyhold/security.html) and the [privacy policy](https://galusz.github.io/keyhold/privacy.html).

## Download

From the [latest release](https://github.com/Galusz/keyhold/releases/latest):

- **Windows** — unzip anywhere and run `keyhold.exe`.
- **Android** — install the `.apk`. In Keyhold's settings, *Fill passwords with Keyhold* makes it the phone's password filler; in Chrome also turn on *Settings → Autofill services → Autofill using another service*.
- **Browser extension** — it is in the `extension` folder next to `keyhold.exe`. Until it is in the stores, load it from there: in Chrome or Edge open `chrome://extensions`, turn on developer mode and choose *Load unpacked*; in Firefox open `about:debugging` → *This Firefox* → *Load Temporary Add-on*. Then open Keyhold, click the puzzle icon and paste the pairing token into the extension — or, on a computer without Keyhold, choose *Use my vault from Google Drive*.

## Build

```
flutter build windows --release --dart-define-from-file=google.json
flutter build apk --release
dart run tool/pack_extension.dart
```

`google.json` holds the Google sign-in keys for Drive sync and is not in the repository:

```json
{
  "KEYHOLD_GOOGLE_CLIENT_ID": "…apps.googleusercontent.com",
  "KEYHOLD_GOOGLE_CLIENT_SECRET": "…"
}
```

Create them in Google Cloud as an OAuth client of type *Desktop app* with the `drive.file` scope. Without the file Keyhold builds fine and simply has no Drive sync. The Android app signs in through its own Android client (the release key's SHA-1), and the extension through a *Web application* client whose redirect is the extension's `chromiumapp.org` address.
