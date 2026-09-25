# Keyhold

Passwords, two-factor codes and important files in one encrypted vault that backs itself up — on Windows, Android and in the browser.

- **One vault, one master password** — like KeePass: the master password opens the vault, and a printable recovery key opens it if the password is ever forgotten. Several vaults can live side by side, each with its own password.
- **Passwords and 2FA codes** — codes of their own, like Google Authenticator, with the next code shown in the last seconds; pin one to a login or a site and it is offered right under the field. Ctrl+Alt+K types a login or a code into any window.
- **Browser extension** — logins and codes right under the field in Chrome, Edge and Firefox, only for the very site they belong to; a login you type in is offered for saving once it worked. It uses the Keyhold app on the same computer, or opens your vault from Google Drive on its own.
- **Android** — your codes and logins on the phone, filled into apps and browsers as the phone's password filler.
- **Fingerprint and Windows Hello** — mark a login or a code and it is filled in only after your fingerprint on the phone or Windows Hello on the computer; Keyhold itself can open the same way. A device without either asks for the master password.
- **Important files** — add a file (recovery codes, keys) and it is kept in the vault; watched folders such as `.ssh` are copied in whenever a file is new or changed.
- **Backups** — every change goes to the folders you choose and optionally to your own server over SSH, in 7 copies from the latest to one about a year old; your own Google Drive keeps your devices in sync.
- **Import** — from browsers, Bitwarden, 1Password, KeePass, LastPass, Proton Pass, Aegis, 2FAS, andOTP, FreeOTP+ and other Keyhold vaults.
- **QR codes** — adds 2FA codes from the screen, an image or the phone's camera, including the Google Authenticator export.
- **Your language** — English, Polish, German, Spanish, French, Portuguese, Italian, Chinese and Japanese, picked from the language of the device or the browser.

The vault is encrypted with AES-256-GCM on your device, its key sealed by the master password with Argon2id. There is no Keyhold server and no account. See [how Keyhold protects your data](https://galusz.github.io/keyhold/security.html) and the [privacy policy](https://galusz.github.io/keyhold/privacy.html).

## Download

From the [latest release](https://github.com/Galusz/keyhold/releases/latest):

- **Windows** — unzip anywhere and run `keyhold.exe`.
- **Android** — install the `.apk`. In Keyhold's settings, *Fill passwords with Keyhold* makes it the phone's password filler; in Chrome also turn on *Settings → Autofill services → Autofill using another service*.
- **Browser extension** — it is in the `extension` folder next to `keyhold.exe`. Until it is in the stores, load it from there: in Chrome or Edge open `chrome://extensions`, turn on developer mode and choose *Load unpacked*; in Firefox open `about:debugging` → *This Firefox* → *Load Temporary Add-on*. Then in Keyhold choose *Menu → Browser extension* and paste the pairing token into the extension (its ⋮ menu → *Pair with the Keyhold app*) — or, on a computer without Keyhold, choose *Use my vault from Google Drive*.

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

Create them in Google Cloud as an OAuth client of type *Desktop app* with the `drive.file` scope. Without the file Keyhold builds fine and simply has no Drive sync. The Android app signs in through its own Android client (the release key's SHA-1), and the extension through a *Web application* client whose redirects are the extension's `chromiumapp.org` address and, for Firefox, its `extensions.allizom.org` address.
