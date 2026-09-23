# Keyhold

Passwords, two-factor codes and important files in one encrypted file that backs itself up.

- **Passwords and 2FA codes** — the current code next to every login; Ctrl+Alt+K types it into any window.
- **Browser extension** — logins and codes right under the field in Chrome, Edge and Firefox; new logins are saved as you sign in.
- **Important files** — watched folders such as `.ssh` are copied into the vault whenever they change.
- **Backups** — every change goes to the folders you choose, optionally to your own server over SSH and to your own Google Drive, which also keeps your devices in sync.
- **QR codes** — adds 2FA codes from the screen or an image, including the Google Authenticator export.

The vault is encrypted with AES-256-GCM on your device. There is no Keyhold server and no account. See the [privacy policy](https://galusz.github.io/keyhold/privacy.html).

## Download

Windows: [latest release](https://github.com/Galusz/keyhold/releases/latest) — unzip anywhere and run `keyhold.exe`.

The browser extension is in the `extension` folder next to `keyhold.exe`. Until it is in the stores, load it from there: in Chrome or Edge open `chrome://extensions`, turn on developer mode and choose *Load unpacked*; in Firefox open `about:debugging` → *This Firefox* → *Load Temporary Add-on*. Then open Keyhold, click the puzzle icon and paste the pairing token into the extension.

## Build

```
flutter build windows --release --dart-define-from-file=google.json
dart run tool/pack_extension.dart
```

`google.json` holds the Google sign-in keys for Drive sync and is not in the repository:

```json
{
  "KEYHOLD_GOOGLE_CLIENT_ID": "…apps.googleusercontent.com",
  "KEYHOLD_GOOGLE_CLIENT_SECRET": "…"
}
```

Create them in Google Cloud as an OAuth client of type *Desktop app* with the `drive.file` scope. Without the file Keyhold builds fine and simply has no Drive sync.
