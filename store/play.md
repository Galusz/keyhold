# Google Play — Keyhold (pl.zkv.keyhold)

Files: `play-icon-512.png`, `play-feature-1024x500.png`, `play-1-codes.png`, `play-2-all.png`, `play-3-details.png`.
Build: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.

## Store listing

**App name** (max 30)
```
Keyhold – Passwords & 2FA
```

### English (default)

**Short description** (max 80)
```
Passwords and 2FA codes in one encrypted vault. No account, no server of ours.
```

**Full description**
```
Keyhold keeps your passwords, two-factor codes and important files in one encrypted vault that belongs to you. Free and open source — no account, no subscription, no ads, no Keyhold server.

• Two-factor codes like Google Authenticator, with a countdown and the next code shown in the last seconds. Scan a QR code with the camera or bring in the Google Authenticator export.
• Fills logins and codes into apps and browsers from the suggestion right under the field, and offers to save new logins.
• Mark a bank login or a code and it is filled in only after your fingerprint.
• One master password opens the vault; a printable recovery key opens it if the password is ever forgotten.
• Keeps your devices in step through your own Google Drive — the vault is encrypted before it leaves the phone. Or back it up to a folder or a server of your own, in seven copies from the latest to one about a year old.
• Imports from Bitwarden, 1Password, KeePass, LastPass, Proton Pass, Aegis, 2FAS, andOTP, FreeOTP+ and browsers.
• Works with Keyhold for Windows and the browser extension for Chrome, Edge and Firefox.
• In English, Polish, German, Spanish, French, Portuguese, Italian, Chinese and Japanese.

The vault is encrypted with AES-256-GCM, with a key made from your master password by Argon2id. Nothing is sent to the author — no analytics, no tracking. Google Drive access is limited to the files Keyhold itself made.

Source code: https://github.com/Galusz/keyhold
How Keyhold protects your data: https://galusz.github.io/keyhold/security.html
```

### Polish

**Short description**
```
Hasła i kody 2FA w jednym zaszyfrowanym sejfie. Bez konta i bez naszego serwera.
```

**Full description**
```
Keyhold trzyma Twoje hasła, kody dwuskładnikowe i ważne pliki w jednym zaszyfrowanym sejfie, który należy do Ciebie. Darmowy i otwarty — bez konta, bez abonamentu, bez reklam, bez serwera Keyhold.

• Kody dwuskładnikowe jak w Google Authenticator, z odliczaniem i następnym kodem w ostatnich sekundach. Zeskanuj kod QR aparatem albo przenieś eksport z Google Authenticator.
• Wpisuje loginy i kody w aplikacjach i przeglądarkach z podpowiedzi tuż pod polem i proponuje zapisanie nowych loginów.
• Oznacz login do banku albo kod, a wpisze się dopiero po odcisku palca.
• Jedno hasło główne otwiera sejf; wydrukowany klucz odzyskiwania otworzy go, gdyby hasło kiedyś wypadło z głowy.
• Trzyma urządzenia w zgodzie przez Twój własny Google Drive — sejf jest szyfrowany, zanim opuści telefon. Albo kopia do folderu lub na własny serwer, w siedmiu kopiach od najnowszej do sprzed mniej więcej roku.
• Importuje z Bitwarden, 1Password, KeePass, LastPass, Proton Pass, Aegis, 2FAS, andOTP, FreeOTP+ i przeglądarek.
• Działa z Keyhold dla Windows i rozszerzeniem do Chrome, Edge i Firefox.
• Po polsku, angielsku, niemiecku, hiszpańsku, francusku, portugalsku, włosku, chińsku i japońsku.

Sejf jest szyfrowany AES-256-GCM kluczem wyprowadzonym z hasła głównego przez Argon2id. Nic nie trafia do autora — bez analityki i śledzenia. Dostęp do Google Drive jest ograniczony do plików, które założył sam Keyhold.

Kod źródłowy: https://github.com/Galusz/keyhold
Jak Keyhold chroni dane: https://galusz.github.io/keyhold/security.html
```

## App content (Policy → App content)

- **Privacy policy:** https://galusz.github.io/keyhold/privacy.html
- **Ads:** No ads.
- **App access:** All functionality is available without special access (the reviewer makes a vault with any password).
- **Content rating:** category "Utility, Productivity, Communication, or Other"; every question No → Everyone / PEGI 3.
- **Target audience:** 18 and over.
- **News app:** No. **Government app:** No. **Financial features:** None. **Health:** None.
- **Data safety:**
  - Does your app collect or share any of the required user data types? **No.**
  - Why: the vault never reaches the author; it goes only to the user's own Google Drive or folders, end-to-end encrypted (both exempt in Google's rules). The Google account email is kept on the phone only.

## Main store listing settings

- **Category:** Tools. **Tags:** Password manager, Authenticator, Security.
- **Contact:** website https://galusz.github.io/keyhold/, email = the developer account email.

## Signing and Google Drive

With Play App Signing Google re-signs the app, so its SHA-1 differs from `keys/keyhold-release.jks`.
Google sign-in (Drive) on a Play install works only after adding, in Google Cloud → Credentials,
an Android OAuth client: package `pl.zkv.keyhold`, SHA-1 from Play Console → Test and release → App integrity → App signing key certificate.
The GitHub APK and the Play install cannot update each other (different signatures): switching means uninstall, install, open the vault from Drive.
