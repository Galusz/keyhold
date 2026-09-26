# Store listing — Keyhold extension

Same text for Chrome Web Store, Edge Add-ons and Firefox Add-ons.
Packages: `dart run tool/pack_extension.dart` → `build/store/keyhold-extension-chromium-<version>.zip`
(Chrome, Edge) and `keyhold-extension-firefox-<version>.zip` (Firefox).

## Name
Keyhold

## Summary (up to 132 characters)
Fills logins and two-factor codes from your Keyhold vault, and saves new logins as you sign in. No account, no Keyhold server.

## Description
Keyhold keeps your passwords and two-factor codes in one encrypted vault that belongs to you. This extension brings it into your browser.

• Click a login field and pick the account from the list under it — the username and password are filled in.
• On a two-factor page the list shows the current code with a countdown; one click fills it.
• When you sign in with a new login, Keyhold offers to save it. When a password changes, it asks before updating.
• Works on two-step logins, where the username and the password are on separate pages.
• In English, Polish, German, Spanish, French, Portuguese, Italian, Chinese and Japanese.

Two ways to use it:
1. With the free Keyhold app for Windows on the same computer — the extension talks only to the app (127.0.0.1).
2. Without the app — the extension opens your vault from your own Google Drive, where the Keyhold app or the Android app keeps it. You sign in to Google and type the vault's master password; the vault is decrypted inside the extension and never leaves your computer unencrypted.

Keyhold for Windows and Android: https://github.com/Galusz/keyhold/releases/latest
There is no Keyhold account, no Keyhold server and no tracking.

Privacy policy: https://galusz.github.io/keyhold/privacy.html

## Category
Chrome: Productivity → Tools · Edge: Productivity · Firefox: Privacy & Security

## Links
Homepage: https://galusz.github.io/keyhold/
Support: https://github.com/Galusz/keyhold/issues
Privacy policy: https://galusz.github.io/keyhold/privacy.html

## Single purpose (Chrome)
Fill and save logins and two-factor codes from the user's own Keyhold vault.

## Permission justifications (Chrome, Edge)
- **activeTab** — fills the login the user picks in the toolbar popup into the page that is open.
- **scripting** — inserts the picked username, password or code into that page from the popup.
- **storage** — keeps the pairing token that connects the extension to the Keyhold app; without the app, the user's encrypted vault file and the site icons. For a few minutes it also keeps the username typed on the first page of a two-step login, so it can be saved together with the password.
- **unlimitedStorage** — without the app the encrypted vault file is kept locally; with files and icons it can exceed the default 10 MB.
- **alarms** — locks the vault opened from Google Drive after 30 minutes without use.
- **identity** — only when the user chooses "Use my vault from Google Drive": signs in to Google with the `drive.file` scope, which reaches only the files Keyhold itself made in the user's Drive.
- **Host permissions (all sites)** — the list under login fields and the offer to save a login have to work on every site where the user signs in; the icons of saved sites are fetched from those sites. `http://127.0.0.1:19919` is the Keyhold app on the same computer; `www.googleapis.com` is the user's Google Drive.
- **Remote code** — none. All code is in the package (Argon2 comes as WebAssembly inside it).

## Data usage (Chrome, Edge)
Handles: authentication information (usernames, passwords, two-factor codes) and website content (login forms on the current page).
- With the app: sent only to the Keyhold app on the same computer.
- Without the app: the vault is read from and written to the user's own Google Drive, encrypted with AES-256-GCM under the user's master password; Keyhold has no server and never sees it.
- Not sold, not transferred to third parties, not used for anything but filling and saving logins.
- Not used for creditworthiness or lending.

## Data collection (Firefox)
Declared in the manifest (`data_collection_permissions`): **authenticationInfo** (logins and codes, which go to the Keyhold app on the same computer or, encrypted, to the user's own Google Drive) and **browsingActivity** (the addresses of login pages, to offer the right logins, and the sites whose icons are fetched). Nothing goes to Keyhold or to anyone else.

## Google sign-in (Drive mode) — one-time setup in Google Cloud Console
The "Web application" OAuth client in the Keyhold project must list these authorized redirect URIs:
- Firefox (extension id `keyhold@zkv.pl`): `https://f3d4d6ce246a6b130ef433e32bd4b18081139064.extensions.allizom.org/`
- Edge Add-ons (CRX id `jngnkhkeahkmcbilappikdkcilhnfolm`): `https://jngnkhkeahkmcbilappikdkcilhnfolm.chromiumapp.org/`
- Chrome Web Store and the unpacked folder: `https://<extension id>.chromiumapp.org/` — the id each one gets.

## Notes for reviewers
1. Install Keyhold for Windows from https://github.com/Galusz/keyhold/releases/latest (unzip, run `keyhold.exe`).
2. On first start choose **Create a new vault**, set a master password, type the last row of the recovery key into the check field and press **Done**.
3. Click **New** and add a login, for example Title `example`, Username `reviewer@example.com`, Password `test-password`, Address `https://practicetestautomation.com/practice-test-login/`.
4. Open **Menu → Browser extension** in Keyhold and copy the pairing token.
5. Click the Keyhold icon in the browser toolbar, allow access, paste the token and press Connect.
6. Open the address from step 3 and click the username field — the list with the login appears under it; pick it to fill the form.
Without the Windows app the popup offers "Use my vault from Google Drive", which needs a vault made by the Keyhold app in that Google Drive.
